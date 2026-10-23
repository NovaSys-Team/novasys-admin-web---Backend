import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:novasys_admin_web/features/students/views/students_view.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';

import 'support/test_app.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/students');
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Students sidebar navigates and signed-out deep links are protected',
    (tester) async {
      final session = DemoSessionController(store: MemoryDemoSessionStore());
      final router = AppRouter.create(
        session: session,
        initialLocation: '/students',
      );
      addTearDown(session.dispose);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/sign-in');
      await open(tester);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/dashboard');
      await tester.pumpAndSettle();
      await tap(tester, find.text('Students'));
      expect(find.byType(StudentsView), findsOneWidget);
    },
  );
  testWidgets(
    'vehicle preview requires vehicle and date and preserves assignment',
    (tester) async {
      await open(tester);
      await tap(tester, find.text('Change vehicle'));
      await tap(tester, find.byType(DropdownButtonFormField<String>));
      await tap(tester, find.text('WP NB–7731 · Kumari W.').last);
      await tap(tester, find.text('Choose start date'));
      await tap(tester, find.text('OK'));
      await tap(tester, find.text('Preview change'));
      expect(find.textContaining('Assignment unchanged.'), findsOneWidget);
      expect(find.text('WP PH–4521 · Toyota HiAce'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders A08 and selects independent student details', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(StudentsView), findsOneWidget);
    expect(find.text('Nadeesha Perera'), findsOneWidget);
    expect(find.text('Peanut allergy'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('student-s5')));
    expect(find.text('Saman Bandara'), findsOneWidget);
    expect(find.text('WP CAB–1190 · Toyota Coaster'), findsOneWidget);
    await tap(tester, find.text('Track'));
    expect(find.text('Track · Hiruni Bandara'), findsOneWidget);
    expect(
      find.text('Mock trip snapshot · no live location feed.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'search, school, fee and no-vehicle filters update list and empty state',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('students-filter-feesDue')));
      expect(find.byKey(const ValueKey('student-s1')), findsNothing);
      expect(find.byKey(const ValueKey('student-s3')), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('students-school')));
      await tap(tester, find.text('Visakha').last);
      expect(find.byKey(const ValueKey('student-s3')), findsNothing);
      expect(find.byKey(const ValueKey('student-s4')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('students-search')),
        'Nobody',
      );
      await tester.pumpAndSettle();
      expect(find.text('No students found'), findsOneWidget);
      await tap(tester, find.text('Clear filters'));
      expect(find.byKey(const ValueKey('student-s1')), findsOneWidget);
      await tap(
        tester,
        find.byKey(const ValueKey('students-filter-noVehicle')),
      );
      expect(find.text('Shanika Fernando'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Track'),
            )
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets('mock dialogs validate input and export filtered records', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.text('Change vehicle'));
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preview change'),
          )
          .onPressed,
      isNull,
    );
    await tap(tester, find.text('Cancel'));
    await tap(tester, find.text('Message parent'));
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preview message'),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Message'),
      'Please call me',
    );
    await tester.pumpAndSettle();
    await tap(tester, find.text('Preview message'));
    expect(find.textContaining('Nothing sent.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('students-search')),
      'Sanuli',
    );
    await tester.pumpAndSettle();
    await tap(tester, find.text('Export list'));
    expect(
      find.text('1 mock student records · current search and filters'),
      findsOneWidget,
    );
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(1100, 800),
    const Size(700, 900),
    const Size(390, 844),
  ]) {
    testWidgets('responsive layout avoids overflow at ${size.width}', (
      tester,
    ) async {
      await open(tester, size: size);
      expect(find.byType(StudentsView), findsOneWidget);
      await tap(tester, find.text('Message parent'));
      expect(
        find.text('Local demo only. No message will be sent.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
