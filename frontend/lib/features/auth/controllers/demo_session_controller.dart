import 'package:flutter/foundation.dart';

import '../../../core/services/demo_session_store.dart';

/// Frontend routing state only. This is not an authentication boundary.
class DemoSessionController extends ChangeNotifier {
  DemoSessionController({required this._store}) {
    try {
      _isSignedIn = _store.hasSession;
    } catch (_) {
      _isSignedIn = false;
    }
  }
  final DemoSessionStore _store;
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  void startSession({required bool persistent}) {
    _store.save(persistent: persistent);
    _isSignedIn = true;
    notifyListeners();
  }

  void signOut() {
    try {
      _store.clear();
    } catch (_) {
      // Always end the in-memory session, even if browser storage is blocked.
    }
    _isSignedIn = false;
    notifyListeners();
  }
}
