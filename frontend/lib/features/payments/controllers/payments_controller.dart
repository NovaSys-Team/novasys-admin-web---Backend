import 'package:flutter/foundation.dart';

import '../models/payment_records.dart';
import '../models/payments_mock_data.dart';

enum PaymentAction {
  remind,
  followUp,
  retryInvoice,
  collectInvoice,
  approveSettlement,
  retrySettlement,
  bankSuccess,
  bankFailure,
}

class PaymentsController extends ChangeNotifier {
  final List<ParentInvoice> _invoices = List.of(PaymentsMockData.invoices);
  final List<DriverSettlement> _settlements = List.of(
    PaymentsMockData.settlements,
  );
  PaymentOverview _overview = PaymentsMockData.overview;
  PaymentOverview get overview => _overview;
  List<ParentInvoice> get invoices => List.unmodifiable(_invoices);
  List<DriverSettlement> get settlements => List.unmodifiable(_settlements);
  String _invoiceQuery = '', _settlementQuery = '';
  InvoiceStatus? _invoiceStatus;
  SettlementStatus? _settlementStatus;
  String get invoiceQuery => _invoiceQuery;
  String get settlementQuery => _settlementQuery;
  InvoiceStatus? get invoiceStatus => _invoiceStatus;
  SettlementStatus? get settlementStatus => _settlementStatus;
  bool _filtersVisible = false;
  bool get filtersVisible => _filtersVisible;
  String? _actionError;
  String? get actionError => _actionError;
  final List<String> _activity = [];
  List<String> get activity => List.unmodifiable(_activity);

  List<ParentInvoice> get filteredInvoices => _invoices
      .where((record) {
        final haystack =
            '${record.id} ${record.parent} ${record.students} ${record.driver}'
                .replaceAll('–', '-')
                .toLowerCase();
        return (_invoiceStatus == null || record.status == _invoiceStatus) &&
            haystack.contains(
              _invoiceQuery.trim().replaceAll('–', '-').toLowerCase(),
            );
      })
      .toList(growable: false);
  List<DriverSettlement> get filteredSettlements => _settlements
      .where(
        (record) =>
            (_settlementStatus == null || record.status == _settlementStatus) &&
            '${record.driver} ${record.period} ${record.id}'
                .replaceAll('–', '-')
                .toLowerCase()
                .contains(
                  _settlementQuery.trim().replaceAll('–', '-').toLowerCase(),
                ),
      )
      .toList(growable: false);
  bool hasFilters(bool settlements) => settlements
      ? _settlementQuery.trim().isNotEmpty || _settlementStatus != null
      : _invoiceQuery.trim().isNotEmpty || _invoiceStatus != null;
  void toggleFilters() {
    _filtersVisible = !_filtersVisible;
    notifyListeners();
  }

  void setQuery(String value, {required bool settlements}) {
    if (settlements) {
      _settlementQuery = value;
    } else {
      _invoiceQuery = value;
    }
    notifyListeners();
  }

  void setInvoiceStatus(InvoiceStatus? value) {
    _invoiceStatus = value;
    notifyListeners();
  }

  void setSettlementStatus(SettlementStatus? value) {
    _settlementStatus = value;
    notifyListeners();
  }

  void clearFilters(bool settlements) {
    if (settlements) {
      _settlementQuery = '';
      _settlementStatus = null;
    } else {
      _invoiceQuery = '';
      _invoiceStatus = null;
    }
    notifyListeners();
  }

  ParentInvoice? invoice(String id) {
    for (final record in _invoices) {
      if (record.id == id) return record;
    }
    return null;
  }

  DriverSettlement? settlement(String id) {
    for (final record in _settlements) {
      if (record.id == id) return record;
    }
    return null;
  }

  bool canPerform(PaymentAction action, String id) {
    final bill = invoice(id);
    final payout = settlement(id);
    return switch (action) {
      PaymentAction.remind =>
        bill?.status == InvoiceStatus.pending && !bill!.reminderLogged,
      PaymentAction.followUp =>
        bill?.status == InvoiceStatus.overdue && !bill!.followUpLogged,
      PaymentAction.retryInvoice => bill?.status == InvoiceStatus.failed,
      PaymentAction.collectInvoice =>
        bill != null &&
            bill.outstanding > 0 &&
            bill.status != InvoiceStatus.failed,
      PaymentAction.approveSettlement =>
        payout?.status == SettlementStatus.draft,
      PaymentAction.retrySettlement =>
        payout?.status == SettlementStatus.payoutFailed,
      PaymentAction.bankSuccess ||
      PaymentAction.bankFailure => payout?.status == SettlementStatus.approved,
    };
  }

  /// Local fixture mutations only. Approval never means a payout was paid.
  bool perform(PaymentAction action, String id) {
    if (!canPerform(action, id)) {
      _actionError =
          'This demo action is no longer available. Review the current status.';
      notifyListeners();
      return false;
    }
    _actionError = null;
    final bill = invoice(id);
    if (bill != null) {
      final updated = switch (action) {
        PaymentAction.remind => bill.copyWith(reminderLogged: true),
        PaymentAction.followUp => bill.copyWith(followUpLogged: true),
        PaymentAction.retryInvoice => bill.copyWith(
          status: InvoiceStatus.pending,
        ),
        PaymentAction.collectInvoice => bill.copyWith(
          status: InvoiceStatus.paid,
          received: bill.amount,
        ),
        _ => bill,
      };
      if (action == PaymentAction.collectInvoice) {
        _overview = _overview.withCollection(
          bill.outstanding,
          wasOverdue: bill.status == InvoiceStatus.overdue,
        );
      }
      _invoices[_invoices.indexOf(bill)] = updated;
    } else {
      final payout = settlement(id)!;
      final status = switch (action) {
        PaymentAction.bankSuccess => SettlementStatus.paid,
        PaymentAction.bankFailure => SettlementStatus.payoutFailed,
        _ => SettlementStatus.approved,
      };
      _settlements[_settlements.indexOf(payout)] = payout.withStatus(status);
      if (action == PaymentAction.bankSuccess) {
        _overview = _overview.withSettledDriver(payout.netPayable);
      }
    }
    _activity.add('$id · ${action.name} · demo only');
    notifyListeners();
    return true;
  }
}
