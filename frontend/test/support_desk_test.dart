import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:novasys_admin_web/features/support/controllers/support_controller.dart';
import 'package:novasys_admin_web/features/support/models/support_ticket.dart';
import 'package:novasys_admin_web/features/support/views/support_view.dart';
import 'package:novasys_admin_web/features/auth/controllers/demo_session_controller.dart';
import 'package:novasys_admin_web/features/auth/views/sign_in_view.dart';

import 'support/test_app.dart';

void main() {
  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = size.width < 800
        ? 1.5
        : 1;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(authenticatedApp());
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/support');
    await tester.pumpAndSettle();
  }

  SupportController controller(WidgetTester tester) =>
      tester.element(find.byType(SupportView)).read<SupportController>();
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('confirmation cancellation, reassignment, reply and resolution', (
    tester,
  ) async {
    await open(tester, const Size(1440, 1000));
    final c = controller(tester);
    await tap(tester, find.text('Approve reassignment'));
    await tap(tester, find.text('Cancel'));
    expect(c.selected!.reassignmentApproved, false);
    await tap(tester, find.text('Approve reassignment'));
    await tap(tester, find.byKey(const ValueKey('support-confirm')));
    expect(c.selected!.reassignmentApproved, true);
    await tester.enterText(
      find.byKey(const ValueKey('support-reply')),
      'We have recorded your request.',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Reply'));
    await tap(tester, find.text('Cancel'));
    expect(c.selected!.messages, hasLength(3));
    await tap(tester, find.widgetWithText(FilledButton, 'Reply'));
    await tap(tester, find.byKey(const ValueKey('support-confirm')));
    expect(c.selected!.messages.last.body, 'We have recorded your request.');
    await tap(tester, find.text('Resolve'));
    await tap(tester, find.byKey(const ValueKey('support-confirm')));
    expect(c.selected!.status, TicketStatus.resolved);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('support-reply')))
          .enabled,
      false,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('selection, search, empty state and sidebar state preservation', (
    tester,
  ) async {
    await open(tester, const Size(1440, 1000));
    await tap(tester, find.byKey(const ValueKey('ticket-T-1046')));
    expect(controller(tester).selected!.role, 'Driver');
    await tap(tester, find.byTooltip('Search & filter tickets'));
    await tester.enterText(
      find.byKey(const ValueKey('support-search')),
      'missing',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No matching tickets. Try clearing filters.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Clear filters'));
    expect(controller(tester).filteredTickets, hasLength(4));
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('support-search')))
          .controller!
          .text,
      isEmpty,
    );
    await tap(tester, find.byType(DropdownButtonFormField<TicketStatus>));
    await tap(tester, find.text('ACTIVE').last);
    expect(controller(tester).filteredTickets, hasLength(2));
    await tap(tester, find.byType(DropdownButtonFormField<String>));
    await tap(tester, find.text('Account').last);
    expect(controller(tester).filteredTickets.single.id, 'T-1046');
    final c = controller(tester);
    await tap(tester, find.text('Overview'));
    await tap(tester, find.text('Support'));
    expect(identical(controller(tester), c), true);
    expect(controller(tester).selected!.id, 'T-1046');
  });
  testWidgets(
    'ticket drafts persist independently and empty replies are rejected',
    (tester) async {
      await open(tester, const Size(1440, 1000));
      await tap(tester, find.widgetWithText(FilledButton, 'Reply'));
      expect(find.text('Write a reply before continuing.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('support-reply')),
        'Draft for Thisal',
      );
      await tap(tester, find.byKey(const ValueKey('ticket-T-1046')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('support-reply')))
            .controller!
            .text,
        isEmpty,
      );
      await tap(tester, find.byKey(const ValueKey('ticket-T-1058')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('support-reply')))
            .controller!
            .text,
        'Draft for Thisal',
      );
    },
  );
  testWidgets('support routes are guarded and mock changes reset on logout', (
    tester,
  ) async {
    await open(tester, const Size(1440, 1000));
    final c = controller(tester);
    c.resolve('T-1058');
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(SupportView)));
    await tap(tester, find.text('Sign out'));
    for (final path in ['/support', '/support/unknown']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(SignInView), findsOneWidget);
    }
    tester
        .element(find.byType(SignInView))
        .read<DemoSessionController>()
        .startSession(persistent: false);
    await tester.pumpAndSettle();
    router.go('/support');
    await tester.pumpAndSettle();
    expect(controller(tester).selected!.status, TicketStatus.waiting);
  });
  for (final size in [
    const Size(1440, 1000),
    const Size(1280, 800),
    const Size(1024, 800),
    const Size(768, 800),
    const Size(375, 800),
    const Size(320, 700),
  ]) {
    testWidgets('Support layout and dialogs fit $size', (tester) async {
      await open(tester, size);
      await tap(tester, find.text('Approve reassignment'));
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Cancel'));
      await tap(tester, find.byTooltip('Search & filter tickets').first);
      expect(tester.takeException(), isNull);
    });
  }
}
