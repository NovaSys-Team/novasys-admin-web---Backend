import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/auth/controllers/demo_session_controller.dart';
import '../../features/auth/controllers/sign_in_controller.dart';
import '../../features/auth/views/sign_in_view.dart';
import '../../features/driver_verification/controllers/driver_verification_controller.dart';
import '../../features/driver_verification/views/driver_verification_view.dart';
import '../../features/driver_verification/widgets/verification_filters_button.dart';
import '../../features/live_trips/controllers/live_trips_controller.dart';
import '../../features/live_trips/views/live_trips_view.dart';
import '../../features/live_trips/widgets/live_trip_summary.dart';
import '../../features/payments/controllers/payments_controller.dart';
import '../../features/payments/views/payments_view.dart';
import '../../features/payments/widgets/payment_styles.dart';
import '../../shared/widgets/admin_shell.dart';
import '../constants/admin_navigation.dart';

abstract final class AppRouter {
  static const dashboardPath = AdminNavigation.dashboardPath;
  static const dashboardName = 'dashboard';
  static const signInPath = '/sign-in';
  static const signInName = 'sign-in';
  static const verificationPath = AdminNavigation.verificationPath;
  static const verificationName = 'driver-verification';
  static const liveTripsPath = AdminNavigation.liveTripsPath;
  static const liveTripsName = 'live-trips';
  static const paymentsPath = AdminNavigation.paymentsPath;
  static const settlementsPath = AdminNavigation.settlementsPath;
  static const paymentsName = 'payments';
  static const settlementsName = 'driver-settlements';

  static GoRouter create({
    required DemoSessionController session,
    String? initialLocation,
  }) => GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      final protected =
          path == dashboardPath ||
          path.startsWith('$dashboardPath/') ||
          path == verificationPath ||
          path.startsWith('$verificationPath/') ||
          path == liveTripsPath ||
          path.startsWith('$liveTripsPath/') ||
          path == paymentsPath ||
          path.startsWith('$paymentsPath/');
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
        builder: (context, state, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DriverVerificationController(),
            ),
            ChangeNotifierProvider(create: (_) => LiveTripsController()),
            ChangeNotifierProvider(create: (_) => PaymentsController()),
          ],
          child: Consumer2<DriverVerificationController, LiveTripsController>(
            builder: (context, verification, live, _) {
              final reviewing = state.uri.path == verificationPath;
              final watching = state.uri.path == liveTripsPath;
              final paying =
                  state.uri.path == paymentsPath ||
                  state.uri.path.startsWith('$paymentsPath/');
              return AdminShell(
                currentPath: state.uri.path,
                verificationCount: verification.pendingCount,
                liveIncidentCount: live.activeIncidentCount,
                title: reviewing
                    ? DriverVerificationView.title
                    : watching
                    ? LiveTripsView.title
                    : paying
                    ? PaymentsView.title
                    : null,
                subtitle: reviewing
                    ? DriverVerificationView.subtitle
                    : watching
                    ? live.subtitle
                    : paying
                    ? PaymentsView.subtitle
                    : null,
                headerActions: reviewing
                    ? const VerificationFiltersButton()
                    : watching
                    ? const LiveTripsHeaderActions()
                    : paying
                    ? const PaymentsHeaderBadge()
                    : null,
                child: child,
              );
            },
          ),
        ),
        routes: [
          GoRoute(
            path: paymentsPath,
            name: paymentsName,
            builder: (context, state) => const PaymentsView(),
            routes: [
              GoRoute(
                path: 'settlements',
                name: settlementsName,
                builder: (context, state) =>
                    const PaymentsView(settlements: true),
              ),
            ],
          ),
          GoRoute(
            path: liveTripsPath,
            name: liveTripsName,
            builder: (context, state) => const LiveTripsView(),
          ),
          GoRoute(
            path: verificationPath,
            name: verificationName,
            builder: (context, state) => const DriverVerificationView(),
          ),
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
