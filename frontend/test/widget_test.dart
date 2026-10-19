import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/features/dashboard/widgets/summary_card.dart';

void main() {
  testWidgets('Root redirects to dashboard and Provider updates metrics', (
    tester,
  ) async {
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    expect(find.text('Admin overview'), findsOneWidget);
    expect(find.text('Morning session'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    await tester.tap(find.text('Switch mock session'));
    await tester.pump();
    expect(find.text('Afternoon session'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('24'), findsNothing);
    await tester.tap(find.text('Switch mock session'));
    await tester.pump();
    expect(find.text('Morning session'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
  });

  testWidgets('Direct dashboard route and unknown route recovery work', (
    tester,
  ) async {
    final router = AppRouter.create(initialLocation: AppRouter.dashboardPath);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Admin overview'), findsOneWidget);
    router.go('/missing');
    await tester.pumpAndSettle();
    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go to dashboard'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRouter.dashboardPath,
    );
    expect(find.text('Admin overview'), findsOneWidget);
  });

  for (final width in [1440.0, 1024.0, 768.0, 375.0]) {
    testWidgets('Dashboard adapts to $width pixel viewport', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const NovaSysApp());
      await tester.pumpAndSettle();
      expect(find.byType(SummaryCard), findsNWidgets(3));
      final first = tester.getTopLeft(find.byType(SummaryCard).at(0));
      final last = tester.getTopLeft(find.byType(SummaryCard).at(2));
      if (width >= 1440) {
        expect(last.dy, first.dy);
        expect(last.dx, greaterThan(first.dx));
      } else {
        expect(last.dy, greaterThan(first.dy));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
