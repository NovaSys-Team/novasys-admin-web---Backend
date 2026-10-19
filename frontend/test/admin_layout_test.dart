import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/constants/admin_navigation.dart';
import 'package:novasys_admin_web/core/theme/design_tokens.dart';
import 'package:novasys_admin_web/shared/widgets/admin_header.dart';
import 'package:novasys_admin_web/shared/widgets/admin_sidebar.dart';

void main() {
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Desktop shell shows selected navigation and mock header', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    expect(find.byType(AdminSidebar), findsOneWidget);
    expect(
      tester.getSize(find.byType(AdminSidebar)).width,
      DesignTokens.sidebarWidth,
    );
    expect(find.byType(AdminHeader), findsOneWidget);
    expect(find.text('Good morning, Shehani'), findsOneWidget);
    expect(find.byTooltip('Open navigation'), findsNothing);
    for (final destination in AdminNavigation.destinations) {
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, destination.label),
      );
      expect(button.onPressed != null, destination.path != null);
    }
    final overview = find.widgetWithText(TextButton, 'Overview');
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('admin-navigation-0')))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(overview);
    await tester.pumpAndSettle();
    expect(find.text('Admin overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Narrow drawer navigates, closes and preserves dashboard state', (
    tester,
  ) async {
    viewport(tester, const Size(375, 700));
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch mock session'));
    await tester.pump();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.text('NovaSys'), findsOneWidget);
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(find.text('NovaSys'), findsNothing);
    expect(find.text('Afternoon session'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shell handles resizing, short windows and enlarged text', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    await tester.pumpWidget(const NovaSysApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch mock session'));
    await tester.pump();
    tester.view.physicalSize = const Size(375, 600);
    await tester.pumpAndSettle();
    expect(find.text('Afternoon session'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Routes & calendar').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: const NovaSysApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
