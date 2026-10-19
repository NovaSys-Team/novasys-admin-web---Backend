/// Public sample values; these are not real account credentials.
abstract final class DemoCredentials {
  static const email = 'admin@novasys.example';
  static const password = 'NovaSysDemo!';

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your work email.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 8) return 'Use at least 8 characters.';
    return null;
  }

  static bool matches(String email, String password) =>
      email.trim().toLowerCase() == DemoCredentials.email &&
      password == DemoCredentials.password;
}
