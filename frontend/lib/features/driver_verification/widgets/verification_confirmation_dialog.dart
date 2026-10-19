import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/driver_application.dart';

Future<bool> confirmVerificationDecision(
  BuildContext context,
  DriverApplication application,
  VerificationDecision decision,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${decision.label}?'),
        scrollable: true,
        content: SizedBox(
          width: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                application.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (decision != VerificationDecision.approve) ...[
                Text('Note to driver: ${application.note.trim()}'),
                const SizedBox(height: 12),
              ],
              const Text(
                'This only changes the local demo application. No real driver account is changed, no message is sent and no audit log is created.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm-verification'),
            style: FilledButton.styleFrom(
              backgroundColor: decision == VerificationDecision.reject
                  ? DesignTokens.danger
                  : DesignTokens.primary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(decision.label),
          ),
        ],
      ),
    ) ??
    false;
