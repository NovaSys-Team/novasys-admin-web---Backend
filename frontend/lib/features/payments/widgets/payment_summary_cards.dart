import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/payment_records.dart';
import 'payment_styles.dart';

class PaymentSummaryCards extends StatelessWidget {
  const PaymentSummaryCards({super.key, required this.overview});
  final PaymentOverview overview;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = constraints.maxWidth >= 950
          ? 4
          : constraints.maxWidth >= 450
          ? 2
          : 1;
      final width = (constraints.maxWidth - 14 * (count - 1)) / count;
      final cards = [
        _Summary(
          label: 'Invoiced · October',
          amount: 'LKR ${formatLkr(overview.invoiced, compact: true)}',
          detail: '${overview.invoiceCount} invoices',
        ),
        _Summary(
          label: 'Collected',
          amount: 'LKR ${formatLkr(overview.collected, compact: true)}',
          progress: overview.collectionProgress,
        ),
        _Summary(
          label: 'Overdue',
          amount: 'LKR ${formatLkr(overview.overdue).split('.').first}',
          detail: '${overview.overdueCount} invoices · reminders sent',
          danger: true,
        ),
        _Summary(
          label: 'To settle 5 Nov',
          amount: 'LKR ${formatLkr(overview.toSettle, compact: true)}',
          detail: '${overview.driverCount} drivers · after 5% fee',
        ),
      ];
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final card in cards) SizedBox(width: width, child: card),
        ],
      );
    },
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.amount,
    this.detail,
    this.progress,
    this.danger = false,
  });
  final String label, amount;
  final String? detail;
  final double? progress;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 104),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: danger ? const Color(0xFFFFC6C8) : DesignTokens.border,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PaymentStyles.muted.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: danger ? DesignTokens.danger : DesignTokens.text,
          ),
        ),
        if (detail != null)
          Text(
            detail!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? DesignTokens.danger : DesignTokens.mutedText,
            ),
          ),
        if (progress != null) ...[
          const SizedBox(height: 8),
          Semantics(
            label:
                'Collected ${(progress! * 100).round()} percent of invoiced total',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: PaymentStyles.neutralBackground,
            ),
          ),
        ],
      ],
    ),
  );
}
