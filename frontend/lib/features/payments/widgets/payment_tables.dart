import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/payment_records.dart';
import 'payment_styles.dart';

class ParentInvoicesTable extends StatelessWidget {
  const ParentInvoicesTable({
    super.key,
    required this.invoices,
    required this.onDetails,
    required this.onAction,
    required this.onClear,
  });
  final List<ParentInvoice> invoices;
  final ValueChanged<ParentInvoice> onDetails, onAction;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => _PaymentTable(
    empty: invoices.isEmpty,
    onClear: onClear,
    minimumWidth: 1060,
    widths: const [15, 26, 15, 9, 9, 13, 14],
    headers: const [
      'Invoice',
      'Parent · student',
      'Driver',
      'Amount',
      'Due',
      'Status',
      '',
    ],
    rightAligned: const {3, 6},
    rows: [
      for (final invoice in invoices)
        [
          _TableLink(
            label: invoice.id,
            bold: true,
            onPressed: () => onDetails(invoice),
            color: DesignTokens.text,
          ),
          Text('${invoice.parent} · ${invoice.students}'),
          Text(invoice.driver),
          Text(
            formatLkr(invoice.amount),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(invoice.due),
          InkWell(
            onTap: () => onDetails(invoice),
            borderRadius: BorderRadius.circular(20),
            child: PaymentBadge(
              label: invoice.statusLabel,
              color: PaymentStyles.invoiceColor(invoice.status),
            ),
          ),
          _TableLink(
            key: ValueKey('invoice-action-${invoice.id}'),
            label: invoice.actionLabel,
            onPressed: () => onAction(invoice),
          ),
        ],
    ],
  );
}

class DriverSettlementsTable extends StatelessWidget {
  const DriverSettlementsTable({
    super.key,
    required this.settlements,
    required this.onDetails,
    required this.onApprove,
    required this.onClear,
  });
  final List<DriverSettlement> settlements;
  final ValueChanged<DriverSettlement> onDetails, onApprove;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => _PaymentTable(
    empty: settlements.isEmpty,
    onClear: onClear,
    minimumWidth: 1060,
    widths: const [23, 16, 11, 10, 12, 16, 12],
    headers: const [
      'Driver',
      'Period',
      'Collected',
      'Fee 5%',
      'Net payable',
      'Status',
      '',
    ],
    rightAligned: const {2, 3, 4, 6},
    rowHeight: 60,
    rows: [
      for (final settlement in settlements)
        [
          _TableLink(
            label: settlement.driver,
            bold: true,
            onPressed: () => onDetails(settlement),
            color: DesignTokens.text,
          ),
          Text(settlement.period),
          Text(formatLkr(settlement.collected)),
          Text(formatLkr(settlement.fee)),
          Text(
            formatLkr(settlement.netPayable),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Tooltip(
            message: 'View demo settlement details',
            child: InkWell(
              onTap: () => onDetails(settlement),
              borderRadius: BorderRadius.circular(20),
              child: PaymentBadge(
                label: settlement.statusLabel,
                color: PaymentStyles.settlementColor(settlement.status),
              ),
            ),
          ),
          if (settlement.status == SettlementStatus.draft)
            FilledButton(
              key: ValueKey('approve-${settlement.id}'),
              onPressed: () => onApprove(settlement),
              style: FilledButton.styleFrom(
                minimumSize: const Size(83, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Approve'),
            )
          else if (settlement.status == SettlementStatus.approved)
            _TableLink(
              label: 'Demo bank result',
              onPressed: () => onDetails(settlement),
            )
          else
            const SizedBox.shrink(),
        ],
    ],
  );
}

class _TableLink extends StatelessWidget {
  const _TableLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.bold = false,
    this.color = DesignTokens.primary,
  });
  final String label;
  final VoidCallback onPressed;
  final bool bold;
  final Color color;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: color,
      textStyle: TextStyle(
        fontFamily: 'NovaSysSans',
        fontSize: 14,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
    child: Text(label),
  );
}

/// A native, bounded table: the page scrolls vertically, only the table scrolls
/// horizontally when the browser is narrower than the reference columns.
class _PaymentTable extends StatefulWidget {
  const _PaymentTable({
    required this.headers,
    required this.widths,
    required this.rightAligned,
    required this.rows,
    required this.empty,
    required this.onClear,
    required this.minimumWidth,
    this.rowHeight = 42,
  });
  final List<String> headers;
  final List<double> widths;
  final Set<int> rightAligned;
  final List<List<Widget>> rows;
  final bool empty;
  final VoidCallback onClear;
  final double rowHeight, minimumWidth;
  @override
  State<_PaymentTable> createState() => _PaymentTableState();
}

class _PaymentTableState extends State<_PaymentTable> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Widget cell(Widget child, int index, double height) => TableCell(
    verticalAlignment: TableCellVerticalAlignment.middle,
    child: Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      alignment: widget.rightAligned.contains(index)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: child,
    ),
  );
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: DesignTokens.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: widget.empty
        ? Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('No matching demo records.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onClear,
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          )
        : LayoutBuilder(
            builder: (context, constraints) => Scrollbar(
              controller: _scroll,
              thumbVisibility: constraints.maxWidth < widget.minimumWidth,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  bottom: constraints.maxWidth < widget.minimumWidth ? 10 : 0,
                ),
                child: SizedBox(
                  width: math.max(constraints.maxWidth, widget.minimumWidth),
                  child: Table(
                    columnWidths: {
                      for (var i = 0; i < widget.widths.length; i++)
                        i: FlexColumnWidth(widget.widths[i]),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEEF2F1)),
                          ),
                        ),
                        children: [
                          for (var i = 0; i < widget.headers.length; i++)
                            cell(
                              Text(
                                widget.headers[i],
                                style: PaymentStyles.muted.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              i,
                              36,
                            ),
                        ],
                      ),
                      for (var row = 0; row < widget.rows.length; row++)
                        TableRow(
                          decoration: row == widget.rows.length - 1
                              ? null
                              : const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFEEF2F1),
                                    ),
                                  ),
                                ),
                          children: [
                            for (
                              var col = 0;
                              col < widget.rows[row].length;
                              col++
                            )
                              cell(
                                widget.rows[row][col],
                                col,
                                widget.rowHeight,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}
