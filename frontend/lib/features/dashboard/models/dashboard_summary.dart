/// Presentation-independent dashboard records. All values are local mock data.
enum DashboardTone { neutral, teal, success, warning, danger, orange }

class SummaryMetric {
  const SummaryMetric(
    this.label,
    this.value,
    this.description, {
    this.tone = DashboardTone.neutral,
    required this.detail,
  });
  final String label;
  final String value;
  final String description;
  final DashboardTone tone;
  final String detail;
}

class AttentionItem {
  const AttentionItem(
    this.count,
    this.title,
    this.description,
    this.tone,
    this.detail,
  );
  final int count;
  final String title;
  final String description;
  final DashboardTone tone;
  final String detail;
}

class TransportDay {
  const TransportDay(this.label, this.count);
  final String label;
  final int count;
}

class DashboardTrip {
  const DashboardTrip({
    required this.driver,
    required this.vehicle,
    required this.route,
    required this.onboard,
    required this.gps,
    required this.eta,
    required this.status,
    required this.tone,
    this.gpsStale = false,
  });
  final String driver;
  final String vehicle;
  final String route;
  final String onboard;
  final String gps;
  final String eta;
  final String status;
  final DashboardTone tone;
  final bool gpsStale;
}

class DashboardIncident {
  const DashboardIncident({
    required this.driver,
    required this.vehicle,
    required this.students,
    required this.location,
    required this.age,
  });
  final String driver;
  final String vehicle;
  final int students;
  final String location;
  final String age;
  String get headline =>
      'SOS · Breakdown · $driver ($vehicle) · $students students on board · $location · $age';
}
