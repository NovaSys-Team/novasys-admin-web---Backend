import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/support_ticket.dart';
import 'support_styles.dart';

class SupportDetails extends StatelessWidget {
  const SupportDetails({super.key, required this.ticket});
  final SupportTicket ticket;
  @override
  Widget build(BuildContext context) => SupportCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Details', style: supportTitle),
        const SizedBox(height: 8),
        ...{
          'Category': ticket.category,
          'Priority': 'Normal',
          'Assigned to': ticket.assignedTo,
          'Student': ticket.student,
          'Driver': ticket.driver,
        }.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: supportMuted.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: DesignTokens.border, height: 18),
        const Text(
          'Complaints are private. They never appear in a driver’s public rating.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: DesignTokens.mutedText,
          ),
        ),
      ],
    ),
  );
}
