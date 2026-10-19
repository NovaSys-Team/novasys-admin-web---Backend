enum TripCondition { onTime, late, gpsStale, sos, completed }

enum TripFilter { all, onTime, late, gpsStale, sos, completed }

enum TripSortField { driver, vehicle, route, onboard, gps, eta, status }

class LiveTrip {
  const LiveTrip({
    required this.id,
    required this.driver,
    required this.phone,
    required this.vehicle,
    required this.route,
    required this.onboard,
    required this.capacity,
    required this.schools,
    required this.gpsSeconds,
    required this.eta,
    required this.condition,
    required this.location,
    this.lateMinutes = 0,
    this.mapX,
    this.mapY,
  });
  final String id;
  final String driver;
  final String phone;
  final String vehicle;
  final String route;
  final int onboard;
  final int capacity;
  final int schools;
  final int gpsSeconds;
  final String eta;
  final TripCondition condition;
  final String location;
  final int lateMinutes;

  /// Coordinates in the local 670 x 622 illustrative map, not GPS coordinates.
  final double? mapX;
  final double? mapY;
  bool get visibleOnMap => mapX != null && mapY != null;
  String get gpsLabel => condition == TripCondition.gpsStale
      ? 'Last ${gpsSeconds ~/ 60} min ago'
      : 'Live · ${gpsSeconds}s';
  String get statusLabel => switch (condition) {
    TripCondition.onTime => 'On time',
    TripCondition.late => 'Running $lateMinutes min late',
    TripCondition.gpsStale => 'GPS stale',
    TripCondition.sos => 'SOS open',
    TripCondition.completed => 'Completed',
  };
  LiveTrip completed() => LiveTrip(
    id: id,
    driver: driver,
    phone: phone,
    vehicle: vehicle,
    route: route,
    onboard: onboard,
    capacity: capacity,
    schools: schools,
    gpsSeconds: gpsSeconds,
    eta: 'At school',
    condition: TripCondition.completed,
    location: location,
    lateMinutes: lateMinutes,
    mapX: mapX,
    mapY: mapY,
  );
}

extension TripFilterLabel on TripFilter {
  String get label => switch (this) {
    TripFilter.all => 'All trips',
    TripFilter.onTime => 'On time',
    TripFilter.late => 'Late',
    TripFilter.gpsStale => 'GPS stale',
    TripFilter.sos => 'SOS',
    TripFilter.completed => 'Completed',
  };
}
