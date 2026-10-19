import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/payment_records.dart';

abstract final class PaymentStyles {
  static const muted = TextStyle(color: DesignTokens.mutedText, fontSize: 13);
  static const green = Color(0xFF00813B);
  static const red = Color(0xFFC62A2F);
  static const amber = Color(0xFF8A5A00);
  static const neutral = Color(0xFF4A5D5B);
  static const greenBackground = Color(0xFFE5F6EC);
  static const redBackground = Color(0xFFFDECEC);
  static const amberBackground = Color(0xFFFFF4DD);
  static const neutralBackground = Color(0xFFEEF2F1);
  static Color invoiceColor(InvoiceStatus status) => switch (status) {
    InvoiceStatus.paid => green,
    InvoiceStatus.partial => amber,
    InvoiceStatus.overdue || InvoiceStatus.failed => red,
    _ => neutral,
  };
  static Color settlementColor(SettlementStatus status) => switch (status) {
    SettlementStatus.paid => green,
    SettlementStatus.payoutFailed => red,
    SettlementStatus.approved => DesignTokens.primary,
    _ => neutral,
  };
}

class PaymentBadge extends StatelessWidget {
  const PaymentBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color == PaymentStyles.red
          ? PaymentStyles.redBackground
          : color == PaymentStyles.amber
          ? PaymentStyles.amberBackground
          : color == PaymentStyles.green
          ? PaymentStyles.greenBackground
          : color == DesignTokens.primary
          ? const Color(0xFFE5F5F3)
          : PaymentStyles.neutralBackground,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class DemoGatewayBadge extends StatelessWidget {
  const DemoGatewayBadge({super.key});
  @override
  Widget build(BuildContext context) => const Tooltip(
    message: 'Local demonstration only. No real payments or money transfers.',
    child: PaymentBadge(
      label: 'DEMO GATEWAY · no real money',
      color: PaymentStyles.amber,
    ),
  );
}

class PaymentsHeaderBadge extends StatelessWidget {
  const PaymentsHeaderBadge({super.key});
  @override
  Widget build(BuildContext context) => MediaQuery.sizeOf(context).width < 664
      ? const Tooltip(
          message: 'DEMO GATEWAY · no real money',
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.science_outlined, color: PaymentStyles.amber),
          ),
        )
      : const DemoGatewayBadge();
}
