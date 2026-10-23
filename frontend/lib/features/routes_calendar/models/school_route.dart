enum TripPeriod { morning, afternoon }

enum StopKind { depot, pickup, school }

class RouteStop {
  const RouteStop({
    required this.title,
    required this.description,
    required this.time,
    required this.kind,
    this.absent = false,
    this.schools = const [],
  });
  final String title, description, time;
  final StopKind kind;
  final bool absent;
  final List<String> schools;
}

class SchoolRoute {
  const SchoolRoute({
    required this.id,
    required this.origin,
    required this.destinations,
    required this.schools,
    required this.driver,
    required this.plate,
    required this.version,
    required this.morningStops,
    required this.afternoonStops,
  });
  final String id, origin, destinations, driver, plate;
  final int version;
  final List<String> schools;
  final List<RouteStop> morningStops, afternoonStops;
  List<RouteStop> stopsFor(TripPeriod period) =>
      period == TripPeriod.morning ? morningStops : afternoonStops;
}
