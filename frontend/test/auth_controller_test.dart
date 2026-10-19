import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/core/services/demo_session_store.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/controllers/sign_in_controller.dart';
import 'package:novasys_admin_web/features/auth/models/demo_credentials.dart';

class _BlockedStore extends MemoryDemoSessionStore {
  @override
  void save({required bool persistent}) => throw StateError('Blocked storage');
}

void main() {
  test(
    'Blocked browser storage reports a helpful error without a session',
    () async {
      final session = DemoSessionController(store: _BlockedStore());
      final controller = SignInController(
        session: session,
        simulatedDelay: Duration.zero,
      );
      addTearDown(controller.dispose);
      addTearDown(session.dispose);
      await controller.signIn(DemoCredentials.email, DemoCredentials.password);
      expect(controller.error, contains('Allow site storage'));
      expect(controller.isLoading, isFalse);
      expect(session.isSignedIn, isFalse);
    },
  );

  test('Leaving sign-in while its simulated request is pending does not start a session', () async {
    final session = DemoSessionController(store: MemoryDemoSessionStore());
    addTearDown(session.dispose);
    final controller = SignInController(
      session: session,
      simulatedDelay: Duration.zero,
    );
    final pending = controller.signIn(
      DemoCredentials.email,
      DemoCredentials.password,
    );
    controller.dispose();
    await pending;
    expect(session.isSignedIn, isFalse);
  });

  test(
    'Only the public demo email is normalized; passwords remain exact',
    () async {
      final session = DemoSessionController(store: MemoryDemoSessionStore());
      final controller = SignInController(
        session: session,
        simulatedDelay: Duration.zero,
      );
      addTearDown(controller.dispose);
      addTearDown(session.dispose);
      await controller.signIn(
        ' ADMIN@NOVASYS.EXAMPLE ',
        '${DemoCredentials.password} ',
      );
      expect(session.isSignedIn, isFalse);
      await controller.signIn(
        ' ADMIN@NOVASYS.EXAMPLE ',
        DemoCredentials.password,
      );
      expect(session.isSignedIn, isTrue);
    },
  );
}
