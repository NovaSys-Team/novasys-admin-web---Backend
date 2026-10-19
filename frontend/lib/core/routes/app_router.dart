import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/auth/controllers/demo_session_controller.dart';
import '../../features/auth/controllers/sign_in_controller.dart';
import '../../features/auth/views/sign_in_view.dart';
import '../../shared/widgets/admin_shell.dart';
import '../constants/admin_navigation.dart';

abstract final class AppRouter {
  static const dashboardPath = AdminNavigation.dashboardPath;
  static const dashboardName = 'dashboard';
  static const signInPath = '/sign-in';
  static const signInName = 'sign-in';

  static GoRouter create({
    required DemoSessionController session,
    String? initialLocation,
  }) => GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      final protected =
          path == dashboardPath || path.startsWith('$dashboardPath/');
      if (path == '/') return session.isSignedIn ? dashboardPath : signInPath;
      if (!session.isSignedIn && protected) return signInPath;
      if (session.isSignedIn && path == signInPath) return dashboardPath;
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => signInPath),
      GoRoute(
        path: signInPath,
        name: signInName,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SignInController(session: session),
          child: const SignInView(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: dashboardPath,
            name: dashboardName,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => DashboardController(),
              child: const DashboardView(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Page not found'),
            TextButton(
              onPressed: () => context.goNamed(dashboardName),
              child: const Text('Go to dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
