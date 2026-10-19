import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/live_trips/controllers/live_trips_controller.dart';
import 'package:novasys_admin_web/features/live_trips/models/live_trip.dart';
import 'package:novasys_admin_web/features/live_trips/models/trip_incident.dart';
import 'package:novasys_admin_web/features/live_trips/views/live_trips_view.dart';
import 'package:novasys_admin_web/shared/widgets/admin_sidebar.dart';

import 'support/test_app.dart';

void main() {
  void viewport(WidgetTester tester, Size size, {double scale = 1}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  LiveTripsController controller(WidgetTester tester) =>
      tester.element(find.byType(LiveTripsView)).read<LiveTripsController>();
  Future<void> openLive(WidgetTester tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.bySemanticsLabel('Admin overview')))
        .go(AppRouter.liveTripsPath);
    await tester.pumpAndSettle();
  }

  Future<void> action(WidgetTester tester, String key) async {
    final item = find.byKey(ValueKey(key));
    await tester.ensureVisible(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  Future<void> acknowledge(WidgetTester tester) async {
    await action(tester, 'acknowledge-incident');
    await action(tester, 'confirm-incident-action');
  }

  testWidgets(
    'A03 initial content has map, counts, incident details and a searchable trip table',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openLive(tester);
      for (final text in [
        'On time 14',
        'Late 2',
        'GPS stale 1',
        'SOS 1',
        'OPEN · 1 MIN',
        'SOS · Vehicle breakdown',
        'WP PH–4521',
        '11 students · 2 schools',
        'Acknowledge & call driver',
        'Live trip list',
      ]) {
        expect(find.text(text), findsWidgets);
      }
      expect(find.byKey(const ValueKey('map-trip-ruwan')), findsOneWidget);
      expect(find.text('SOS raised by driver · breakdown'), findsOneWidget);
      expect(controller(tester).pageTrips, hasLength(5));
      expect(find.byKey(const ValueKey('trip-search')), findsOneWidget);
    },
  );
  testWidgets(
    'Acknowledge requires confirmation and produces all A03.2 events',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openLive(tester);
      await action(tester, 'acknowledge-incident');
      expect(find.text('Acknowledge incident?'), findsOneWidget);
      expect(find.textContaining('does not place a call'), findsOneWidget);
      expect(controller(tester).selectedIncident.status, IncidentStatus.open);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller(tester).selectedIncident.events, hasLength(1));
      await acknowledge(tester);
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);
      for (final text in [
        'Acknowledged by Shehani K. · called driver',
        'Standby van WP KA–2210 dispatched · ETA 9 min',
        '11 parents notified of delay',
        'Standby dispatched',
        'Parents notified',
        'Mark resolved',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Parents notified'));
      await tester.tap(find.text('Parents notified'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No notifications or messages were sent'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('acknowledge-incident')), findsNothing);
    },
  );
  testWidgets('Resolve validates note, confirms outcome and matches A03.3', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openLive(tester);
    await acknowledge(tester);
    await action(tester, 'resolve-incident');
    await tester.enterText(find.byKey(const ValueKey('resolution-note')), ' ');
    await action(tester, 'confirm-incident-action');
    expect(find.text('Add a resolution note.'), findsOneWidget);
    expect(
      controller(tester).selectedIncident.status,
      IncidentStatus.acknowledged,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await action(tester, 'resolve-incident');
    await action(tester, 'confirm-incident-action');
    expect(find.text('RESOLVED'), findsOneWidget);
    expect(find.text('Resolved · students at school'), findsOneWidget);
    expect(
      find.text(
        'Resolved · all 11 students reached school on standby van WP KA–2210.',
      ),
      findsOneWidget,
    );
    expect(find.text('SOS 0'), findsOneWidget);
    expect(find.text('Completed 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdminSidebar),
        matching: find.text('SOS 1'),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('resolve-incident')), findsNothing);
    expect(controller(tester).runningCount, 17);
  });
  testWidgets(
    'Map markers show snapshots, select incidents and support zoom controls',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openLive(tester);
      await action(tester, 'map-trip-dilshan');
      expect(find.text('Mock trip snapshot'), findsOneWidget);
      expect(find.textContaining('No live GPS connection'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await action(tester, 'map-trip-kumari');
      expect(controller(tester).selectedIncident.id, 'INC-2026-0081');
      expect(find.text('Route delay · Previous demo incident'), findsOneWidget);
      await action(tester, 'map-trip-ruwan');
      expect(controller(tester).selectedIncident.id, 'INC-2026-0087');
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!
            .value
            .getMaxScaleOnAxis(),
        1.25,
      );
      await tester.tap(find.byTooltip('Reset map view'));
      await tester.pump();
      expect(
        tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!
            .value
            .getMaxScaleOnAxis(),
        1,
      );
    },
  );
  testWidgets('Search, filtering, sorting, pagination and local refresh work', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openLive(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('trip-search')));
    await tester.enterText(find.byKey(const ValueKey('trip-search')), 'KUMARI');
    await tester.pumpAndSettle();
    expect(controller(tester).filteredTrips.single.id, 'kumari');
    await tester.enterText(
      find.byKey(const ValueKey('trip-search')),
      'no matches',
    );
    await tester.pumpAndSettle();
    expect(find.text('No trips match your search or filters.'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Next trips'));
    await tester.tap(find.byTooltip('Next trips'));
    await tester.pumpAndSettle();
    expect(controller(tester).page, 1);
    final heading = find.descendant(
      of: find.byType(DataTable),
      matching: find.text('Driver'),
    );
    await tester.ensureVisible(heading);
    await tester.tap(heading);
    await tester.pumpAndSettle();
    expect(controller(tester).pageTrips.first.driver, 'Amila Fernando');
    final previousRefreshCount = controller(tester).refreshCount;
    await tester.ensureVisible(find.byTooltip('Refresh mock snapshot'));
    await tester.tap(find.byTooltip('Refresh mock snapshot'));
    await tester.pumpAndSettle();
    expect(controller(tester).refreshCount, previousRefreshCount + 1);
    await tester.tap(find.byKey(const ValueKey('summary-sos')));
    await tester.pumpAndSettle();
    expect(controller(tester).filteredTrips.single.id, 'ruwan');
    final dropdown = find.byType(DropdownButtonFormField<TripFilter>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GPS stale').last);
    await tester.pumpAndSettle();
    expect(controller(tester).filteredTrips.single.id, 'dilshan');
  });
  testWidgets(
    'Incident picker and sidebar navigation preserve workflow and filter state',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openLive(tester);
      await acknowledge(tester);
      await tester.ensureVisible(find.byTooltip('Select incident'));
      await tester.tap(find.byTooltip('Select incident'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('INC-2026-0079 · resolved'));
      await tester.pumpAndSettle();
      expect(
        find.text('Vehicle check · Previous demo incident'),
        findsOneWidget,
      );
      controller(tester).selectIncident('INC-2026-0087');
      controller(tester).setFilter(TripFilter.sos);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live trips'));
      await tester.pumpAndSettle();
      expect(controller(tester).filter, TripFilter.sos);
      expect(
        controller(tester).selectedIncident.status,
        IncidentStatus.acknowledged,
      );
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);
    },
  );
  testWidgets(
    'Live routes are guarded and the demo incident resets on logout',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openLive(tester);
      controller(tester).acknowledgeIncident('INC-2026-0087');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInView), findsOneWidget);
      final router = GoRouter.of(tester.element(find.byType(SignInView)));
      router.go('${AppRouter.liveTripsPath}/incident');
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRouter.signInPath,
      );
      tester
          .element(find.byType(SignInView))
          .read<DemoSessionController>()
          .startSession(persistent: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live trips'));
      await tester.pumpAndSettle();
      expect(controller(tester).selectedIncident.status, IncidentStatus.open);
    },
  );
  testWidgets(
    'Narrow status filters and incident history remain usable with enlarged text',
    (tester) async {
      viewport(tester, const Size(320, 700), scale: 1.5);
      await openLive(tester);
      await tester.tap(find.byTooltip('Trip status filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('summary-gpsStale')).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(controller(tester).filteredTrips.single.id, 'dilshan');
      await tester.ensureVisible(find.byTooltip('Select incident'));
      await tester.tap(find.byTooltip('Select incident'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('INC-2026-0081 · resolved'));
      await tester.pumpAndSettle();
      expect(controller(tester).selectedIncident.id, 'INC-2026-0081');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Ten-second mock refresh stops when navigating away', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openLive(tester);
    final c = controller(tester);
    expect(c.refreshCount, 0);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(c.refreshCount, 1);
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 20));
    expect(c.refreshCount, 1);
  });

  for (final size in [
    const Size(1440, 1000),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 700),
    const Size(320, 650),
  ]) {
    testWidgets('Live trips and incident actions fit at $size', (tester) async {
      viewport(tester, size, scale: size.width < 800 ? 1.5 : 1);
      await openLive(tester);
      await acknowledge(tester);
      await action(tester, 'resolve-incident');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('trip-search')));
      await tester.enterText(find.byKey(const ValueKey('trip-search')), 'none');
      await tester.pumpAndSettle();
      expect(
        find.text('No trips match your search or filters.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
