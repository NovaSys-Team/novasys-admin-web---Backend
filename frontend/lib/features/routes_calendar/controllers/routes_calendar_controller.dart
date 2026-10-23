import 'package:flutter/foundation.dart';

import '../data/routes_calendar_mock_data.dart';
import '../models/school_route.dart';
import '../models/school_calendar_event.dart';
import '../models/trip_rule.dart';

class RoutesCalendarController extends ChangeNotifier {
  // A07 is a fixed October 2026 mock scenario, rather than a live calendar.
  static final demoToday = DateTime(2026, 10, 19);
  static final firstDate = DateTime(2026);
  static final lastDate = DateTime(2027, 12, 31);
  static const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<SchoolCalendarEvent> _events = createSchoolCalendarEvents();
  final Map<TripRule, String> _rules = {
    for (final rule in TripRule.values) rule: rule.initialValue,
  };
  final List<RuleChange> _ruleChanges = [];
  List<SchoolRoute> get routes => List.unmodifiable(schoolRoutesMockData);
  List<SchoolCalendarEvent> get events => List.unmodifiable(_events);
  List<RuleChange> get ruleChanges => List.unmodifiable(_ruleChanges);
  String selectedRouteId = 'R-12';
  TripPeriod period = TripPeriod.morning;
  DateTime selectedDate = demoToday;
  String routeQuery = '';
  String? schoolFilter;
  SchoolRoute get route => routes.firstWhere((r) => r.id == selectedRouteId);
  List<String> get schools => routes.expand((r) => r.schools).toSet().toList();
  List<SchoolRoute> get filteredRoutes => routes
      .where(
        (r) =>
            '${r.id} ${r.origin} ${r.destinations} ${r.driver} ${r.plate} ${r.schools.join(' ')}'
                .toLowerCase()
                .contains(routeQuery.trim().toLowerCase()) &&
            (schoolFilter == null || r.schools.contains(schoolFilter)),
      )
      .toList();
  void searchRoutes(String query) {
    routeQuery = query;
    notifyListeners();
  }

  void filterSchool(String? school) {
    schoolFilter = school;
    notifyListeners();
  }

  void clearRouteFilters() {
    routeQuery = '';
    schoolFilter = null;
    notifyListeners();
  }

  void selectRoute(String id) {
    if (!routes.any((r) => r.id == id)) return;
    selectedRouteId = id;
    notifyListeners();
  }

  void selectPeriod(TripPeriod value) {
    period = value;
    notifyListeners();
  }

  bool selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(firstDate) ||
        day.isAfter(lastDate) ||
        day.weekday > DateTime.friday) {
      return false;
    }
    selectedDate = day;
    notifyListeners();
    return true;
  }

  String get monthLabel =>
      '${monthNames[selectedDate.month - 1]} ${selectedDate.year}';
  static String shortDate(DateTime day) =>
      '${day.day} ${monthNames[day.month - 1].substring(0, 3)}';
  String get planLabel =>
      'plan v${route.version} for ${selectedDate == demoToday ? 'today' : shortDate(selectedDate)}';
  List<List<DateTime?>> get calendarWeeks {
    final first = DateTime(selectedDate.year, selectedDate.month);
    final last = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    var monday = first.subtract(Duration(days: first.weekday - 1));
    final weeks = <List<DateTime?>>[];
    while (!monday.isAfter(last)) {
      final cells = List<DateTime?>.generate(5, (i) {
        final day = monday.add(Duration(days: i));
        return day.month == first.month ? day : null;
      });
      if (cells.any((d) => d != null)) weeks.add(cells);
      monday = monday.add(const Duration(days: 7));
    }
    return weeks;
  }

  List<SchoolCalendarEvent> eventsOn(DateTime day) =>
      _events.where((e) => e.includes(day)).toList();
  List<SchoolCalendarEvent> get monthEvents =>
      _events
          .where(
            (e) =>
                !e.end.isBefore(
                  DateTime(selectedDate.year, selectedDate.month),
                ) &&
                e.start.isBefore(
                  DateTime(selectedDate.year, selectedDate.month + 1),
                ),
          )
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
  Set<String> get closedSchools {
    final holidays = eventsOn(selectedDate)
        .where((e) => e.kind == SchoolEventKind.noTrip);
    return holidays.any((e) => e.school == SchoolCalendarEvent.allSchools)
        ? route.schools.toSet()
        : holidays.map((e) => e.school).where(route.schools.contains).toSet();
  }

  bool get noTrips => route.schools.every(closedSchools.contains);
  bool absent(RouteStop stop) => stop.absent && selectedDate == demoToday;
  bool skipped(RouteStop stop) =>
      absent(stop) ||
      noTrips ||
      (stop.schools.isNotEmpty && stop.schools.every(closedSchools.contains));
  String stopTime(RouteStop stop) {
    if (skipped(stop)) return '—';
    if (period == TripPeriod.afternoon && stop.kind == StopKind.school) {
      final override = eventsOn(selectedDate)
          .where(
            (e) =>
                e.kind == SchoolEventKind.exams &&
                stop.schools.contains(e.school) &&
                e.afternoonPickup != null,
          )
          .firstOrNull;
      if (override != null) return override.afternoonPickup!;
    }
    return stop.time;
  }

  String? addNoTripDay({
    required DateTime date,
    required String school,
    required String reason,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(firstDate) ||
        day.isAfter(lastDate) ||
        day.weekday > DateTime.friday) {
      return 'Choose a school weekday in 2026 or 2027.';
    }
    if (school != SchoolCalendarEvent.allSchools && !schools.contains(school)) {
      return 'Choose a school from the list.';
    }
    if (reason.trim().isEmpty) return 'Enter a reason for the no-trip day.';
    if (eventsOn(day).any(
      (e) =>
          e.kind == SchoolEventKind.noTrip &&
          (e.school == school ||
              e.school == SchoolCalendarEvent.allSchools ||
              school == SchoolCalendarEvent.allSchools),
    )) {
      return 'A no-trip day already covers this school and date.';
    }
    _events.add(
      SchoolCalendarEvent(
        id: 'demo-holiday-${_events.length}',
        start: day,
        end: day,
        school: school,
        description: reason.trim(),
        kind: SchoolEventKind.noTrip,
      ),
    );
    selectedDate = day;
    notifyListeners();
    return null;
  }

  String ruleValue(TripRule rule) => _rules[rule]!;
  String ruleDisplay(TripRule rule) =>
      '${ruleValue(rule)}${rule.unit.isEmpty ? '' : ' ${rule.unit}'}';
  String? validateRule(TripRule rule, String value) {
    final text = value.trim();
    if (rule.isTime) {
      return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text)
          ? null
          : 'Use a valid 24-hour time (HH:MM).';
    }
    final number = int.tryParse(text);
    final limit = rule == TripRule.maxGpsAge
        ? 600
        : rule == TripRule.maxGpsAccuracy
        ? 1000
        : 5000;
    if (number == null || number < 1 || number > limit) {
      return 'Enter a whole number from 1 to $limit.';
    }
    if (rule == TripRule.arrivalRadius &&
        number > int.parse(ruleValue(TripRule.departureRadius))) {
      return 'Arrival radius cannot exceed departure radius.';
    }
    if (rule == TripRule.departureRadius &&
        number < int.parse(ruleValue(TripRule.arrivalRadius))) {
      return 'Departure radius cannot be smaller than arrival radius.';
    }
    return null;
  }

  String? updateRule(TripRule rule, String value) {
    final error = validateRule(rule, value);
    if (error != null) return error;
    final normalized = rule.isTime
        ? value.trim()
        : int.parse(value.trim()).toString();
    if (_rules[rule] == normalized) return null;
    _ruleChanges.add(RuleChange(rule, _rules[rule]!, normalized));
    _rules[rule] = normalized;
    notifyListeners();
    return null;
  }
}
