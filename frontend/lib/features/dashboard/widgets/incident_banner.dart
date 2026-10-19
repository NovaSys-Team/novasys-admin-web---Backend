import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';

class IncidentBanner extends StatelessWidget {
  const IncidentBanner({
    super.key,
    required this.incident,
    required this.onOpen,
  });
  final DashboardIncident incident;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: DesignTokens.danger,
      borderRadius: BorderRadius.circular(16),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final action = FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFC62A2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onOpen,
          child: const Text('Open incident'),
        );
        final message = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                incident.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [message, const SizedBox(height: 12), action],
          );
        }
        return Row(
          children: [
            Expanded(child: message),
            const SizedBox(width: 16),
            action,
          ],
        );
      },
    ),
  );
}
