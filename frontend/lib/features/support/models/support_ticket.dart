enum TicketStatus {
  waiting('WAITING FOR ADMIN'),
  active('ACTIVE'),
  resolved('RESOLVED');

  const TicketStatus(this.label);
  final String label;
}

class SupportMessage {
  const SupportMessage(this.author, this.body);
  final String author;
  final String body;
}

class SupportTicket {
  SupportTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.age,
    required this.role,
    required this.requester,
    required this.student,
    required this.driver,
    required this.status,
    required List<SupportMessage> messages,
    this.reassignment = false,
  }) : messages = List.of(messages);
  final String id, category, subject, age, role, requester, student, driver;
  TicketStatus status;
  final List<SupportMessage> messages;
  final bool reassignment;
  bool reassignmentApproved = false;
  String assignedTo = 'Unassigned';
}
