import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/payments_controller.dart';
import '../models/payment_records.dart';
import 'payment_styles.dart';

class PaymentFilters extends StatefulWidget {
  const PaymentFilters({super.key, required this.settlements});
  final bool settlements;
  @override
  State<PaymentFilters> createState() => _PaymentFiltersState();
}

class _PaymentFiltersState extends State<PaymentFilters> {
  late final TextEditingController _query;
  @override
  void initState() {
    super.initState();
    final controller = context.read<PaymentsController>();
    _query = TextEditingController(
      text: widget.settlements
          ? controller.settlementQuery
          : controller.invoiceQuery,
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    final current = widget.settlements
        ? controller.settlementQuery
        : controller.invoiceQuery;
    if (_query.text != current) {
      _query.value = TextEditingValue(
        text: current,
        selection: TextSelection.collapsed(offset: current.length),
      );
    }
    final search = TextField(
      key: const ValueKey('payment-search'),
      controller: _query,
      onChanged: (value) =>
          controller.setQuery(value, settlements: widget.settlements),
      decoration: InputDecoration(
        labelText: widget.settlements
            ? 'Search drivers or periods'
            : 'Search invoices, parents or drivers',
        prefixIcon: const Icon(Icons.search, size: 20),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
    final status = DropdownButtonFormField<String>(
      key: ValueKey(
        'payment-status-${widget.settlements}-${widget.settlements ? controller.settlementStatus?.name : controller.invoiceStatus?.name}',
      ),
      initialValue: widget.settlements
          ? controller.settlementStatus?.name ?? 'all'
          : controller.invoiceStatus?.name ?? 'all',
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('All statuses')),
        if (widget.settlements)
          for (final status in SettlementStatus.values)
            DropdownMenuItem(
              value: status.name,
              child: Text(
                status == SettlementStatus.payoutFailed
                    ? 'Payout failed'
                    : status.name[0].toUpperCase() + status.name.substring(1),
              ),
            )
        else
          for (final status in InvoiceStatus.values)
            DropdownMenuItem(
              value: status.name,
              child: Text(
                status.name[0].toUpperCase() + status.name.substring(1),
              ),
            ),
      ],
      onChanged: (value) {
        if (widget.settlements) {
          controller.setSettlementStatus(
            value == 'all' ? null : SettlementStatus.values.byName(value!),
          );
        } else {
          controller.setInvoiceStatus(
            value == 'all' ? null : InvoiceStatus.values.byName(value!),
          );
        }
      },
    );
    final clear = TextButton(
      onPressed: controller.hasFilters(widget.settlements)
          ? () => controller.clearFilters(widget.settlements)
          : null,
      child: const Text('Clear filters'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 650
                ? Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: 12),
                      SizedBox(width: 190, child: status),
                      const SizedBox(width: 8),
                      clear,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: 12),
                      status,
                      Align(alignment: Alignment.centerRight, child: clear),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.settlements
                ? '4 sample drivers of 42 · October 2026 · local demo data'
                : '6 sample invoices of 636 · October 2026 · local demo data',
            style: PaymentStyles.muted,
          ),
        ],
      ),
    );
  }
}
