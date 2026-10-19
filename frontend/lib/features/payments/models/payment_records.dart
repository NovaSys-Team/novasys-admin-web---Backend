enum InvoiceStatus { pending, overdue, paid, partial, failed }

enum SettlementStatus { draft, approved, paid, payoutFailed }

/// All amounts are mock LKR minor units, avoiding floating-point money math.
class ParentInvoice {
  const ParentInvoice({
    required this.id,
    required this.parent,
    required this.students,
    required this.driver,
    required this.amount,
    required this.received,
    required this.due,
    required this.status,
    this.reminderLogged = false,
    this.followUpLogged = false,
  });
  final String id, parent, students, driver, due;
  final int amount, received;
  final InvoiceStatus status;
  final bool reminderLogged, followUpLogged;
  int get outstanding => amount - received;
  String get statusLabel => status.name.toUpperCase();
  String get actionLabel => switch (status) {
    InvoiceStatus.pending =>
      reminderLogged ? 'Reminder logged' : 'Send reminder',
    InvoiceStatus.overdue =>
      followUpLogged ? 'Follow-up logged' : 'Call parent',
    InvoiceStatus.paid => 'Receipt',
    InvoiceStatus.partial => 'View',
    InvoiceStatus.failed => 'Retry link',
  };
  ParentInvoice copyWith({
    InvoiceStatus? status,
    int? received,
    bool? reminderLogged,
    bool? followUpLogged,
  }) => ParentInvoice(
    id: id,
    parent: parent,
    students: students,
    driver: driver,
    amount: amount,
    received: received ?? this.received,
    due: due,
    status: status ?? this.status,
    reminderLogged: reminderLogged ?? this.reminderLogged,
    followUpLogged: followUpLogged ?? this.followUpLogged,
  );
}

class DriverSettlement {
  const DriverSettlement({
    required this.id,
    required this.driver,
    required this.period,
    required this.collected,
    required this.status,
  });
  final String id, driver, period;
  final int collected;
  final SettlementStatus status;
  int get fee => (collected * 5 + 50) ~/ 100;
  int get netPayable => collected - fee;
  String get statusLabel => switch (status) {
    SettlementStatus.payoutFailed => 'PAYOUT FAILED',
    _ => status.name.toUpperCase(),
  };
  DriverSettlement withStatus(SettlementStatus value) => DriverSettlement(
    id: id,
    driver: driver,
    period: period,
    collected: collected,
    status: value,
  );
}

/// Aggregate fixture totals cover the full fictional October dataset.
/// The tables intentionally show only the sample records from A04/A04.2.
class PaymentOverview {
  const PaymentOverview({
    required this.invoiced,
    required this.collected,
    required this.overdue,
    required this.toSettle,
    required this.invoiceCount,
    required this.overdueCount,
    required this.driverCount,
  });
  final int invoiced, collected, overdue, toSettle;
  final int invoiceCount, overdueCount, driverCount;
  double get collectionProgress => (collected / invoiced).clamp(0, 1);
  PaymentOverview withSettledDriver(int net) => PaymentOverview(
    invoiced: invoiced,
    collected: collected,
    overdue: overdue,
    toSettle: toSettle - net,
    invoiceCount: invoiceCount,
    overdueCount: overdueCount,
    driverCount: driverCount - 1,
  );
  PaymentOverview withCollection(int amount, {required bool wasOverdue}) =>
      PaymentOverview(
        invoiced: invoiced,
        collected: collected + amount,
        overdue: wasOverdue ? overdue - amount : overdue,
        toSettle: toSettle,
        invoiceCount: invoiceCount,
        overdueCount: wasOverdue ? overdueCount - 1 : overdueCount,
        driverCount: driverCount,
      );
}

String formatLkr(int minorUnits, {bool compact = false}) {
  if (compact && minorUnits >= 100000000) {
    return '${(minorUnits / 100000000).toStringAsFixed(2)}M';
  }
  final whole = (minorUnits ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$whole.${(minorUnits % 100).toString().padLeft(2, '0')}';
}
