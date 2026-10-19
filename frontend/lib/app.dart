import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class NovaSysApp extends StatefulWidget {
  const NovaSysApp({super.key});
  @override
  State<NovaSysApp> createState() => _NovaSysAppState();
}

class _NovaSysAppState extends State<NovaSysApp> {
  late final GoRouter _router = AppRouter.create();
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'NovaSys Admin',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: _router,
  );
}
