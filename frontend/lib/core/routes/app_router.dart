import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';

abstract final class AppRouter {
  static const dashboardPath = '/dashboard';
  static const dashboardName = 'dashboard';

  static GoRouter create({String? initialLocation}) => GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => dashboardPath),
      GoRoute(
        path: dashboardPath,
        name: dashboardName,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => DashboardController(),
          child: const DashboardView(),
        ),
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
