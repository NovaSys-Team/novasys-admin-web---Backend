import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/core/routes/app_router.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';
import 'package:novasys_admin_web/features/payments/controllers/payments_controller.dart';
import 'package:novasys_admin_web/features/payments/models/payment_records.dart';
import 'package:novasys_admin_web/features/payments/views/payments_view.dart';
import 'package:novasys_admin_web/shared/widgets/admin_sidebar.dart';

import 'support/test_app.dart';

void main() {
  void viewport(WidgetTester tester, Size size, {double scale = 1}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  PaymentsController controller(WidgetTester tester) =>
      tester.element(find.byType(PaymentsView).last).read<PaymentsController>();
  GoRouter router(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(PaymentsView).last));
  Future<void> openPayments(
    WidgetTester tester, {
    bool settlements = false,
  }) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.bySemanticsLabel('Admin overview')))
        .go(settlements ? AppRouter.settlementsPath : AppRouter.paymentsPath);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester) =>
      tap(tester, find.byKey(const ValueKey('confirm-payment-action')));
  Future<void> tab(WidgetTester tester, bool settlements) => tap(
    tester,
    find.text(settlements ? 'Driver settlements' : 'Parent invoices').last,
  );
  Future<void> invoiceAction(WidgetTester tester, int index) => tap(
    tester,
    find.byKey(
      ValueKey('invoice-action-${controller(tester).invoices[index].id}'),
    ),
  );

  testWidgets('A04 contains every summary, invoice, label, status and action', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await openPayments(tester);
    for (final label in [
      'Payments',
      PaymentsView.subtitle,
      'DEMO GATEWAY · no real money',
      'Invoiced · October',
      'LKR 5.40M',
      '636 invoices',
      'Collected',
      'LKR 4.21M',
      'Overdue',
      'LKR 195,500',
      '23 invoices · reminders sent',
      'To settle 5 Nov',
      'LKR 4.00M',
      '42 drivers · after 5% fee',
      'Parent invoices',
      'Driver settlements',
      'Invoice',
      'Parent · student',
      'Driver',
      'Amount',
      'Due',
      'Status',
      'PENDING',
      'OVERDUE',
      'PAID',
      'PARTIAL',
      'FAILED',
      'Send reminder',
      'Call parent',
      'Receipt',
      'View',
      'Retry link',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    for (final record in controller(tester).invoices) {
      expect(find.text(record.id), findsOneWidget);
      expect(
        find.text('${record.parent} · ${record.students}'),
        findsOneWidget,
      );
      expect(find.text(formatLkr(record.amount)), findsWidgets);
    }
    expect(find.byType(AdminSidebar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'A04.2 tab and deep route show all settlement values and policy notice',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester);
      await tab(tester, true);
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        AppRouter.settlementsPath,
      );
      expect(
        find.textContaining('A driver is not "paid" until'),
        findsOneWidget,
      );
      expect(find.text('Approve'), findsNWidgets(3));
      expect(find.text('DRAFT'), findsNWidgets(3));
      expect(find.text('PAYOUT FAILED'), findsOneWidget);
      for (final record in controller(tester).settlements) {
        expect(find.text(record.driver), findsOneWidget);
        expect(find.text(formatLkr(record.collected)), findsOneWidget);
        expect(find.text(formatLkr(record.fee)), findsOneWidget);
        expect(find.text(formatLkr(record.netPayable)), findsOneWidget);
      }
      await tab(tester, false);
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        AppRouter.paymentsPath,
      );
      expect(find.text('Send reminder'), findsOneWidget);
    },
  );
  testWidgets(
    'Reminder and parent follow-up require confirmation and explicitly contact nobody',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester);
      await invoiceAction(tester, 0);
      expect(find.textContaining('No reminder is sent'), findsOneWidget);
      expect(controller(tester).invoices.first.reminderLogged, false);
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).invoices.first.reminderLogged, false);
      await invoiceAction(tester, 0);
      await confirm(tester);
      expect(find.text('Reminder logged'), findsOneWidget);
      expect(
        find.text('Demo reminder logged. No message sent.'),
        findsOneWidget,
      );
      expect(controller(tester).invoices.first.status, InvoiceStatus.pending);
      await invoiceAction(tester, 1);
      expect(find.textContaining('No phone call is placed'), findsOneWidget);
      await confirm(tester);
      expect(controller(tester).invoices[1].followUpLogged, true);
      expect(controller(tester).invoices[1].status, InvoiceStatus.overdue);
    },
  );
  testWidgets(
    'Receipt and partial details expose balances and simulated collection is confirmed',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester);
      await invoiceAction(tester, 2);
      expect(find.text('Demo receipt'), findsOneWidget);
      expect(
        find.textContaining('not proof of a real payment'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('simulate-invoice-payment')),
        findsNothing,
      );
      await tap(tester, find.text('Close'));
      await invoiceAction(tester, 3);
      expect(find.text('LKR 3,600.00'), findsNWidgets(2));
      await tap(tester, find.byKey(const ValueKey('simulate-invoice-payment')));
      expect(find.textContaining('No card is charged'), findsOneWidget);
      expect(controller(tester).invoices[3].status, InvoiceStatus.partial);
      await tap(tester, find.text('Cancel'));
      expect(controller(tester).invoices[3].status, InvoiceStatus.partial);
      await invoiceAction(tester, 3);
      await tap(tester, find.byKey(const ValueKey('simulate-invoice-payment')));
      await confirm(tester);
      expect(controller(tester).invoices[3].status, InvoiceStatus.paid);
      expect(controller(tester).overview.collected, 421360000);
      expect(
        find.text('Demo invoice marked paid. No money collected.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Failed invoice retry returns to pending without claiming a link was sent',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester);
      await invoiceAction(tester, 4);
      expect(find.textContaining('No payment link is created'), findsOneWidget);
      await confirm(tester);
      expect(controller(tester).invoices[4].status, InvoiceStatus.pending);
      expect(
        find.text('Demo retry prepared. No payment link sent.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Settlement approval remains unpaid until separately confirmed mock bank success',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester, settlements: true);
      final id = controller(tester).settlements.first.id;
      await tap(tester, find.byKey(ValueKey('approve-$id')));
      expect(
        find.textContaining('Approval does not mean paid'),
        findsOneWidget,
      );
      await tap(tester, find.text('Cancel'));
      expect(
        controller(tester).settlements.first.status,
        SettlementStatus.draft,
      );
      await tap(tester, find.byKey(ValueKey('approve-$id')));
      await confirm(tester);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PAID'), findsNothing);
      await tap(tester, find.text('Demo bank result'));
      await tap(tester, find.byKey(const ValueKey('demo-bank-success')));
      expect(find.textContaining('No bank is contacted'), findsOneWidget);
      expect(
        controller(tester).settlements.first.status,
        SettlementStatus.approved,
      );
      await confirm(tester);
      expect(
        controller(tester).settlements.first.status,
        SettlementStatus.paid,
      );
      expect(find.text('41 drivers · after 5% fee'), findsOneWidget);
      expect(
        find.text('Demo bank result recorded as paid. No money transferred.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Failed settlement detail supports retry, simulated failure and explicit feedback',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester, settlements: true);
      await tap(tester, find.text('Asanka Perera'));
      expect(find.textContaining('Fictional payout failure'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('retry-demo-settlement')));
      await confirm(tester);
      expect(
        controller(tester).settlements.last.status,
        SettlementStatus.approved,
      );
      await tap(tester, find.text('Demo bank result'));
      await tap(tester, find.byKey(const ValueKey('demo-bank-failure')));
      await confirm(tester);
      expect(
        controller(tester).settlements.last.status,
        SettlementStatus.payoutFailed,
      );
      expect(
        find.text('Demo bank failure recorded. No money transferred.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Visible search, status filters, empty state and clear work on both tabs',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester);
      await tap(tester, find.byKey(const ValueKey('payment-filters-toggle')));
      await tester.enterText(
        find.byKey(const ValueKey('payment-search')),
        'ruwan ',
      );
      await tester.pumpAndSettle();
      expect(controller(tester).filteredInvoices, hasLength(3));
      expect(controller(tester).invoiceQuery, 'ruwan ');
      await tap(tester, find.byType(DropdownButtonFormField<String>));
      await tap(tester, find.text('Paid').last);
      expect(controller(tester).filteredInvoices.single.students, 'Tharushi');
      await tester.enterText(
        find.byKey(const ValueKey('payment-search')),
        'missing',
      );
      await tester.pumpAndSettle();
      expect(find.text('No matching demo records.'), findsOneWidget);
      await tap(tester, find.text('Clear filters').first);
      expect(controller(tester).filteredInvoices, hasLength(6));
      await tab(tester, true);
      await tester.enterText(
        find.byKey(const ValueKey('payment-search')),
        'Asanka',
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byType(DropdownButtonFormField<String>));
      await tap(tester, find.text('Payout failed').last);
      expect(
        controller(tester).filteredSettlements.single.driver,
        'Asanka Perera',
      );
      await tab(tester, false);
      expect(controller(tester).hasFilters(false), false);
      await tab(tester, true);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('payment-search')))
            .controller!
            .text,
        'Asanka',
      );
    },
  );
  testWidgets(
    'Sidebar navigation preserves mock changes and logout resets guarded routes',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await openPayments(tester, settlements: true);
      final initial = controller(tester);
      initial.perform(
        PaymentAction.approveSettlement,
        initial.settlements.first.id,
      );
      await tester.pumpAndSettle();
      await tap(tester, find.text('Overview'));
      await tap(tester, find.widgetWithText(TextButton, 'Payments'));
      expect(identical(initial, controller(tester)), true);
      await tab(tester, true);
      expect(find.text('APPROVED'), findsOneWidget);
      await tap(tester, find.text('Sign out'));
      expect(find.byType(SignInView), findsOneWidget);
      final go = GoRouter.of(tester.element(find.byType(SignInView)));
      for (final path in [
        AppRouter.paymentsPath,
        AppRouter.settlementsPath,
        '${AppRouter.paymentsPath}/unknown',
      ]) {
        go.go(path);
        await tester.pumpAndSettle();
        expect(
          go.routeInformationProvider.value.uri.path,
          AppRouter.signInPath,
        );
      }
      tester
          .element(find.byType(SignInView))
          .read<DemoSessionController>()
          .startSession(persistent: false);
      await tester.pumpAndSettle();
      go.go(AppRouter.settlementsPath);
      await tester.pumpAndSettle();
      expect(
        controller(tester).settlements.first.status,
        SettlementStatus.draft,
      );
      expect(controller(tester).activity, isEmpty);
    },
  );

  for (final size in [
    const Size(1440, 1000),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 700),
    const Size(320, 650),
  ]) {
    testWidgets(
      'Payments, settlements, filters and confirmation dialogs fit at $size',
      (tester) async {
        viewport(tester, size, scale: size.width < 800 ? 1.5 : 1);
        await openPayments(tester);
        await invoiceAction(tester, 0);
        expect(tester.takeException(), isNull);
        await confirm(tester);
        expect(tester.takeException(), isNull);
        router(tester).go(AppRouter.settlementsPath);
        await tester.pumpAndSettle();
        final id = controller(tester).settlements.first.id;
        await tap(tester, find.byKey(ValueKey('approve-$id')));
        expect(tester.takeException(), isNull);
        await confirm(tester);
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        await tap(tester, find.text('Demo bank result'));
        expect(tester.takeException(), isNull);
        await tap(tester, find.byKey(const ValueKey('demo-bank-success')));
        expect(tester.takeException(), isNull);
        await tap(tester, find.text('Cancel'));
        await tap(tester, find.byKey(const ValueKey('payment-filters-toggle')));
        await tester.enterText(
          find.byKey(const ValueKey('payment-search')),
          'Kumari',
        );
        await tester.pumpAndSettle();
        expect(
          controller(tester).filteredSettlements.single.driver,
          'Kumari Wickramasinghe',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
