import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/driver_verification/controllers/driver_verification_controller.dart';
import 'package:novasys_admin_web/features/driver_verification/models/driver_application.dart';

void main() {
  late DriverVerificationController controller;
  setUp(() => controller = DriverVerificationController());
  tearDown(() => controller.dispose());

  test(
    'Initial reference applications enforce all required document checks',
    () {
      expect(controller.pendingCount, 4);
      expect(controller.selected!.id, 'nimal');
      expect(controller.selected!.documents, hasLength(6));
      expect(controller.selected!.canApprove, isFalse);
      expect(controller.decide('nimal', VerificationDecision.approve), isFalse);
      expect(controller.actionError, contains('Every required document'));
      expect(controller.selected!.status, ApplicationStatus.pending);
      controller.selectApplication('tharindu');
      expect(controller.selected!.canApprove, isTrue);
      expect(controller.selected!.documents.every((doc) => doc.passes), isTrue);
    },
  );

  test(
    'Approval matches A02.2, decrements count and prevents repeat decisions',
    () {
      controller.selectApplication('tharindu');
      expect(
        controller.decide('tharindu', VerificationDecision.approve),
        isTrue,
      );
      expect(controller.selected!.detailStatus, 'VERIFIED');
      expect(controller.selected!.id, 'tharindu');
      expect(controller.pendingCount, 3);
      expect(
        controller.decide('tharindu', VerificationDecision.reject),
        isFalse,
      );
      expect(
        controller.decide('tharindu', VerificationDecision.approve),
        isFalse,
      );
      expect(controller.pendingCount, 3);
      expect(controller.selected!.status, ApplicationStatus.verified);
    },
  );

  test('Rejection requires a note and snapshots the reason without changing other drivers', () {
    controller.selectApplication('malini');
    controller.updateNote('malini', '   ');
    expect(controller.decide('malini', VerificationDecision.reject), isFalse);
    expect(controller.actionError, contains('Add a note'));
    controller.updateNote(
      'malini',
      ' Please provide a readable insurance photo. ',
    );
    expect(controller.decide('malini', VerificationDecision.reject), isTrue);
    expect(
      controller.selected!.decisionNote,
      'Please provide a readable insurance photo.',
    );
    expect(controller.pendingCount, 3);
    controller.updateNote('malini', 'Overwrite finalized reason');
    expect(
      controller.selected!.decisionNote,
      'Please provide a readable insurance photo.',
    );
    expect(controller.applications.first.status, ApplicationStatus.pending);
  });

  test('Re-upload keeps the application pending and does not repair mock documents', () {
    expect(
      controller.decide('nimal', VerificationDecision.requestReupload),
      isTrue,
    );
    expect(controller.selected!.status, ApplicationStatus.reuploadRequested);
    expect(controller.pendingCount, 4);
    expect(controller.selected!.documentsPass, isFalse);
    expect(controller.selected!.canApprove, isFalse);
    expect(
      controller.decide('nimal', VerificationDecision.requestReupload),
      isFalse,
    );
    expect(controller.decide('nimal', VerificationDecision.approve), isFalse);
    expect(controller.decide('nimal', VerificationDecision.reject), isTrue);
  });

  test('Search and status filters combine, handle no matches and reconcile selection', () {
    controller.setFilters(
      query: ' MAHARAGAMA ',
      filter: ApplicationFilter.ready,
    );
    expect(controller.filteredApplications.map((app) => app.id), [
      'tharindu',
      'kasun',
    ]);
    expect(controller.selected!.id, 'tharindu');
    controller.setFilters(query: 'WP KA', filter: ApplicationFilter.issues);
    expect(controller.filteredApplications.single.id, 'nimal');
    controller.setFilters(query: '198512345678', filter: ApplicationFilter.all);
    expect(controller.selected!.id, 'nimal');
    controller.setFilters(
      query: 'no matching application',
      filter: ApplicationFilter.all,
    );
    expect(controller.filteredApplications, isEmpty);
    expect(controller.selected, isNull);
    controller.clearFilters();
    expect(controller.filteredApplications, hasLength(4));
    expect(controller.selected!.id, 'nimal');
  });

  test(
    'Filtering verified applications reflects decisions; drafts are per driver',
    () {
      controller.updateNote('nimal', 'Nimal draft');
      controller.selectApplication('tharindu');
      controller.updateNote('tharindu', 'Tharindu draft');
      controller.selectApplication('nimal');
      expect(controller.selected!.note, 'Nimal draft');
      controller.decide('tharindu', VerificationDecision.approve);
      controller.setFilters(query: '', filter: ApplicationFilter.verified);
      expect(controller.filteredApplications.single.id, 'tharindu');
      expect(controller.selected!.note, 'Tharindu draft');
      expect(
        controller.decide('unknown', VerificationDecision.reject),
        isFalse,
      );
      expect(controller.applications, hasLength(4));
      expect(() => controller.applications.clear(), throwsUnsupportedError);
    },
  );
}
