import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/routes_calendar/controllers/routes_calendar_controller.dart';
import 'package:novasys_admin_web/features/routes_calendar/models/school_route.dart';
import 'package:novasys_admin_web/features/routes_calendar/models/school_calendar_event.dart';
import 'package:novasys_admin_web/features/routes_calendar/models/trip_rule.dart';

void main() {
  late RoutesCalendarController c;
  setUp(() => c = RoutesCalendarController());
  tearDown(() => c.dispose());
  test('A07 initial plan, weekday grid and rules match reference', () {
    expect(c.route.id, 'R-12');
    expect(c.route.morningStops, hasLength(7));
    expect(c.planLabel, 'plan v7 for today');
    expect(c.calendarWeeks, hasLength(5));
    expect(c.calendarWeeks.first.take(3), everyElement(isNull));
    expect(
      c.calendarWeeks.expand((w) => w).whereType<DateTime>(),
      hasLength(22),
    );
    expect(
      c.calendarWeeks
          .expand((w) => w)
          .whereType<DateTime>()
          .every((d) => d.weekday <= 5),
      true,
    );
    expect(c.ruleDisplay(TripRule.arrivalRadius), '100 m');
    expect(c.ruleDisplay(TripRule.maxGpsAge), '120 s');
    expect(c.stopTime(c.route.morningStops[1]), '—');
    expect(c.stopTime(c.route.morningStops.last), '07:38');
  });
  test('route search and school filter intersect; selection validates IDs', () {
    c.searchRoutes('  kumari ');
    expect(c.filteredRoutes.single.id, 'R-08');
    c.filterSchool('Ananda College');
    expect(c.filteredRoutes, isEmpty);
    c.clearRouteFilters();
    c.filterSchool('Royal College');
    expect(c.filteredRoutes, hasLength(2));
    c.searchRoutes('wp ph-4521');
    expect(c.filteredRoutes.single.id, 'R-12');
    c.selectRoute('missing');
    expect(c.route.id, 'R-12');
    c.selectRoute('R-05');
    expect(c.route.driver, 'Dilshan Fernando');
    expect(c.route.morningStops.last.title, 'Ananda College');
  });
  test('period/date switching applies holidays, exam pickup and attendance snapshot', () {
    c.selectPeriod(TripPeriod.afternoon);
    expect(c.route.stopsFor(c.period).first.title, 'Royal College');
    expect(c.stopTime(c.route.afternoonStops.first), '13:00');
    c.selectDate(DateTime(2026, 10, 26));
    expect(c.stopTime(c.route.afternoonStops.first), '11:30');
    expect(c.stopTime(c.route.afternoonStops[1]), '13:15');
    c.selectPeriod(TripPeriod.morning);
    expect(c.stopTime(c.route.morningStops.last), '07:38');
    expect(c.stopTime(c.route.morningStops[1]), '06:40');
    c.selectDate(DateTime(2026, 10, 22));
    expect(c.noTrips, true);
    expect(c.route.morningStops.every(c.skipped), true);
    expect(c.route.morningStops.map(c.stopTime), everyElement('—'));
  });
  test(
    'calendar date range validates weekdays and supports month/year changes',
    () {
      expect(c.selectDate(DateTime(2026, 10, 24)), false);
      expect(c.selectDate(DateTime(2025, 12, 31)), false);
      expect(c.selectDate(DateTime(2028)), false);
      expect(c.selectedDate, DateTime(2026, 10, 19));
      expect(c.selectDate(DateTime(2026, 11, 3, 15)), true);
      expect(c.selectedDate, DateTime(2026, 11, 3));
      expect(c.monthLabel, 'November 2026');
      expect(c.monthEvents, isEmpty);
      expect(
        c.calendarWeeks
            .expand((w) => w)
            .whereType<DateTime>()
            .every((d) => d.month == 11),
        true,
      );
    },
  );
  test(
    'no-trip day validates scope, reason, weekday and overlapping holidays',
    () {
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 24),
          school: 'All schools',
          reason: 'Holiday',
        ),
        isNotNull,
      );
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 20),
          school: 'Unknown',
          reason: 'Holiday',
        ),
        isNotNull,
      );
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 20),
          school: 'All schools',
          reason: '  ',
        ),
        isNotNull,
      );
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 22),
          school: 'Royal College',
          reason: 'Duplicate',
        ),
        isNotNull,
      );
      expect(c.events, hasLength(2));
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 20),
          school: 'Royal College',
          reason: '  Staff day  ',
        ),
        isNull,
      );
      expect(c.closedSchools, {'Royal College'});
      expect(c.noTrips, false);
      expect(c.stopTime(c.route.morningStops.last), '—');
      expect(c.stopTime(c.route.morningStops[5]), '07:24');
      expect(c.stopTime(c.route.morningStops[2]), '06:45');
      expect(c.events.last.description, 'Staff day');
      expect(
        c.addNoTripDay(
          date: DateTime(2026, 10, 20),
          school: 'All schools',
          reason: 'Overlaps',
        ),
        isNotNull,
      );
      c.selectRoute('R-05');
      expect(c.closedSchools, isEmpty);
      expect(c.noTrips, false);
    },
  );
  test('new all-school holiday overrides an exam pickup locally', () {
    c.selectPeriod(TripPeriod.afternoon);
    expect(
      c.addNoTripDay(
        date: DateTime(2026, 10, 26),
        school: SchoolCalendarEvent.allSchools,
        reason: 'Holiday',
      ),
      isNull,
    );
    expect(c.noTrips, true);
    expect(c.stopTime(c.route.afternoonStops.first), '—');
    expect(c.eventsOn(DateTime(2026, 10, 26)), hasLength(2));
  });
  test(
    'rule edits validate times, units and radius ordering and log changes once',
    () {
      expect(c.updateRule(TripRule.morningCutoff, '24:00'), isNotNull);
      expect(c.updateRule(TripRule.morningCutoff, '7:30'), isNotNull);
      expect(c.updateRule(TripRule.maxGpsAge, '0'), isNotNull);
      expect(c.updateRule(TripRule.maxGpsAge, '601'), isNotNull);
      expect(c.updateRule(TripRule.maxGpsAccuracy, 'abc'), isNotNull);
      expect(c.updateRule(TripRule.arrivalRadius, '151'), isNotNull);
      expect(c.updateRule(TripRule.departureRadius, '99'), isNotNull);
      expect(c.ruleChanges, isEmpty);
      expect(c.updateRule(TripRule.morningCutoff, ' 06:15 '), isNull);
      expect(c.ruleValue(TripRule.morningCutoff), '06:15');
      expect(c.ruleChanges.single.previous, '06:30');
      expect(c.updateRule(TripRule.morningCutoff, '06:15'), isNull);
      expect(c.ruleChanges, hasLength(1));
      expect(c.updateRule(TripRule.departureRadius, '0200'), isNull);
      expect(c.ruleDisplay(TripRule.departureRadius), '200 m');
    },
  );
  test('controller notifies on changes and isolates mock session state', () {
    var updates = 0;
    c.addListener(() => updates++);
    c.selectRoute('unknown');
    c.selectDate(DateTime(2026, 10, 24));
    expect(updates, 0);
    c.selectPeriod(TripPeriod.afternoon);
    c.updateRule(TripRule.maxGpsAge, '180');
    c.addNoTripDay(
      date: DateTime(2026, 10, 20),
      school: 'All schools',
      reason: 'Demo',
    );
    expect(updates, 3);
    final other = RoutesCalendarController();
    expect(other.events, hasLength(2));
    expect(other.ruleValue(TripRule.maxGpsAge), '120');
    expect(other.period, TripPeriod.morning);
    other.dispose();
  });
}
