import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/design_tokens.dart';
import '../controllers/sign_in_controller.dart';
import '../models/demo_credentials.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/demo_credentials_panel.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});
  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = context.read<SignInController>();
    if (controller.isLoading) return;
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      controller.signIn(_email.text, _password.text);
    }
  }

  void _useDemo() {
    _email.text = DemoCredentials.email;
    _password.text = DemoCredentials.password;
    context.read<SignInController>().clearError();
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop =
              constraints.maxWidth >= 1100 &&
              constraints.maxHeight >= 650 &&
              MediaQuery.textScalerOf(context).scale(36) <= 48;
          if (!desktop) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const ColoredBox(
                    color: DesignTokens.sidebar,
                    child: SizedBox(
                      width: double.infinity,
                      child: AuthBrandPanel(compact: true),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildForm(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Stack(
            children: [
              Row(
                children: [
                  Expanded(child: Container(color: DesignTokens.sidebar)),
                  const Expanded(child: SizedBox.expand()),
                ],
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: AuthIllustration()),
                ),
              ),
              Row(
                children: [
                  const Expanded(child: AuthBrandPanel()),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: SizedBox(
                              width: 400,
                              child: _buildForm(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _buildForm(BuildContext context) {
    final controller = context.watch<SignInController>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Staff accounts only',
            style: TextStyle(fontSize: 15, color: DesignTokens.mutedText),
          ),
          const SizedBox(height: 18),
          AuthTextField(
            key: const ValueKey('email-field'),
            label: 'Work email',
            controller: _email,
            hintText: DemoCredentials.email,
            validator: DemoCredentials.validateEmail,
            onChanged: controller.clearError,
            enabled: !controller.isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            key: const ValueKey('password-field'),
            label: 'Password',
            controller: _password,
            hintText: 'Enter your password',
            validator: DemoCredentials.validatePassword,
            onChanged: controller.clearError,
            enabled: !controller.isLoading,
            obscureText: !controller.passwordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            suffixIcon: IconButton(
              tooltip: controller.passwordVisible
                  ? 'Hide password'
                  : 'Show password',
              onPressed: controller.isLoading
                  ? null
                  : controller.togglePasswordVisibility,
              icon: Icon(
                controller.passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 26,
                      height: 36,
                      child: Checkbox(
                        semanticLabel: 'Keep me signed in',
                        value: controller.keepSignedIn,
                        onChanged: controller.isLoading
                            ? null
                            : (value) =>
                                  controller.setKeepSignedIn(value ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Keep me signed in',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4A5D5B),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Demo sign-in only'),
                            content: const Text(
                              'Password recovery is not connected. Use the public demo credentials shown on this page. No email or SMS will be sent.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (controller.error != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                controller.error!,
                key: const ValueKey('sign-in-error'),
                style: const TextStyle(
                  color: DesignTokens.danger,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('sign-in-button'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.standard,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: controller.isLoading ? null : _submit,
              child: controller.isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Signing in…'),
                      ],
                    )
                  : const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 18, color: Color(0xFF0A6A60)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo mode: no 6-digit code is sent and no audit log is recorded.',
                    style: TextStyle(
                      color: Color(0xFF0A6A60),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DemoCredentialsPanel(onUse: controller.isLoading ? null : _useDemo),
        ],
      ),
    );
  }
}
