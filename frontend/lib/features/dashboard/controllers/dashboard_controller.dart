import 'package:flutter/foundation.dart';

import '../models/dashboard_mock_data.dart';
import '../models/dashboard_summary.dart';

class DashboardController extends ChangeNotifier {
  List<SummaryMetric> get metrics => DashboardMockData.metrics;
  List<AttentionItem> get attention => DashboardMockData.attention;
  List<TransportDay> get days => DashboardMockData.days;
  List<DashboardTrip> get trips => DashboardMockData.trips;
  DashboardIncident get incident => DashboardMockData.incident;
  int? _selectedDayIndex;
  int? get selectedDayIndex => _selectedDayIndex;
  TransportDay? get selectedDay =>
      _selectedDayIndex == null ? null : days[_selectedDayIndex!];
  int get totalTransported => days.fold(0, (sum, day) => sum + day.count);

  void selectDay(int index) {
    RangeError.checkValidIndex(index, days);
    if (_selectedDayIndex == index) return;
    _selectedDayIndex = index;
    notifyListeners();
  }
}
