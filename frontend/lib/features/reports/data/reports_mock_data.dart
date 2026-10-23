import '../models/report.dart';

const reportSchools = ['Visakha', 'Royal', 'St. Bridget’s'];

List<String> reportHeaders(ReportType type) => switch (type) {
  ReportType.attendance => [
    'Date',
    'School',
    'Student',
    'Boarded',
    'Dropped',
    'Absent',
  ],
  ReportType.trips => [
    'Date',
    'School',
    'Route',
    'Trips',
    'On-time',
    'Delay (min)',
    'GPS gaps',
  ],
  ReportType.payments => [
    'Date',
    'School',
    'Invoice',
    'Collected (LKR)',
    'Overdue (LKR)',
    'Payout (LKR)',
  ],
  ReportType.drivers => [
    'Date',
    'School',
    'Driver',
    'Rating',
    'Complaints',
    'On-time (%)',
    'Licence expiry',
  ],
  ReportType.incidents => [
    'Date',
    'School',
    'Alert',
    'Vehicle',
    'Response (sec)',
    'Status',
  ],
  ReportType.students => ['Date', 'School', 'Student', 'Vehicle', 'Driver'],
};

// Deterministic, fictional daily records; no connected analytics services.
List<ReportEntry> createMockReportEntries() => [
  for (final month in [9, 10])
    for (var day = 1; day <= (month == 9 ? 30 : 19); day++)
      if (DateTime(2026, month, day).weekday <= DateTime.friday)
        for (var school = 0; school < reportSchools.length; school++)
          for (final type in ReportType.values)
            if (type != ReportType.incidents || day % 9 == 0)
              ReportEntry(
                type: type,
                date: DateTime(2026, month, day),
                school: reportSchools[school],
                values: switch (type) {
                  ReportType.attendance => [
                    [
                      'Sanuli Perera',
                      'Kavin Perera',
                      'Nethmi Fernando',
                    ][school],
                    day % 7 == 0 ? '0' : '1',
                    day % 7 == 0 ? '0' : '1',
                    day % 7 == 0 ? '1' : '0',
                  ],
                  ReportType.trips => [
                    'Route ${school + 1}',
                    '2',
                    day % 5 == 0 ? '1' : '2',
                    day % 5 == 0 ? '8' : '0',
                    day % 11 == 0 ? '1' : '0',
                  ],
                  ReportType.payments => [
                    'INV-$month-$day-${school + 1}',
                    '${9000 + school * 1500}',
                    day % 5 == 0 ? '3000' : '0',
                    '${8100 + school * 1350}',
                  ],
                  ReportType.drivers => [
                    ['Ruwan J.', 'Kumari W.', 'Dilshan F.'][school],
                    ['4.8', '4.7', '4.9'][school],
                    day % 13 == 0 ? '1' : '0',
                    '${94 + school}',
                    '31 Dec 2027',
                  ],
                  ReportType.incidents => [
                    'SOS-${school + 1}-$day',
                    ['WP PH-4521', 'WP NB-7731', 'WP CAB-1190'][school],
                    '${45 + school * 12}',
                    'Resolved',
                  ],
                  ReportType.students => [
                    [
                      'Sanuli Perera',
                      'Kavin Perera',
                      'Nethmi Fernando',
                    ][school],
                    ['WP PH-4521', 'WP PH-4521', 'No vehicle'][school],
                    ['Ruwan J.', 'Ruwan J.', 'Request pending'][school],
                  ],
                },
              ),
];

List<GeneratedReport> createMockReportHistory(List<ReportEntry> entries) => [
  for (final item in [
    (ReportType.payments, ReportFormat.excel, 'Sep 2026', '1 Oct · Shehani K.'),
    (ReportType.attendance, ReportFormat.pdf, 'Sep 2026', '1 Oct · Shehani K.'),
    (ReportType.incidents, ReportFormat.pdf, 'Term 3', '28 Sep · Kavindu H.'),
  ])
    GeneratedReport(
      id: 'sample-${item.$1.name}',
      type: item.$1,
      format: item.$2,
      from: DateTime(2026, 9),
      to: DateTime(2026, 9, item.$1 == ReportType.incidents ? 28 : 30),
      school: null,
      period: item.$3,
      created: item.$4,
      headers: reportHeaders(item.$1),
      rows: [
        for (final entry in entries)
          if (entry.type == item.$1 &&
              entry.date.month == 9 &&
              (item.$1 != ReportType.incidents || entry.date.day <= 28))
            [reportDate(entry.date), entry.school, ...entry.values],
      ],
    ),
];
