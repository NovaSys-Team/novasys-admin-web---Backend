import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/demo_session_store_factory.dart';
import 'features/auth/controllers/demo_session_controller.dart';

class NovaSysApp extends StatefulWidget {
  const NovaSysApp({super.key, this.session});
  final DemoSessionController? session;
  @override
  State<NovaSysApp> createState() => _NovaSysAppState();
}

class _NovaSysAppState extends State<NovaSysApp> {
  late final DemoSessionController _session =
      widget.session ?? DemoSessionController(store: createDemoSessionStore());
  late final GoRouter _router = AppRouter.create(session: _session);
  @override
  void dispose() {
    _router.dispose();
    if (widget.session == null) _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _session,
    child: MaterialApp.router(
      title: 'NovaSys Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    ),
  );
}
