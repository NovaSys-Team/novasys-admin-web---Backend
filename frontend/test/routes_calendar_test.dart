import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/features/routes_calendar/controllers/routes_calendar_controller.dart';
import 'package:novasys_admin_web/features/routes_calendar/models/school_route.dart';
import 'package:novasys_admin_web/features/routes_calendar/models/trip_rule.dart';
import 'package:novasys_admin_web/features/routes_calendar/views/routes_calendar_view.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';

import 'support/test_app.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = size.width < 800
        ? 1.5
        : 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go('/routes-calendar');
    await tester.pumpAndSettle();
  }

  RoutesCalendarController controller(WidgetTester t) => t
      .element(find.byType(RoutesCalendarView))
      .read<RoutesCalendarController>();
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder day(int number) =>
      find.byKey(ValueKey('calendar-day-2026-10-$number'));
  testWidgets('A07 route stops, absent state, calendar legends and six rules', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Start · Rajagiriya depot'), findsOneWidget);
    expect(find.text('Pita Kotte junction'), findsOneWidget);
    expect(find.text('Tharushi M. · absent today'), findsOneWidget);
    expect(find.text('Sanuli P., Kavin P.'), findsOneWidget);
    expect(find.text('Hiruni B., Senuri J., +3'), findsOneWidget);
    expect(find.text('07:38'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(
      find.text(
        '· School holiday (all schools) · no trips, no absences needed',
      ),
      findsOneWidget,
    );
    expect(
      find.text('· Royal College exams · afternoon pickup 11:30'),
      findsOneWidget,
    );
    for (final rule in TripRule.values) {
      expect(find.text(rule.label), findsOneWidget);
      expect(find.byKey(ValueKey('rule-${rule.name}')), findsOneWidget);
    }
    expect(find.text('100 m'), findsNWidgets(2));
    expect(find.text('150 m'), findsOneWidget);
    expect(find.text('120 s'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'morning/afternoon and dates show holiday and exam pickup states',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('period-afternoon')));
      expect(controller(tester).period, TripPeriod.afternoon);
      expect(find.text('13:15'), findsOneWidget);
      await tap(tester, day(26));
      expect(find.text('11:30'), findsOneWidget);
      await tap(tester, day(22));
      expect(
        find.text('No trips · School holiday · no absences needed'),
        findsOneWidget,
      );
      expect(find.text('School no-trip day'), findsNWidgets(7));
      expect(find.text('11:30'), findsNothing);
      await tap(tester, day(19));
      await tap(tester, find.byKey(const ValueKey('period-morning')));
      expect(find.text('07:38'), findsOneWidget);
    },
  );
  testWidgets(
    'route list searches, filters, selects and retains independent state',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('route-selector')));
      await tester.enterText(
        find.byKey(const ValueKey('route-search')),
        'Kumari',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('choose-route-R-08')), findsOneWidget);
      expect(find.byKey(const ValueKey('choose-route-R-12')), findsNothing);
      await tap(tester, find.byType(DropdownButtonFormField<String>));
      await tap(tester, find.text('Ananda College').last);
      expect(find.text('No matching routes.'), findsOneWidget);
      await tap(tester, find.text('Clear filters'));
      await tap(tester, find.byKey(const ValueKey('choose-route-R-05')));
      expect(controller(tester).route.id, 'R-05');
      expect(find.text('Start · Nawala depot'), findsOneWidget);
      final c = controller(tester);
      await tap(tester, find.text('Overview'));
      await tap(tester, find.text('Routes & calendar'));
      expect(identical(c, controller(tester)), true);
      expect(c.route.id, 'R-05');
    },
  );
  testWidgets(
    'no-trip creation requires confirmation and rejects duplicate dates',
    (tester) async {
      await open(tester);
      await tap(tester, day(20));
      await tap(tester, find.byKey(const ValueKey('add-no-trip-day')));
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).events, hasLength(2));
      await tap(tester, find.byKey(const ValueKey('add-no-trip-day')));
      await tester.enterText(find.byKey(const ValueKey('no-trip-reason')), '');
      await tap(tester, find.byKey(const ValueKey('confirm-no-trip')));
      expect(find.text('Enter a reason.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('no-trip-reason')),
        'Staff training',
      );
      await tap(tester, find.byKey(const ValueKey('confirm-no-trip')));
      expect(controller(tester).events, hasLength(3));
      expect(
        find.text('No-trip day added to this demo. No notifications sent.'),
        findsOneWidget,
      );
      expect(controller(tester).noTrips, true);
      await tap(tester, find.byKey(const ValueKey('add-no-trip-day')));
      await tap(tester, find.byKey(const ValueKey('confirm-no-trip')));
      expect(
        find.text('A no-trip day already covers this school and date.'),
        findsOneWidget,
      );
      await tap(tester, find.text('Cancel'));
    },
  );
  testWidgets('school-specific no-trip day skips only affected school stops', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, day(20));
    await tap(tester, find.byKey(const ValueKey('add-no-trip-day')));
    await tap(tester, find.byKey(const ValueKey('no-trip-school')));
    await tap(tester, find.text('Royal College').last);
    await tap(tester, find.byKey(const ValueKey('confirm-no-trip')));
    expect(controller(tester).closedSchools, {'Royal College'});
    expect(controller(tester).noTrips, false);
    expect(find.text('School no-trip day'), findsNWidgets(2));
    expect(find.text('07:24'), findsOneWidget);
    expect(find.text('06:45'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('rule editor validates, cancels and confirms local changes', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('rule-morningCutoff')));
    await tester.enterText(
      find.byKey(const ValueKey('trip-rule-value')),
      '25:00',
    );
    await tap(tester, find.byKey(const ValueKey('confirm-trip-rule')));
    expect(find.text('Use a valid 24-hour time (HH:MM).'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('trip-rule-value')),
      '06:15',
    );
    await tap(tester, find.text('Cancel'));
    expect(controller(tester).ruleValue(TripRule.morningCutoff), '06:30');
    await tap(tester, find.byKey(const ValueKey('rule-morningCutoff')));
    await tester.enterText(
      find.byKey(const ValueKey('trip-rule-value')),
      '06:15',
    );
    await tap(tester, find.byKey(const ValueKey('confirm-trip-rule')));
    expect(find.text('06:15'), findsOneWidget);
    expect(controller(tester).ruleChanges, hasLength(1));
    await tap(tester, find.byKey(const ValueKey('rule-arrivalRadius')));
    await tester.enterText(
      find.byKey(const ValueKey('trip-rule-value')),
      '999',
    );
    await tap(tester, find.byKey(const ValueKey('confirm-trip-rule')));
    expect(
      find.text('Arrival radius cannot exceed departure radius.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Cancel'));
  });
  testWidgets(
    'calendar date picker selects another month without changing on cancel',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('calendar-date-picker')));
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).selectedDate, DateTime(2026, 10, 19));
      await tap(tester, find.byKey(const ValueKey('calendar-date-picker')));
      await tap(tester, find.byTooltip('Next month'));
      await tap(
        tester,
        find
            .descendant(
              of: find.byType(DatePickerDialog),
              matching: find.text('3'),
            )
            .last,
      );
      await tap(tester, find.text('OK'));
      expect(controller(tester).selectedDate, DateTime(2026, 11, 3));
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('No calendar events this month.'), findsOneWidget);
    },
  );
  testWidgets('protected route and mock rules/events reset after logout', (
    tester,
  ) async {
    await open(tester);
    controller(tester).updateRule(TripRule.maxGpsAge, '180');
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(RoutesCalendarView)));
    await tap(tester, find.text('Sign out'));
    for (final path in ['/routes-calendar', '/routes-calendar/unknown']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(SignInView), findsOneWidget);
    }
    tester
        .element(find.byType(SignInView))
        .read<DemoSessionController>()
        .startSession(persistent: false);
    await tester.pumpAndSettle();
    router.go('/routes-calendar');
    await tester.pumpAndSettle();
    expect(controller(tester).ruleValue(TripRule.maxGpsAge), '120');
    expect(controller(tester).events, hasLength(2));
  });
  for (final size in [
    const Size(1440, 1000),
    const Size(1280, 800),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 800),
    const Size(320, 700),
  ]) {
    testWidgets('route plan, calendar, rules and dialogs fit $size', (
      tester,
    ) async {
      await open(tester, size: size);
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const ValueKey('period-afternoon')));
      await tap(tester, day(26));
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const ValueKey('add-no-trip-day')));
      await tap(tester, find.byKey(const ValueKey('no-trip-date')));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Cancel').last);
      await tap(tester, find.text('Cancel'));
      await tap(tester, find.byKey(const ValueKey('rule-maxGpsAge')));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Cancel'));
      await tap(tester, find.byTooltip('Find a route'));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Close'));
    });
  }
}
