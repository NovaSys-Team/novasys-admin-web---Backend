import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/app.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';

DemoSessionController authenticatedSession() {
  final session = DemoSessionController(
    store: MemoryDemoSessionStore(active: true),
  );
  addTearDown(session.dispose);
  return session;
}

NovaSysApp authenticatedApp() => NovaSysApp(session: authenticatedSession());
