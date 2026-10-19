import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/admin_navigation.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../controllers/payments_controller.dart';
import '../models/payment_records.dart';
import '../widgets/payment_dialogs.dart';
import '../widgets/payment_filters.dart';
import '../widgets/payment_styles.dart';
import '../widgets/payment_summary_cards.dart';
import '../widgets/payment_tables.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key, this.settlements = false});
  final bool settlements;
  static const title = 'Payments';
  static const subtitle =
      'Parents pay NovaSys · NovaSys settles drivers monthly';
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    return Semantics(
      label: settlements ? 'Driver settlements' : 'Parent payments',
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (constraints.maxWidth <
                  DesignTokens.compactPageHeaderWidth) ...[
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text(subtitle, style: PaymentStyles.muted),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: DemoGatewayBadge(),
                ),
                const SizedBox(height: 16),
              ],
              PaymentSummaryCards(overview: controller.overview),
              const SizedBox(height: 20),
              _PaymentTabs(settlements: settlements),
              const SizedBox(height: 18),
              if (controller.filtersVisible ||
                  controller.hasFilters(settlements))
                PaymentFilters(
                  key: ValueKey(settlements),
                  settlements: settlements,
                ),
              if (settlements) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF006D64),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Only confirmed parent payments are included. A driver is not "paid" until the bank confirms the payout.',
                          style: TextStyle(
                            color: Color(0xFF006D64),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                DriverSettlementsTable(
                  settlements: controller.filteredSettlements,
                  onDetails: (record) =>
                      _settlementDetails(context, controller, record),
                  onApprove: (record) => _perform(
                    context,
                    controller,
                    PaymentAction.approveSettlement,
                    record.id,
                    record.driver,
                    record.netPayable,
                  ),
                  onClear: () => controller.clearFilters(true),
                ),
              ] else
                ParentInvoicesTable(
                  invoices: controller.filteredInvoices,
                  onDetails: (record) =>
                      _invoiceDetails(context, controller, record),
                  onAction: (record) =>
                      _invoiceAction(context, controller, record),
                  onClear: () => controller.clearFilters(false),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _invoiceAction(
    BuildContext context,
    PaymentsController controller,
    ParentInvoice record,
  ) async {
    final action = switch (record.status) {
      InvoiceStatus.pending when !record.reminderLogged => PaymentAction.remind,
      InvoiceStatus.overdue when !record.followUpLogged =>
        PaymentAction.followUp,
      InvoiceStatus.failed => PaymentAction.retryInvoice,
      _ => null,
    };
    if (action == null) {
      await _invoiceDetails(context, controller, record);
    } else {
      await _perform(context, controller, action, record.id, record.id, null);
    }
  }

  Future<void> _invoiceDetails(
    BuildContext context,
    PaymentsController controller,
    ParentInvoice record,
  ) async {
    final action = await showInvoiceDetails(context, record);
    if (action != null && context.mounted) {
      await _perform(
        context,
        controller,
        action,
        record.id,
        record.id,
        action == PaymentAction.collectInvoice ? record.outstanding : null,
      );
    }
  }

  Future<void> _settlementDetails(
    BuildContext context,
    PaymentsController controller,
    DriverSettlement record,
  ) async {
    final action = await showSettlementDetails(context, record);
    if (action != null && context.mounted) {
      await _perform(
        context,
        controller,
        action,
        record.id,
        record.driver,
        record.netPayable,
      );
    }
  }

  Future<void> _perform(
    BuildContext context,
    PaymentsController controller,
    PaymentAction action,
    String id,
    String label,
    int? amount,
  ) async {
    final confirmed = await confirmPaymentAction(
      context,
      action,
      label,
      amount: amount,
    );
    if (!confirmed || !context.mounted) return;
    final success = controller.perform(action, id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          showCloseIcon: true,
          content: Text(
            success
                ? PaymentActionText.feedback(action)
                : controller.actionError!,
          ),
        ),
      );
  }
}

class _PaymentTabs extends StatelessWidget {
  const _PaymentTabs({required this.settlements});
  final bool settlements;
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DesignTokens.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tab(
                    context,
                    'Parent invoices',
                    !settlements,
                    AdminNavigation.paymentsPath,
                  ),
                  _tab(
                    context,
                    'Driver settlements',
                    settlements,
                    AdminNavigation.settlementsPath,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('payment-filters-toggle'),
            tooltip: 'Search & filters',
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            isSelected:
                controller.filtersVisible || controller.hasFilters(settlements),
            onPressed: controller.toggleFilters,
            icon: const Icon(Icons.search, size: 20),
            selectedIcon: const Icon(Icons.filter_alt, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, bool selected, String path) =>
      Semantics(
        selected: selected,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? DesignTokens.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: TextButton(
            onPressed: () => context.go(path),
            style: TextButton.styleFrom(
              foregroundColor: selected
                  ? DesignTokens.primary
                  : DesignTokens.mutedText,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(),
              textStyle: const TextStyle(
                fontFamily: 'NovaSysSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(label),
          ),
        ),
      );
}
