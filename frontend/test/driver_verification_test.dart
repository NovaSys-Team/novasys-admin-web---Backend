import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';
import 'package:novasys_admin_web/features/driver_verification/controllers/driver_verification_controller.dart';
import 'package:novasys_admin_web/features/driver_verification/models/driver_application.dart';
import 'package:novasys_admin_web/features/driver_verification/views/driver_verification_view.dart';
import 'package:novasys_admin_web/features/driver_verification/widgets/verification_document_card.dart';
import 'package:novasys_admin_web/shared/widgets/admin_sidebar.dart';

import 'support/test_app.dart';

void main() {
  void viewport(WidgetTester tester, Size size, {double textScale = 1}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> openVerification(WidgetTester tester) async {
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.bySemanticsLabel('Admin overview')))
        .go(AppRouter.verificationPath);
    await tester.pumpAndSettle();
  }

  DriverVerificationController controller(WidgetTester tester) => tester
      .element(find.byType(DriverVerificationView))
      .read<DriverVerificationController>();
  Future<void> select(WidgetTester tester, String id) async {
    final item = find.byKey(ValueKey('application-$id'));
    await tester.ensureVisible(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  Future<void> action(WidgetTester tester, String key) async {
    final button = find.byKey(ValueKey(key));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'A02 includes four applications, all metadata and six document checks',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openVerification(tester);
      expect(find.text('Driver verification'), findsOneWidget);
      expect(find.text(DriverVerificationView.subtitle), findsOneWidget);
      for (final id in ['nimal', 'tharindu', 'malini', 'kasun']) {
        expect(find.byKey(ValueKey('application-$id')), findsOneWidget);
      }
      expect(find.byType(VerificationDocumentCard), findsNWidgets(6));
      for (final text in [
        'PENDING REVIEW',
        'Nissan Caravan · WP KA–2210 · 12 seats',
        'Rajagiriya, Kotte',
        '17 Oct 2026',
        'Valid to 2030',
        'Matches name',
        'Unreadable photo',
        'Valid to Mar 2027',
        'Expires in 26 days',
        'Issued Sep 2026',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('approve-driver')))
            .onPressed,
        isNull,
      );
      await action(tester, 'document-insurance');
      expect(find.text('Insurance · Nimal Silva'), findsOneWidget);
      expect(find.textContaining('No real scan is loaded'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Approval confirms before mutation, matches A02.2 and updates sidebar badge',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openVerification(tester);
      await select(tester, 'tharindu');
      expect(find.text('Toyota HiAce · WP PJ–8812 · 14 seats'), findsOneWidget);
      expect(find.text('Valid to Jan 2027'), findsOneWidget);
      expect(find.text('Issued Oct 2026'), findsOneWidget);
      await action(tester, 'approve-driver');
      expect(find.text('Approve driver?'), findsOneWidget);
      expect(
        find.textContaining('No real driver account is changed'),
        findsOneWidget,
      );
      expect(controller(tester).selected!.status, ApplicationStatus.pending);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller(tester).pendingCount, 4);
      await action(tester, 'approve-driver');
      await action(tester, 'confirm-verification');
      expect(find.text('VERIFIED'), findsNWidgets(2));
      expect(
        find.text('Tharindu Rajapaksha approved (demo only).'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AdminSidebar),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('approve-driver')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('reject-driver')))
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'Reject requires a reason and cancellation leaves the application unchanged',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openVerification(tester);
      await select(tester, 'malini');
      await action(tester, 'reject-driver');
      expect(find.textContaining('Add a note to the driver'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      final note = find.byKey(const ValueKey('driver-note'));
      await tester.ensureVisible(note);
      await tester.enterText(
        note,
        'Please upload a readable insurance certificate.',
      );
      await action(tester, 'reject-driver');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller(tester).selected!.status, ApplicationStatus.pending);
      await action(tester, 'reject-driver');
      await action(tester, 'confirm-verification');
      expect(find.text('REJECTED'), findsOneWidget);
      expect(
        find.text('Malini Wijesekara rejected (demo only).'),
        findsOneWidget,
      );
      expect(
        controller(tester).selected!.decisionNote,
        'Please upload a readable insurance certificate.',
      );
    },
  );

  testWidgets(
    'Re-upload confirmation updates local status without pretending to send a message',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openVerification(tester);
      await action(tester, 'request-reupload');
      expect(
        find.textContaining('No real driver account is changed'),
        findsOneWidget,
      );
      await action(tester, 'confirm-verification');
      expect(find.text('RE-UPLOAD REQUESTED'), findsOneWidget);
      expect(controller(tester).pendingCount, 4);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('request-reupload')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Unreadable photo'), findsOneWidget);
    },
  );

  testWidgets('Search, status filter, no-results state and clearing work', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openVerification(tester);
    await tester.tap(find.byTooltip('Search and filter applications'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('application-search')),
      'THARINDU',
    );
    await tester.tap(find.byType(DropdownButtonFormField<ApplicationFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ready to approve').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('application-tharindu')), findsOneWidget);
    expect(find.byKey(const ValueKey('application-nimal')), findsNothing);
    expect(controller(tester).selected!.id, 'tharindu');
    await tester.tap(find.byTooltip('Search and filter applications'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('application-search')),
      'no matches',
    );
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.text('No applications match your search.'), findsOneWidget);
    expect(find.byType(VerificationDocumentCard), findsNothing);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.byType(VerificationDocumentCard), findsNWidgets(6));
  });

  testWidgets(
    'Drafts, selection, filters and decisions survive normal sidebar navigation',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openVerification(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('driver-note')));
      await tester.enterText(
        find.byKey(const ValueKey('driver-note')),
        'Saved Nimal draft',
      );
      await select(tester, 'tharindu');
      await action(tester, 'approve-driver');
      await action(tester, 'confirm-verification');
      controller(tester)
          .setFilters(query: 'tharindu', filter: ApplicationFilter.verified);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
      await tester.tap(find.text('Verification'));
      await tester.pumpAndSettle();
      expect(controller(tester).query, 'tharindu');
      expect(controller(tester).filter, ApplicationFilter.verified);
      expect(find.text('VERIFIED'), findsNWidgets(2));
      controller(tester).clearFilters();
      await tester.pumpAndSettle();
      await select(tester, 'nimal');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('driver-note')))
            .controller!
            .text,
        'Saved Nimal draft',
      );
    },
  );

  testWidgets('Verification is guarded and mock reviews reset after logout', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openVerification(tester);
    controller(tester).decide('tharindu', VerificationDecision.approve);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInView), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(SignInView)));
    router.go(AppRouter.verificationPath);
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRouter.signInPath,
    );
    final session = tester
        .element(find.byType(SignInView))
        .read<DemoSessionController>();
    session.startSession(persistent: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    expect(controller(tester).pendingCount, 4);
    expect(
      controller(tester).applications[1].status,
      ApplicationStatus.pending,
    );
  });

  testWidgets('Direct verification route redirects without a demo session', (
    tester,
  ) async {
    final session = DemoSessionController(store: MemoryDemoSessionStore());
    addTearDown(session.dispose);
    await tester.pumpWidget(NovaSysApp(session: session));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(SignInView)));
    router.go('${AppRouter.verificationPath}/application');
    await tester.pumpAndSettle();
    expect(find.byType(SignInView), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRouter.signInPath,
    );
  });

  testWidgets(
    'Narrow enlarged-text filters and document previews remain usable',
    (tester) async {
      viewport(tester, const Size(320, 700), textScale: 1.5);
      await openVerification(tester);
      await tester.tap(find.byTooltip('Search and filter applications'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<ApplicationFilter>),
      );
      await tester.tap(find.byType(DropdownButtonFormField<ApplicationFilter>));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Re-upload requested').last);
      await tester.tap(find.text('Re-upload requested').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Apply filters'));
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();
      expect(find.text('No applications match your search.'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      await action(tester, 'document-police');
      expect(find.textContaining('No real scan is loaded'), findsOneWidget);
      await tester.ensureVisible(find.text('Close'));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(1440, 1000),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 700),
    const Size(320, 600),
  ]) {
    testWidgets(
      'Verification has no overflow and actions remain reachable at $size',
      (tester) async {
        viewport(tester, size, textScale: size.width < 800 ? 1.5 : 1);
        await openVerification(tester);
        expect(find.byType(VerificationDocumentCard), findsNWidgets(6));
        await select(tester, 'tharindu');
        await action(tester, 'approve-driver');
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
