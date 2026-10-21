import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/support/controllers/support_controller.dart';
import 'package:novasys_admin_web/features/support/models/support_ticket.dart';

void main() {
  late SupportController c;
  setUp(() => c = SupportController());
  tearDown(() => c.dispose());
  test('search and filters intersect and clearing restores inbox', () {
    c.search('  paid ');
    expect(c.filteredTickets.single.id, 'T-1049');
    c.filterStatus(TicketStatus.active);
    expect(c.filteredTickets, isEmpty);
    c.clearFilters();
    c.filterCategory('Account');
    expect(c.filteredTickets.single.role, 'Driver');
    c.clearFilters();
    expect(c.filteredTickets, hasLength(4));
  });
  test('selection validates IDs and state changes notify listeners', () {
    var notifications = 0;
    c.addListener(() => notifications++);
    c.select('invalid');
    expect(notifications, 0);
    c.select('T-1046');
    expect(c.selected!.id, 'T-1046');
    expect(c.reply('T-1046', '  Demo reply  '), true);
    expect(c.selected!.messages.last.body, 'Demo reply');
    expect(c.selected!.assignedTo, 'Admin');
    expect(notifications, 2);
  });
  test('reassignment and resolution prevent repeated or invalid mutations', () {
    expect(c.approveReassignment('T-1051'), false);
    expect(c.approveReassignment('T-1058'), true);
    expect(c.selected!.reassignmentApproved, true);
    expect(c.selected!.status, TicketStatus.active);
    expect(c.approveReassignment('T-1058'), false);
    expect(c.reply('T-1058', '  '), false);
    expect(c.resolve('T-1058'), true);
    expect(c.resolve('T-1058'), false);
    expect(c.reply('T-1058', 'Late reply'), false);
    expect(c.approveReassignment('missing'), false);
    expect(c.resolve('missing'), false);
    expect(c.reply('missing', 'Reply'), false);
  });
  test('mock changes are isolated between controller instances', () {
    c.resolve('T-1058');
    final other = SupportController();
    expect(other.selected!.status, TicketStatus.waiting);
    other.dispose();
  });
}
