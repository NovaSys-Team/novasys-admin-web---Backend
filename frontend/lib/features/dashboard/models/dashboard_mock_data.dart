import 'dashboard_summary.dart';

abstract final class DashboardMockData {
  static const incident = DashboardIncident(
    driver: 'Ruwan Jayasinghe',
    vehicle: 'WP PH–4521',
    students: 11,
    location: 'Nawala Rd',
    age: '1 min ago',
  );
  static const metrics = [
    SummaryMetric(
      'Trips running now',
      '18 / 42',
      '24 completed or scheduled',
      detail: '18 of 42 mock trips are running. The other 24 are completed or scheduled.',
    ),
    SummaryMetric(
      'Students on board',
      '214',
      '12 absent today',
      detail: '214 students are on board across the mock fleet. 12 students are marked absent today.',
    ),
    SummaryMetric(
      'On-time arrivals (7 days)',
      '94%',
      '2 pts vs last week',
      tone: DashboardTone.success,
      detail: 'Mock on-time arrival rate is 94%, up from 92% last week.',
    ),
    SummaryMetric(
      'Pending verifications',
      '4',
      'Oldest waiting 2 days',
      tone: DashboardTone.warning,
      detail: '4 driver applications need review, including 1 re-upload. The oldest has waited 2 days.',
    ),
    SummaryMetric(
      'October collected',
      'LKR 4.2M',
      '78% of LKR 5.4M',
      detail: 'Mock October collections: LKR 4.2M of LKR 5.4M. No payments are processed here.',
    ),
    SummaryMetric(
      'Open support tickets',
      '9',
      '3 complaints',
      tone: DashboardTone.orange,
      detail: '9 mock support tickets are open, including 3 complaints.',
    ),
  ];
  static const attention = [
    AttentionItem(
      1,
      'Substitute needed Fri 23 Oct',
      'Ruwan J. on leave · 14 students',
      DashboardTone.orange,
      'A substitute is needed for Ruwan Jayasinghe on Friday 23 October. 14 students are assigned. This preview does not assign a driver.',
    ),
    AttentionItem(
      3,
      'Documents expiring in 30 days',
      'Fitness, insurance, revenue licence',
      DashboardTone.warning,
      '3 mock documents need renewal: fitness certificate, insurance and revenue licence. No documents are submitted from this preview.',
    ),
    AttentionItem(
      4,
      'Driver applications to review',
      'Includes 1 re-upload',
      DashboardTone.teal,
      '4 mock applications await review, including 1 re-upload. Approval workflows are not connected.',
    ),
    AttentionItem(
      23,
      'Overdue invoices',
      'LKR 195,500 outstanding',
      DashboardTone.danger,
      '23 mock invoices total LKR 195,500 outstanding. No payment or collection action is performed.',
    ),
    AttentionItem(
      2,
      'Driver change requests',
      'Parents asking to switch driver',
      DashboardTone.neutral,
      '2 mock requests from parents to switch drivers are waiting for review. No assignments are changed.',
    ),
  ];
  // Counts chosen to reproduce the outlined SVG bar heights (0–500 scale).
  static const days = [
    TransportDay('6 Oct', 452),
    TransportDay('7 Oct', 448),
    TransportDay('8 Oct', 455),
    TransportDay('9 Oct', 431),
    TransportDay('12 Oct', 450),
    TransportDay('13 Oct', 446),
    TransportDay('14 Oct', 458),
    TransportDay('15 Oct', 440),
    TransportDay('16 Oct', 397),
    TransportDay('19 Oct', 214),
  ];
  static const trips = [
    DashboardTrip(
      driver: 'Ruwan Jayasinghe',
      vehicle: 'WP PH–4521',
      route: 'Rajagiriya → Visakha, Royal',
      onboard: '11 / 11',
      gps: 'Live · 6s',
      eta: '—',
      status: 'SOS open',
      tone: DashboardTone.danger,
    ),
    DashboardTrip(
      driver: 'Kumari Wickramasinghe',
      vehicle: 'WP NB–7731',
      route: 'Kotte → St. Bridget’s',
      onboard: '19 / 21',
      gps: 'Live · 4s',
      eta: '07:22',
      status: 'On time',
      tone: DashboardTone.success,
    ),
    DashboardTrip(
      driver: 'Dilshan Fernando',
      vehicle: 'WP CAB–1190',
      route: 'Nugegoda → Visakha',
      onboard: '8 / 9',
      gps: 'Last 2 min ago',
      eta: '~07:31',
      status: 'GPS stale',
      tone: DashboardTone.warning,
      gpsStale: true,
    ),
    DashboardTrip(
      driver: 'Asanka Perera',
      vehicle: 'WP PE–3306',
      route: 'Dehiwala → Royal',
      onboard: '12 / 12',
      gps: 'Live · 9s',
      eta: '07:35',
      status: 'Running 6 min late',
      tone: DashboardTone.orange,
    ),
  ];
}
