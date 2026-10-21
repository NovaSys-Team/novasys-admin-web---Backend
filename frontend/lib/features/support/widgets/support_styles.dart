import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/support_ticket.dart';

const supportMuted = TextStyle(fontSize: 12, color: DesignTokens.mutedText);
const supportTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

class SupportCard extends StatelessWidget {
  const SupportCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: DesignTokens.border),
    ),
    child: child,
  );
}

class SupportBadge extends StatelessWidget {
  const SupportBadge(this.label, {super.key, this.status});
  final String label;
  final TicketStatus? status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: status == TicketStatus.waiting
          ? const Color(0xFFFFF4DC)
          : status == null
          ? const Color(0xFFEDF2F1)
          : const Color(0xFFE5F5F3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: status == TicketStatus.waiting
            ? const Color(0xFF925B00)
            : status == null
            ? DesignTokens.mutedText
            : DesignTokens.primary,
      ),
    ),
  );
}

Future<bool> confirmSupportAction(
  BuildContext context,
  String title,
  String description,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            '$description\n\nDemo only: changes stay in this session. No messages are sent.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('support-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;
