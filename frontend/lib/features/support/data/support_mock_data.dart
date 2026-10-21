import '../models/support_ticket.dart';

List<SupportTicket> createSupportTickets() => [
  SupportTicket(
    id: 'T-1058',
    category: 'Driver / route',
    subject: 'Request to change driver',
    age: '12 min',
    role: 'Parent',
    requester: 'Chathura Gunawardena',
    student: 'Thisal G. · Grade 7',
    driver: 'Ruwan J.',
    status: TicketStatus.waiting,
    reassignment: true,
    messages: const [
      SupportMessage(
        'Assistant (auto)',
        'Driver changes after approval need an admin. I’ve added you to the queue.',
      ),
      SupportMessage(
        'Parent',
        'We are moving to Battaramulla from November. Ruwan’s route doesn’t cover it. Can Thisal switch to Kumari’s van?',
      ),
    ],
  ),
  SupportTicket(
    id: 'T-1051',
    category: 'Complaint',
    subject: 'Van arrived 20 min late twice',
    age: '3 d',
    role: 'Parent',
    requester: 'Nimali Perera',
    student: 'Amaya P. · Grade 5',
    driver: 'Asanka P.',
    status: TicketStatus.active,
    messages: const [
      SupportMessage(
        'Parent',
        'The van arrived 20 minutes late twice this week. Please help us check the pickup time.',
      ),
    ],
  ),
  SupportTicket(
    id: 'T-1049',
    category: 'Payment',
    subject: 'Paid but invoice still pending',
    age: '1 d',
    role: 'Parent',
    requester: 'Dilini Silva',
    student: 'Senuli S. · Grade 6',
    driver: 'Kumari W.',
    status: TicketStatus.waiting,
    messages: const [
      SupportMessage(
        'Parent',
        'I paid the invoice, but it still shows as pending. Could you check?',
      ),
    ],
  ),
  SupportTicket(
    id: 'T-1046',
    category: 'Account',
    subject: 'Cannot upload insurance file',
    age: '2 d',
    role: 'Driver',
    requester: 'Ruwan Jayasinghe',
    student: '—',
    driver: 'Ruwan J.',
    status: TicketStatus.active,
    messages: const [
      SupportMessage(
        'Driver',
        'I cannot upload my insurance file. Please help me complete my documents.',
      ),
    ],
  ),
];
