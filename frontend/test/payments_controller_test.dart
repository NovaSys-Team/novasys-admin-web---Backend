import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/payments/controllers/payments_controller.dart';
import 'package:novasys_admin_web/features/payments/models/payment_records.dart';

void main() {
  late PaymentsController controller;
  setUp(() => controller = PaymentsController());
  tearDown(() => controller.dispose());

  test('A04 and A04.2 fixtures, totals and integer fee calculations match', () {
    expect(controller.invoices, hasLength(6));
    expect(controller.settlements, hasLength(4));
    expect(controller.overview.invoiced, 540000000);
    expect(controller.overview.collected, 421000000);
    expect(controller.overview.overdue, 19550000);
    expect(controller.overview.toSettle, 400000000);
    expect(controller.overview.invoiceCount, 636);
    expect(controller.overview.overdueCount, 23);
    expect(controller.overview.driverCount, 42);
    expect(controller.settlements.map((s) => s.fee), [
      510000,
      684000,
      273000,
      468000,
    ]);
    expect(controller.settlements.map((s) => s.netPayable), [
      9690000,
      12996000,
      5187000,
      8892000,
    ]);
    expect(controller.invoices.map((i) => i.status), [
      InvoiceStatus.pending,
      InvoiceStatus.overdue,
      InvoiceStatus.paid,
      InvoiceStatus.partial,
      InvoiceStatus.failed,
      InvoiceStatus.paid,
    ]);
  });
  test(
    'Case-insensitive queries, normalized invoice IDs and statuses combine',
    () {
      controller.setQuery(' INV-10-0418 ', settlements: false);
      expect(controller.filteredInvoices.single.parent, 'Nadeesha P.');
      controller.setQuery('rUwAn', settlements: false);
      expect(controller.filteredInvoices, hasLength(3));
      controller.setInvoiceStatus(InvoiceStatus.paid);
      expect(controller.filteredInvoices.single.students, 'Tharushi');
      controller.setInvoiceStatus(InvoiceStatus.failed);
      expect(controller.filteredInvoices, isEmpty);
      controller.clearFilters(false);
      expect(controller.filteredInvoices, hasLength(6));
      expect(controller.hasFilters(false), false);
    },
  );
  test(
    'Queries preserve typed spaces and filter state is independent per tab',
    () {
      controller.setQuery('Kumari ', settlements: true);
      controller.setSettlementStatus(SettlementStatus.draft);
      controller.setQuery('Ruwan ', settlements: false);
      controller.setInvoiceStatus(InvoiceStatus.pending);
      expect(controller.invoiceQuery, 'Ruwan ');
      expect(controller.settlementQuery, 'Kumari ');
      expect(
        controller.filteredSettlements.single.driver,
        'Kumari Wickramasinghe',
      );
      controller.clearFilters(false);
      expect(controller.hasFilters(true), true);
      controller.clearFilters(true);
      expect(controller.filteredSettlements, hasLength(4));
      expect(controller.hasFilters(true), false);
    },
  );
  test(
    'Reminders and follow-ups log once without pretending an invoice was paid',
    () {
      final pending = controller.invoices[0], overdue = controller.invoices[1];
      expect(controller.perform(PaymentAction.remind, pending.id), true);
      expect(controller.invoice(pending.id)!.reminderLogged, true);
      expect(controller.invoice(pending.id)!.status, InvoiceStatus.pending);
      expect(controller.perform(PaymentAction.remind, pending.id), false);
      expect(controller.perform(PaymentAction.followUp, overdue.id), true);
      expect(controller.invoice(overdue.id)!.status, InvoiceStatus.overdue);
      expect(controller.perform(PaymentAction.followUp, overdue.id), false);
      expect(controller.activity, hasLength(2));
      expect(controller.overview.collected, 421000000);
    },
  );
  test('Failed invoices must retry before simulated collection; no duplicate collection', () {
    final failed = controller.invoices[4];
    expect(controller.perform(PaymentAction.collectInvoice, failed.id), false);
    expect(controller.perform(PaymentAction.retryInvoice, failed.id), true);
    expect(controller.invoice(failed.id)!.status, InvoiceStatus.pending);
    expect(controller.perform(PaymentAction.retryInvoice, failed.id), false);
    expect(controller.perform(PaymentAction.collectInvoice, failed.id), true);
    expect(controller.invoice(failed.id)!.received, failed.amount);
    expect(controller.overview.collected, 421720000);
    expect(controller.perform(PaymentAction.collectInvoice, failed.id), false);
    expect(controller.overview.collected, 421720000);
  });
  test('Partial collection uses only outstanding amount and clears overdue aggregates correctly', () {
    final partial = controller.invoices[3], overdue = controller.invoices[1];
    controller.perform(PaymentAction.collectInvoice, partial.id);
    expect(controller.overview.collected, 421360000);
    expect(controller.overview.overdueCount, 23);
    controller.perform(PaymentAction.collectInvoice, overdue.id);
    expect(controller.overview.collected, 422210000);
    expect(controller.overview.overdue, 18700000);
    expect(controller.overview.overdueCount, 22);
    expect(controller.overview.toSettle, 400000000);
  });
  test('Approval does not mean paid; bank simulation requires approval', () {
    final record = controller.settlements.first;
    expect(controller.perform(PaymentAction.bankSuccess, record.id), false);
    expect(
      controller.perform(PaymentAction.approveSettlement, record.id),
      true,
    );
    expect(controller.settlement(record.id)!.status, SettlementStatus.approved);
    expect(controller.overview.toSettle, 400000000);
    expect(
      controller.perform(PaymentAction.approveSettlement, record.id),
      false,
    );
    expect(controller.perform(PaymentAction.bankSuccess, record.id), true);
    expect(controller.settlement(record.id)!.status, SettlementStatus.paid);
    expect(controller.overview.toSettle, 390310000);
    expect(controller.overview.driverCount, 41);
    expect(controller.perform(PaymentAction.bankSuccess, record.id), false);
    expect(controller.overview.driverCount, 41);
  });
  test('Failed payouts can retry, fail and retry again before success', () {
    final failed = controller.settlements.last;
    expect(controller.perform(PaymentAction.bankSuccess, failed.id), false);
    expect(controller.perform(PaymentAction.retrySettlement, failed.id), true);
    expect(controller.perform(PaymentAction.bankFailure, failed.id), true);
    expect(
      controller.settlement(failed.id)!.status,
      SettlementStatus.payoutFailed,
    );
    expect(controller.overview.toSettle, 400000000);
    expect(controller.perform(PaymentAction.retrySettlement, failed.id), true);
    expect(controller.perform(PaymentAction.bankSuccess, failed.id), true);
    expect(controller.settlement(failed.id)!.status, SettlementStatus.paid);
  });
  test(
    'Unknown IDs and mismatched record actions are rejected without mutation',
    () {
      for (final action in PaymentAction.values) {
        expect(controller.perform(action, 'unknown'), false);
      }
      expect(
        controller.perform(
          PaymentAction.approveSettlement,
          controller.invoices.first.id,
        ),
        false,
      );
      expect(
        controller.perform(
          PaymentAction.remind,
          controller.settlements.first.id,
        ),
        false,
      );
      expect(controller.activity, isEmpty);
      expect(controller.actionError, isNotNull);
      expect(
        controller.perform(PaymentAction.remind, controller.invoices.first.id),
        true,
      );
      expect(controller.actionError, isNull);
    },
  );
  test(
    'Collections are immutable and independent controller sessions reset',
    () {
      expect(() => controller.invoices.clear(), throwsUnsupportedError);
      expect(() => controller.settlements.clear(), throwsUnsupportedError);
      expect(() => controller.activity.add('x'), throwsUnsupportedError);
      controller.perform(PaymentAction.remind, controller.invoices.first.id);
      final other = PaymentsController();
      expect(other.invoices.first.reminderLogged, false);
      other.dispose();
    },
  );
  test(
    'LKR formatting preserves exact minor units and compact summary values',
    () {
      expect(formatLkr(540000000, compact: true), '5.40M');
      expect(formatLkr(19550000), '195,500.00');
      expect(formatLkr(123456), '1,234.56');
      expect(formatLkr(0), '0.00');
    },
  );
}
