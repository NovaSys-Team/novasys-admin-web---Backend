enum SchoolEventKind { noTrip, exams }

class SchoolCalendarEvent {
  const SchoolCalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.school,
    required this.description,
    required this.kind,
    this.afternoonPickup,
  });
  static const allSchools = 'All schools';
  final String id, school, description;
  final DateTime start, end;
  final SchoolEventKind kind;
  final String? afternoonPickup;
  bool includes(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }
}
