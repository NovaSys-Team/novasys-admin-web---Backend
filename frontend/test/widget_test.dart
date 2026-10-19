import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/features/dashboard/widgets/summary_card.dart';

void main() {
  void size(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Overview contains every reference section and mock incident', (
    tester,
  ) async {
    size(tester, 1440);
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
    expect(find.byType(SummaryCard), findsNWidgets(6));
    for (final label in [
      'Trips running now',
      'Students on board',
      'On-time arrivals (7 days)',
      'Pending verifications',
      'October collected',
      'Open support tickets',
      'Students transported per day',
      'Needs attention',
      'Morning trips right now',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    for (final label in [
      'Substitute needed Fri 23 Oct',
      'Documents expiring in 30 days',
      'Driver applications to review',
      'Overdue invoices',
      'Driver change requests',
      'Kumari Wickramasinghe',
      'Dilshan Fernando',
      'Asanka Perera',
      'LKR 195,500 outstanding',
      'Running 6 min late',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Open incident'));
    await tester.pumpAndSettle();
    expect(find.text('SOS · Breakdown'), findsOneWidget);
    expect(find.text('Mock data preview'), findsOneWidget);
    expect(
      find.textContaining('No driver, parent or emergency service'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('October collected'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No payments are processed'), findsOneWidget);
  });

  testWidgets('Chart hover gives exact counts; selection and report work', (
    tester,
  ) async {
    size(tester, 1440);
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    final bar = find.byKey(const ValueKey('transport-bar-0'));
    await tester.ensureVisible(bar);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(bar));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('6 Oct: 452 students'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.tap(bar);
    await tester.pumpAndSettle();
    expect(find.text('6 Oct: 452 students · Mock data'), findsOneWidget);
    await tester.ensureVisible(find.text('Full report'));
    await tester.tap(find.text('Full report'));
    await tester.pumpAndSettle();
    expect(find.text('Students transported report'), findsOneWidget);
    expect(find.text('452'), findsOneWidget);
    expect(find.text('214'), findsNWidgets(2));
  });

  testWidgets('Attention, trip status and map actions show honest details', (
    tester,
  ) async {
    size(tester, 1440);
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overdue invoices'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No payment or collection action'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('GPS stale'));
    await tester.tap(find.text('GPS stale'));
    await tester.pumpAndSettle();
    expect(find.textContaining('GPS snapshot: Last 2 min ago'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Open live map'));
    await tester.tap(find.text('Open live map'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Live GPS is not connected'), findsOneWidget);
  });

  testWidgets('Direct route and unknown route recovery work', (tester) async {
    final router = AppRouter.create(initialLocation: AppRouter.dashboardPath);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
    router.go('/missing');
    await tester.pumpAndSettle();
    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go to dashboard'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRouter.dashboardPath,
    );
    expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
  });

  for (final width in [1440.0, 1024.0, 768.0, 375.0, 320.0]) {
    testWidgets('Complete overview scrolls without overflow at $width', (
      tester,
    ) async {
      size(tester, width);
      await tester.pumpWidget(const NovaSysApp());
      await tester.pumpAndSettle();
      expect(find.byType(SummaryCard), findsNWidgets(6));
      final first = tester.getTopLeft(find.byType(SummaryCard).at(0));
      final sixth = tester.getTopLeft(find.byType(SummaryCard).at(5));
      expect(sixth.dy, greaterThan(first.dy));
      await tester.ensureVisible(find.text('Morning trips right now'));
      await tester.pumpAndSettle();
      expect(
        find.text('Morning trips right now').hitTestable(),
        findsOneWidget,
      );
      final horizontal = find
          .ancestor(
            of: find.byType(DataTable),
            matching: find.byType(SingleChildScrollView),
          )
          .first;
      await tester.drag(horizontal, const Offset(-1100, 0));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Running 6 min late'));
      await tester.pumpAndSettle();
      expect(find.text('Running 6 min late').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
