import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/reports/controllers/reports_controller.dart';
import 'package:novasys_admin_web/features/reports/models/report.dart';
import 'package:novasys_admin_web/features/reports/views/reports_view.dart';

import 'support/test_app.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/reports');
    await tester.pumpAndSettle();
  }

  ReportsController controller(WidgetTester tester) =>
      tester.element(find.byType(ReportsView)).read<ReportsController>();
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'A09 shows six report choices, date controls and original history',
    (tester) async {
      await open(tester);
      for (final type in ReportType.values) {
        expect(find.text(type.description), findsOneWidget);
        expect(
          find.byKey(ValueKey('report-type-${type.name}')),
          findsOneWidget,
        );
      }
      expect(find.text('1 Oct 2026'), findsOneWidget);
      expect(find.text('19 Oct 2026'), findsOneWidget);
      expect(find.text('Sep 2026'), findsNWidgets(2));
      expect(find.text('Term 3'), findsOneWidget);
      expect(find.text('28 Sep · Kavindu H.'), findsOneWidget);
      expect(find.text('Download'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'switching reports and school changes generated snapshot and format',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('report-type-trips')));
      await tap(tester, find.byKey(const ValueKey('report-school')));
      await tap(tester, find.text('Royal').last);
      await tap(tester, find.byKey(const ValueKey('report-format-csv')));
      expect(find.text('Generate CSV'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('generate-report')));
      final report = controller(tester).history.first;
      expect(report.type, ReportType.trips);
      expect(report.school, 'Royal');
      expect(report.format, ReportFormat.csv);
      expect(report.rows.length, 13);
      expect(
        find.textContaining('13 records. Ready to download.'),
        findsOneWidget,
      );
      await tap(tester, find.byKey(ValueKey('report-download-${report.id}')));
      expect(find.textContaining('Mock CSV prepared'), findsOneWidget);
    },
  );
  testWidgets(
    'date picker cancel preserves state; invalid dates block generation',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('report-from')));
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).from, DateTime(2026, 10, 1));
      await tap(tester, find.byKey(const ValueKey('report-from')));
      await tap(tester, find.text('20').last);
      await tap(tester, find.text('OK'));
      expect(
        find.text('From date must be on or before To date.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('generate-report')))
            .onPressed,
        isNull,
      );
      await tap(tester, find.byKey(const ValueKey('report-to')));
      await tap(tester, find.text('21').last);
      await tap(tester, find.text('OK'));
      await tap(tester, find.byKey(const ValueKey('generate-report')));
      expect(
        find.textContaining('No mock data for this report'),
        findsOneWidget,
      );
      expect(controller(tester).history.length, 3);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'sidebar navigation retains report filters and deep links require a session',
    (tester) async {
      final session = DemoSessionController(store: MemoryDemoSessionStore());
      final router = AppRouter.create(
        session: session,
        initialLocation: '/reports',
      );
      addTearDown(session.dispose);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/sign-in');
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('report-type-drivers')));
      await tap(tester, find.text('Students'));
      await tap(tester, find.text('Reports'));
      expect(controller(tester).type, ReportType.drivers);
      expect(find.byType(ReportsView), findsOneWidget);
    },
  );
  for (final size in [
    const Size(1280, 800),
    const Size(1024, 800),
    const Size(768, 900),
    const Size(390, 844),
    const Size(320, 700),
  ]) {
    testWidgets(
      'report controls and generation fit ${size.width} with enlarged text',
      (tester) async {
        await open(tester, size: size, scale: size.width < 800 ? 1.5 : 1);
        await tap(tester, find.byKey(const ValueKey('report-type-incidents')));
        await tap(tester, find.byKey(const ValueKey('report-format-excel')));
        await tap(tester, find.byKey(const ValueKey('generate-report')));
        expect(controller(tester).history.first.type, ReportType.incidents);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
