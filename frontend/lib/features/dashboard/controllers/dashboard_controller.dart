import 'package:flutter/foundation.dart';

import '../models/dashboard_summary.dart';

class DashboardController extends ChangeNotifier {
  static const _morning = DashboardSummary(
    activeTrips: 24,
    pendingVerifications: 8,
    openIncidents: 3,
  );
  static const _afternoon = DashboardSummary(
    activeTrips: 18,
    pendingVerifications: 5,
    openIncidents: 1,
  );
  bool _isAfternoon = false;

  String get sessionLabel => _isAfternoon ? 'Afternoon' : 'Morning';
  DashboardSummary get summary => _isAfternoon ? _afternoon : _morning;

  void toggleSession() {
    _isAfternoon = !_isAfternoon;
    notifyListeners();
  }
}
