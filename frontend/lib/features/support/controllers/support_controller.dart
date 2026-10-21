import 'package:flutter/foundation.dart';

import '../data/support_mock_data.dart';
import '../models/support_ticket.dart';

class SupportController extends ChangeNotifier {
  final List<SupportTicket> _tickets = createSupportTickets();
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);
  String _selectedId = 'T-1058';
  String query = '';
  TicketStatus? statusFilter;
  String? categoryFilter;
  bool filtersVisible = false;
  final Map<String, String> _drafts = {};
  String draftFor(String id) => _drafts[id] ?? '';
  void saveDraft(String id, String text) => _drafts[id] = text;
  SupportTicket? get selected =>
      _tickets.where((t) => t.id == _selectedId).firstOrNull;
  List<SupportTicket> get filteredTickets => _tickets.where((t) {
    final search = query.trim().toLowerCase();
    return (statusFilter == null || t.status == statusFilter) &&
        (categoryFilter == null || t.category == categoryFilter) &&
        '${t.id} ${t.subject} ${t.requester} ${t.category} ${t.role}'
            .toLowerCase()
            .contains(search);
  }).toList();
  void select(String id) {
    if (!_tickets.any((t) => t.id == id)) return;
    _selectedId = id;
    notifyListeners();
  }

  void toggleFilters() {
    filtersVisible = !filtersVisible;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void filterStatus(TicketStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void filterCategory(String? value) {
    categoryFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    statusFilter = null;
    categoryFilter = null;
    notifyListeners();
  }

  bool reply(String id, String body) {
    final t = _tickets.where((t) => t.id == id).firstOrNull;
    if (t == null || t.status == TicketStatus.resolved || body.trim().isEmpty) {
      return false;
    }
    t.messages.add(SupportMessage('Admin (demo)', body.trim()));
    _drafts.remove(id);
    t.status = TicketStatus.active;
    t.assignedTo = 'Admin';
    notifyListeners();
    return true;
  }

  bool resolve(String id) {
    final t = _tickets.where((t) => t.id == id).firstOrNull;
    if (t == null || t.status == TicketStatus.resolved) return false;
    t.status = TicketStatus.resolved;
    notifyListeners();
    return true;
  }

  bool approveReassignment(String id) {
    final t = _tickets.where((t) => t.id == id).firstOrNull;
    if (t == null ||
        !t.reassignment ||
        t.reassignmentApproved ||
        t.status == TicketStatus.resolved) {
      return false;
    }
    t.reassignmentApproved = true;
    t.status = TicketStatus.active;
    t.assignedTo = 'Admin';
    t.messages.add(
      const SupportMessage(
        'Admin (demo)',
        'Reassignment approved locally. A mock request to Kumari W. for 1 Nov has been recorded.',
      ),
    );
    notifyListeners();
    return true;
  }
}
