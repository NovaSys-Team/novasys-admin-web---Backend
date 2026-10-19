import 'package:flutter/material.dart';

import '../controllers/payments_controller.dart';
import '../models/payment_records.dart';
import 'payment_styles.dart';

abstract final class PaymentActionText {
  static String title(PaymentAction action) => switch (action) {
    PaymentAction.remind => 'Log a demo reminder?',
    PaymentAction.followUp => 'Record a demo follow-up?',
    PaymentAction.retryInvoice => 'Prepare a demo retry?',
    PaymentAction.collectInvoice => 'Simulate invoice payment?',
    PaymentAction.approveSettlement => 'Approve demo settlement?',
    PaymentAction.retrySettlement => 'Retry demo settlement?',
    PaymentAction.bankSuccess => 'Simulate bank confirmation?',
    PaymentAction.bankFailure => 'Simulate bank failure?',
  };
  static String description(PaymentAction action) => switch (action) {
    PaymentAction.remind =>
      'Record a reminder in local demo state. No reminder is sent to a parent.',
    PaymentAction.followUp => 'Record a fictional parent follow-up. No phone call is placed and no parent is contacted.',
    PaymentAction.retryInvoice => 'Move the failed mock invoice back to pending. No payment link is created or sent, and no gateway is contacted.',
    PaymentAction.collectInvoice => 'Mark the remaining mock balance as paid and update the demonstration total. No card is charged and no money is collected.',
    PaymentAction.approveSettlement => 'Approve this mock settlement for the next demo step. Approval does not mean paid. No payout is submitted and no money is transferred.',
    PaymentAction.retrySettlement => 'Return this failed mock settlement to approved, awaiting a simulated bank result. No payout is submitted and no money is transferred.',
    PaymentAction.bankSuccess => 'Set the local settlement status to paid for this demonstration. No bank is contacted and no money is transferred.',
    PaymentAction.bankFailure => 'Set the local settlement status to payout failed for this demonstration. No bank is contacted and no money is transferred.',
  };
  static String feedback(PaymentAction action) => switch (action) {
    PaymentAction.remind => 'Demo reminder logged. No message sent.',
    PaymentAction.followUp => 'Demo follow-up logged. No call placed.',
    PaymentAction.retryInvoice => 'Demo retry prepared. No payment link sent.',
    PaymentAction.collectInvoice =>
      'Demo invoice marked paid. No money collected.',
    PaymentAction.approveSettlement => 'Demo settlement approved, awaiting a simulated bank result. No money transferred.',
    PaymentAction.retrySettlement => 'Demo retry approved, awaiting a simulated bank result. No money transferred.',
    PaymentAction.bankSuccess =>
      'Demo bank result recorded as paid. No money transferred.',
    PaymentAction.bankFailure =>
      'Demo bank failure recorded. No money transferred.',
  };
}

Future<bool> confirmPaymentAction(
  BuildContext context,
  PaymentAction action,
  String record, {
  int? amount,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(PaymentActionText.title(action)),
        content: SizedBox(
          width: 460,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const DemoGatewayBadge(),
              const SizedBox(height: 16),
              Text(record, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (amount != null) ...[
                const SizedBox(height: 8),
                Text('Demo amount: LKR ${formatLkr(amount)}'),
              ],
              const SizedBox(height: 12),
              Text(PaymentActionText.description(action)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm-payment-action'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm demo action'),
          ),
        ],
      ),
    ) ??
    false;

Future<PaymentAction?> showInvoiceDetails(
  BuildContext context,
  ParentInvoice invoice,
) => showDialog<PaymentAction>(
  context: context,
  builder: (context) => AlertDialog(
    scrollable: true,
    title: Text(
      invoice.status == InvoiceStatus.paid ? 'Demo receipt' : 'Invoice details',
    ),
    content: SizedBox(
      width: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: DemoGatewayBadge(),
          ),
          const SizedBox(height: 16),
          _Detail('Invoice', invoice.id),
          _Detail('Parent', invoice.parent),
          _Detail('Students', invoice.students),
          _Detail('Driver', invoice.driver),
          _Detail('Due', invoice.due),
          _Detail('Amount', 'LKR ${formatLkr(invoice.amount)}'),
          _Detail('Received (demo)', 'LKR ${formatLkr(invoice.received)}'),
          _Detail(
            'Outstanding (demo)',
            'LKR ${formatLkr(invoice.outstanding)}',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PaymentBadge(
              label: invoice.statusLabel,
              color: PaymentStyles.invoiceColor(invoice.status),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            invoice.status == InvoiceStatus.paid
                ? 'Sample receipt only. This is not proof of a real payment.'
                : 'Local demonstration record. No real payment gateway, parent contact or card details are used.',
            style: PaymentStyles.muted,
          ),
          if (invoice.reminderLogged)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Demo reminder logged · no message sent.'),
            ),
          if (invoice.followUpLogged)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Demo follow-up logged · no call placed.'),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
      if (invoice.status == InvoiceStatus.failed)
        FilledButton(
          onPressed: () => Navigator.pop(context, PaymentAction.retryInvoice),
          child: const Text('Prepare demo retry'),
        )
      else if (invoice.outstanding > 0)
        FilledButton(
          key: const ValueKey('simulate-invoice-payment'),
          onPressed: () => Navigator.pop(context, PaymentAction.collectInvoice),
          child: const Text('Simulate remaining payment'),
        ),
    ],
  ),
);

Future<PaymentAction?> showSettlementDetails(
  BuildContext context,
  DriverSettlement settlement,
) => showDialog<PaymentAction>(
  context: context,
  builder: (context) => AlertDialog(
    scrollable: true,
    title: const Text('Demo settlement details'),
    content: SizedBox(
      width: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: DemoGatewayBadge(),
          ),
          const SizedBox(height: 16),
          _Detail('Driver', settlement.driver),
          _Detail('Settlement', settlement.id),
          _Detail('Period', settlement.period),
          _Detail('Collected', 'LKR ${formatLkr(settlement.collected)}'),
          _Detail('Fee 5%', 'LKR ${formatLkr(settlement.fee)}'),
          _Detail('Net payable', 'LKR ${formatLkr(settlement.netPayable)}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PaymentBadge(
              label: settlement.statusLabel,
              color: PaymentStyles.settlementColor(settlement.status),
            ),
          ),
          const SizedBox(height: 16),
          Text(switch (settlement.status) {
            SettlementStatus.draft =>
              'Draft demo settlement. Approval will not mark it paid.',
            SettlementStatus.approved => 'Approved in local state only. Choose a simulated bank result to continue. No payout has been sent.',
            SettlementStatus.paid => 'Paid is a simulated bank result only. No bank was contacted and no real money was transferred.',
            SettlementStatus.payoutFailed => 'Fictional payout failure. You can retry the demo workflow without contacting a bank or transferring money.',
          }),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
      if (settlement.status == SettlementStatus.draft)
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, PaymentAction.approveSettlement),
          child: const Text('Approve (demo)'),
        ),
      if (settlement.status == SettlementStatus.payoutFailed)
        FilledButton(
          key: const ValueKey('retry-demo-settlement'),
          onPressed: () =>
              Navigator.pop(context, PaymentAction.retrySettlement),
          child: const Text('Retry (demo)'),
        ),
      if (settlement.status == SettlementStatus.approved) ...[
        OutlinedButton(
          key: const ValueKey('demo-bank-failure'),
          onPressed: () => Navigator.pop(context, PaymentAction.bankFailure),
          child: const Text('Simulate failure'),
        ),
        FilledButton(
          key: const ValueKey('demo-bank-success'),
          onPressed: () => Navigator.pop(context, PaymentAction.bankSuccess),
          child: const Text('Simulate success'),
        ),
      ],
    ],
  ),
);

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: MediaQuery.sizeOf(context).width < 500
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: PaymentStyles.muted),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: PaymentStyles.muted)),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
  );
}
