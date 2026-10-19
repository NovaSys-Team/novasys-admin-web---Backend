import 'package:flutter/foundation.dart';

import '../models/driver_application.dart';
import '../models/driver_verification_mock_data.dart';

class DriverVerificationController extends ChangeNotifier {
  final List<DriverApplication> _applications = List.of(
    DriverVerificationMockData.applications,
  );
  String? _selectedId = DriverVerificationMockData.applications.first.id;
  String _query = '';
  ApplicationFilter _filter = ApplicationFilter.all;
  String? _actionError;
  List<DriverApplication> get applications => List.unmodifiable(_applications);
  String get query => _query;
  ApplicationFilter get filter => _filter;
  String? get actionError => _actionError;
  bool get hasFilters => _query.isNotEmpty || _filter != ApplicationFilter.all;
  int get pendingCount => _applications.where((app) => !app.isFinal).length;
  DriverApplication? get selected {
    for (final app in _applications) {
      if (app.id == _selectedId) return app;
    }
    return null;
  }

  List<DriverApplication> get filteredApplications => List.unmodifiable(
    _applications.where((app) {
      final search =
          '${app.name} ${app.phone} ${app.nic} ${app.vehicle} ${app.serviceArea}'
              .toLowerCase();
      if (!search.contains(_query.toLowerCase())) return false;
      return switch (_filter) {
        ApplicationFilter.all => true,
        ApplicationFilter.pending => !app.isFinal,
        ApplicationFilter.ready => app.canApprove,
        ApplicationFilter.issues => !app.isFinal && !app.documentsPass,
        ApplicationFilter.verified => app.status == ApplicationStatus.verified,
        ApplicationFilter.rejected => app.status == ApplicationStatus.rejected,
        ApplicationFilter.reuploadRequested =>
          app.status == ApplicationStatus.reuploadRequested,
      };
    }),
  );
  void setFilters({required String query, required ApplicationFilter filter}) {
    _query = query.trim();
    _filter = filter;
    _actionError = null;
    _reconcileSelection();
    notifyListeners();
  }

  void clearFilters() => setFilters(query: '', filter: ApplicationFilter.all);
  void _reconcileSelection() {
    final visible = filteredApplications;
    if (!visible.any((app) => app.id == _selectedId)) {
      _selectedId = visible.isEmpty ? null : visible.first.id;
    }
  }

  void selectApplication(String id) {
    if (!filteredApplications.any((app) => app.id == id)) return;
    _selectedId = id;
    _actionError = null;
    notifyListeners();
  }

  void updateNote(String id, String note) {
    final index = _applications.indexWhere((app) => app.id == id);
    if (index < 0 || _applications[index].isFinal) return;
    _applications[index] = _applications[index].copyWith(note: note);
    _actionError = null;
    notifyListeners();
  }

  bool validateDecision(String id, VerificationDecision decision) {
    final index = _applications.indexWhere((app) => app.id == id);
    final app = index < 0 ? null : _applications[index];
    _actionError = switch (app) {
      null => 'This demo application is no longer available.',
      DriverApplication(isFinal: true) =>
        'This application has already been decided.',
      _ when decision == VerificationDecision.approve && !app.canApprove =>
        'Every required document must pass before approval.',
      _
          when decision == VerificationDecision.requestReupload &&
              app.status == ApplicationStatus.reuploadRequested =>
        'A re-upload has already been requested in this demo.',
      _
          when decision != VerificationDecision.approve &&
              app.note.trim().isEmpty =>
        'Add a note to the driver before rejecting or requesting a re-upload.',
      _ => null,
    };
    notifyListeners();
    return _actionError == null;
  }

  bool decide(String id, VerificationDecision decision) {
    if (!validateDecision(id, decision)) return false;
    final index = _applications.indexWhere((app) => app.id == id);
    final app = _applications[index];
    _applications[index] = app.copyWith(
      status: switch (decision) {
        VerificationDecision.approve => ApplicationStatus.verified,
        VerificationDecision.reject => ApplicationStatus.rejected,
        VerificationDecision.requestReupload =>
          ApplicationStatus.reuploadRequested,
      },
      decisionNote: decision == VerificationDecision.approve
          ? ''
          : app.note.trim(),
    );
    _reconcileSelection();
    notifyListeners();
    return true;
  }
}
