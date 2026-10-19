import 'package:flutter/foundation.dart';

import '../models/demo_credentials.dart';
import 'demo_session_controller.dart';

class SignInController extends ChangeNotifier {
  SignInController({
    required this._session,
    this._simulatedDelay = const Duration(milliseconds: 650),
  });
  final DemoSessionController _session;
  final Duration _simulatedDelay;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _keepSignedIn = false;
  bool _disposed = false;
  String? _error;
  bool get isLoading => _isLoading;
  bool get passwordVisible => _passwordVisible;
  bool get keepSignedIn => _keepSignedIn;
  String? get error => _error;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void setKeepSignedIn(bool value) {
    if (_isLoading) return;
    _keepSignedIn = value;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    if (_isLoading || _disposed) return;
    _error =
        DemoCredentials.validateEmail(email) ??
        DemoCredentials.validatePassword(password);
    if (_error != null) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(_simulatedDelay);
    if (_disposed) return;
    if (!DemoCredentials.matches(email, password)) {
      _error = 'These credentials do not match the demo account. Use the demo credentials below.';
    } else {
      try {
        _session.startSession(persistent: _keepSignedIn);
      } catch (_) {
        _error = 'Your browser could not save the demo session. Allow site storage and try again.';
      }
    }
    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
