import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/models/demo_credentials.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';
import 'package:novasys_admin_web/shared/widgets/admin_sidebar.dart';

void main() {
  final email = find.descendant(
    of: find.byKey(const ValueKey('email-field')),
    matching: find.byType(TextFormField),
  );
  final password = find.descendant(
    of: find.byKey(const ValueKey('password-field')),
    matching: find.byType(TextFormField),
  );
  final submit = find.byKey(const ValueKey('sign-in-button'));
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<DemoSessionController> openLogin(
    WidgetTester tester, {
    MemoryDemoSessionStore? store,
  }) async {
    final session = DemoSessionController(
      store: store ?? MemoryDemoSessionStore(),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      NovaSysApp(key: ValueKey(session), session: session),
    );
    await tester.pumpAndSettle();
    return session;
  }

  Future<void> useDemo(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Demo credentials'));
    await tester.tap(find.text('Demo credentials'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use demo credentials'));
    await tester.tap(find.text('Use demo credentials'));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Signed-out root shows A00 content, demo disclosure and recovery help',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      await openLogin(tester);
      for (final text in [
        'NovaSys Admin',
        'Every school ride, safe\nand on time.',
        'Staff accounts only',
        'Work email',
        'Password',
        'Keep me signed in',
        'Forgot password?',
        'Demo credentials',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.byType(AdminSidebar), findsNothing);
      expect(find.textContaining('no 6-digit code is sent'), findsOneWidget);
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No email or SMS will be sent'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Email and password validation reject empty and malformed inputs',
    (tester) async {
      final session = await openLogin(tester);
      await signIn(tester);
      expect(find.text('Enter your work email.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      await tester.enterText(email, 'not-an-email');
      await tester.enterText(password, 'short');
      await signIn(tester);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(session.isSignedIn, isFalse);
    },
  );

  testWidgets('Password toggle, loading and wrong demo credentials work', (
    tester,
  ) async {
    final session = await openLogin(tester);
    await tester.enterText(email, DemoCredentials.email);
    await tester.enterText(password, 'WrongPassword!');
    final passwordInput = find.descendant(
      of: find.byKey(const ValueKey('password-field')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(passwordInput).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(passwordInput).obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(tester.widget<TextFormField>(email).enabled, isFalse);
    expect(session.isSignedIn, isFalse);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('do not match the demo account'),
      findsOneWidget,
    );
    expect(session.isSignedIn, isFalse);
    await tester.enterText(password, DemoCredentials.password);
    await tester.pump();
    expect(find.byKey(const ValueKey('sign-in-error')), findsNothing);
  });

  testWidgets(
    'Public demo login navigates to overview; sign out clears session and guards back navigation',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      final store = MemoryDemoSessionStore();
      final session = await openLogin(tester, store: store);
      final router = GoRouter.of(tester.element(find.byType(SignInView)));
      router.go('/dashboard');
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRouter.signInPath,
      );
      router.go('/dashboard/trips');
      await tester.pumpAndSettle();
      expect(find.byType(SignInView), findsOneWidget);
      await useDemo(tester);
      expect(
        tester.widget<TextFormField>(email).controller!.text,
        DemoCredentials.email,
      );
      await signIn(tester);
      expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
      expect(session.isSignedIn, isTrue);
      expect(store.hasSession, isTrue);
      expect(store.persistent, isFalse);
      router.go(AppRouter.signInPath);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRouter.dashboardPath,
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(store.hasSession, isFalse);
      expect(session.isSignedIn, isFalse);
      expect(find.byType(SignInView), findsOneWidget);
      router.go('/dashboard');
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRouter.signInPath,
      );
      expect(find.byType(AdminSidebar), findsNothing);
    },
  );

  testWidgets(
    'Keep me signed in persists marker; reconstructing app restores demo session',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      final store = MemoryDemoSessionStore();
      await openLogin(tester, store: store);
      await useDemo(tester);
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await signIn(tester);
      expect(store.persistent, isTrue);
      // Recreate the app and session with the same storage, as a refresh would.
      await tester.pumpWidget(const SizedBox.shrink());
      await openLogin(tester, store: store);
      expect(find.bySemanticsLabel('Admin overview'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await openLogin(tester, store: store);
      expect(find.byType(SignInView), findsOneWidget);
    },
  );

  testWidgets('Narrow drawer sign out returns to login', (tester) async {
    viewport(tester, const Size(375, 700));
    final session = await openLogin(tester);
    await useDemo(tester);
    await signIn(tester);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(session.isSignedIn, isFalse);
    expect(find.byType(SignInView), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  for (final size in [
    const Size(1440, 900),
    const Size(1024, 700),
    const Size(768, 700),
    const Size(375, 600),
    const Size(320, 480),
    const Size(1440, 400),
  ]) {
    testWidgets('Sign in scrolls without overflow at $size with large text', (
      tester,
    ) async {
      viewport(tester, size);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openLogin(tester);
      await useDemo(tester);
      await tester.ensureVisible(submit);
      expect(submit.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
