import 'package:web/web.dart' as web;

import 'demo_session_store.dart';

DemoSessionStore createDemoSessionStore() => _BrowserDemoSessionStore();

class _BrowserDemoSessionStore implements DemoSessionStore {
  static const _key = 'novasys.demo-session.v1';
  static const _marker = 'active';
  @override
  bool get hasSession {
    // A blocked storage area must not prevent checking the other area.
    return _read(persistent: false) || _read(persistent: true);
  }

  bool _read({required bool persistent}) {
    try {
      final storage = persistent
          ? web.window.localStorage
          : web.window.sessionStorage;
      return storage.getItem(_key) == _marker;
    } catch (_) {
      return false;
    }
  }

  @override
  void save({required bool persistent}) {
    // Remove the previous scope before starting a new demo session.
    clear();
    final storage = persistent
        ? web.window.localStorage
        : web.window.sessionStorage;
    storage.setItem(_key, _marker);
  }

  @override
  void clear() {
    Object? failure;
    for (final persistent in [false, true]) {
      try {
        final storage = persistent
            ? web.window.localStorage
            : web.window.sessionStorage;
        storage.removeItem(_key);
      } catch (error) {
        failure = error;
      }
    }
    if (failure != null) throw StateError('Browser storage is unavailable');
  }
}
