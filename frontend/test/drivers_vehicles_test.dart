import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/controllers/drivers_vehicles_controller.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/models/driver_vehicle.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/views/drivers_vehicles_view.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';

import 'support/test_app.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1440, 1066),
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
        .go('/drivers-vehicles');
    await tester.pumpAndSettle();
  }

  DriversVehiclesController controller(WidgetTester t) => t
      .element(find.byType(DriversVehiclesView))
      .read<DriversVehiclesController>();
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('A06 sections, five rows, selected vehicle and details actions', (
    tester,
  ) async {
    await open(tester);
    expect(
      find.text('42 verified drivers · 3 standby · compliance checked daily'),
      findsOneWidget,
    );
    expect(find.text('Substitute needed · Fri 23 Oct'), findsOneWidget);
    expect(find.text('NEEDS ASSIGNMENT'), findsOneWidget);
    expect(find.text('Toyota HiAce'), findsOneWidget);
    expect(find.text('LKR 1,200/km'), findsOneWidget);
    expect(find.text('Visakha, Royal, St. Bridget’s'), findsOneWidget);
    expect(find.text('Suspend'), findsNWidgets(4));
    expect(find.text('Reinstate'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('driver-DV-002')));
    expect(find.byKey(const ValueKey('fleet-details-DV-002')), findsOneWidget);
    await tap(tester, find.text('Documents'));
    expect(find.text('Documents · Kumari Wickramasinghe'), findsOneWidget);
    await tap(tester, find.text('Close'));
    await tap(tester, find.text('View students'));
    expect(find.text('24 students assigned · mock roster'), findsOneWidget);
    await tap(tester, find.text('Close'));
    await tap(tester, find.byKey(const ValueKey('vehicle-DV-002')));
    expect(find.text('Vehicle · WP NB-7731'), findsOneWidget);
    await tap(tester, find.text('Close'));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'suspension validates a reason and confirms; cancellation preserves state',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('status-action-DV-001')));
      await tap(tester, find.byKey(const ValueKey('fleet-confirm-action')));
      expect(find.text('Reason is required.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('fleet-action-text')),
        'Safety review',
      );
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).selected.status, DriverStatus.verified);
      await tap(tester, find.byKey(const ValueKey('status-action-DV-001')));
      await tester.enterText(
        find.byKey(const ValueKey('fleet-action-text')),
        'Safety review',
      );
      await tap(tester, find.byKey(const ValueKey('fleet-confirm-action')));
      expect(controller(tester).selected.status, DriverStatus.suspended);
      expect(controller(tester).activity.last.reason, 'Safety review');
      await tap(tester, find.byKey(const ValueKey('status-action-DV-001')));
      await tester.enterText(
        find.byKey(const ValueKey('fleet-action-text')),
        'Reviewed',
      );
      await tap(tester, find.byKey(const ValueKey('fleet-confirm-action')));
      expect(controller(tester).selected.status, DriverStatus.verified);
    },
  );
  testWidgets('substitute eligibility, confirmation and mock messaging', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('substitute-Nimal Silva')));
    expect(find.text('Confirm assignment'), findsNothing);
    await tap(tester, find.text('Close'));
    await tap(
      tester,
      find.byKey(const ValueKey('substitute-Tharindu Rajapaksha')),
    );
    await tap(tester, find.text('Cancel'));
    expect(controller(tester).assignedSubstitute, isNull);
    await tap(
      tester,
      find.byKey(const ValueKey('substitute-Tharindu Rajapaksha')),
    );
    await tap(tester, find.byKey(const ValueKey('fleet-confirm-substitute')));
    expect(find.text('ASSIGNED'), findsOneWidget);
    await tap(tester, find.text('Message driver'));
    await tester.enterText(
      find.byKey(const ValueKey('fleet-action-text')),
      'Demo pickup reminder',
    );
    await tap(tester, find.byKey(const ValueKey('fleet-confirm-action')));
    expect(controller(tester).activity.last.action, 'Mock message');
  });
  testWidgets(
    'search, combined filters, empty state, clearing and navigation persistence',
    (tester) async {
      await open(tester);
      await tap(tester, find.byTooltip('Search & filter drivers'));
      await tester.enterText(
        find.byKey(const ValueKey('fleet-search')),
        'HiAce',
      );
      await tester.pumpAndSettle();
      expect(controller(tester).filteredRecords, hasLength(2));
      await tap(tester, find.byType(DropdownButtonFormField<ComplianceLevel>));
      await tap(tester, find.text('Expired / under 14 days').last);
      expect(controller(tester).filteredRecords.single.name, 'Asanka Perera');
      await tap(tester, find.byType(DropdownButtonFormField<DriverStatus>));
      await tap(tester, find.text('SUSPENDED').last);
      expect(find.text('No matching drivers or vehicles.'), findsOneWidget);
      await tap(tester, find.text('Clear filters').first);
      expect(controller(tester).filteredRecords, hasLength(5));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('fleet-search')))
            .controller!
            .text,
        isEmpty,
      );
      final c = controller(tester);
      c.select('DV-002');
      await tester.pumpAndSettle();
      await tap(tester, find.text('Overview'));
      await tap(tester, find.text('Drivers & vehicles'));
      expect(identical(c, controller(tester)), true);
      expect(controller(tester).selectedId, 'DV-002');
    },
  );
  testWidgets(
    'add vehicle validates input, duplicate plate and creates pending mock record',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('fleet-add-vehicle')));
      await tap(tester, find.byKey(const ValueKey('fleet-add-confirm')));
      expect(find.text('Driver name is required.'), findsOneWidget);
      for (final field in {
        'name': 'Demo Driver',
        'plate': 'WP PH-4521',
        'model': 'Toyota HiAce',
        'year': '2021',
        'seats': '14',
        'price': '1200',
      }.entries) {
        final finder = find.byKey(ValueKey('add-vehicle-${field.key}'));
        await tester.ensureVisible(finder);
        await tester.enterText(finder, field.value);
      }
      await tap(tester, find.byKey(const ValueKey('fleet-add-confirm')));
      expect(
        find.text('A vehicle with this plate already exists.'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('add-vehicle-plate')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('add-vehicle-plate')),
        'WP XX-1234',
      );
      await tap(tester, find.byKey(const ValueKey('fleet-add-confirm')));
      expect(controller(tester).records, hasLength(6));
      expect(controller(tester).selected.status, DriverStatus.pending);
      expect(
        find.text('Mock vehicle added. Pending document verification.'),
        findsOneWidget,
      );
    },
  );
  testWidgets('protected fleet routes and logout reset local changes', (
    tester,
  ) async {
    await open(tester);
    controller(tester)
        .changeStatus('DV-001', DriverStatus.verified, 'Demo reason');
    await tester.pumpAndSettle();
    final router = GoRouter.of(
      tester.element(find.byType(DriversVehiclesView)),
    );
    await tap(tester, find.text('Sign out'));
    for (final path in ['/drivers-vehicles', '/drivers-vehicles/unknown']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(SignInView), findsOneWidget);
    }
    tester
        .element(find.byType(SignInView))
        .read<DemoSessionController>()
        .startSession(persistent: false);
    await tester.pumpAndSettle();
    router.go('/drivers-vehicles');
    await tester.pumpAndSettle();
    expect(controller(tester).selected.status, DriverStatus.verified);
    expect(controller(tester).activity, isEmpty);
  });
  for (final size in [
    const Size(1440, 1066),
    const Size(1280, 800),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 800),
    const Size(320, 700),
  ]) {
    testWidgets('fleet layout, filters and dialogs fit $size', (tester) async {
      await open(tester, size: size);
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Documents'));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Close'));
      await tap(tester, find.text('Message driver'));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Cancel'));
      await tap(tester, find.byTooltip('Search & filter drivers').first);
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const ValueKey('fleet-add-vehicle')).first);
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Cancel'));
    });
  }
}
