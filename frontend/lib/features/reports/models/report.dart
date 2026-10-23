enum ReportType {
  attendance('Attendance', 'Boarded, dropped and absent days per student'),
  trips('Trips & on-time', 'Every trip, delays and GPS gaps by route'),
  payments('Payments', 'Invoices, collections, overdue and payouts'),
  drivers('Driver performance', 'Ratings, complaints, on-time and expiries'),
  incidents('Incidents & SOS', 'All SOS alerts with response times'),
  students('Students by vehicle', 'Which child rides in which vehicle');

  const ReportType(this.label, this.description);
  final String label, description;
}

enum ReportFormat {
  pdf('PDF', 'pdf', 'application/pdf'),
  excel('Excel', 'xml', 'application/vnd.ms-excel'),
  csv('CSV', 'csv', 'text/csv');

  const ReportFormat(this.label, this.extension, this.mimeType);
  final String label, extension, mimeType;
}

class ReportEntry {
  const ReportEntry({
    required this.type,
    required this.date,
    required this.school,
    required this.values,
  });
  final ReportType type;
  final DateTime date;
  final String school;
  final List<String> values;
}

class GeneratedReport {
  GeneratedReport({
    required this.id,
    required this.type,
    required this.format,
    required this.from,
    required this.to,
    required this.school,
    required this.period,
    required this.created,
    required List<List<String>> rows,
    required List<String> headers,
  }) : rows = List.unmodifiable(
         rows.map((row) => List<String>.unmodifiable(row)),
       ),
       headers = List.unmodifiable(headers);
  final String id, period, created;
  final ReportType type;
  final ReportFormat format;
  final DateTime from, to;
  final String? school;
  final List<String> headers;
  final List<List<String>> rows;
  String get filename => 'novasys-${type.name}-$id.${format.extension}';
}

String reportDate(DateTime date) =>
    '${date.day} ${reportMonths[date.month - 1]} ${date.year}';
const reportMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
