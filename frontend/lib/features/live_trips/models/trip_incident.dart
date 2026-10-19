enum IncidentStatus { open, acknowledged, resolved }

class IncidentEvent {
  const IncidentEvent(this.time, this.description);
  final String time;
  final String description;
}

class TripIncident {
  const TripIncident({
    required this.id,
    required this.tripId,
    required this.title,
    required this.status,
    required this.events,
    this.age = '1 min',
    this.resolution = '',
    this.standbyVehicle = '',
    this.standbyEtaMinutes = 0,
    this.notifiedParentCount = 0,
    this.suggestedResolution = '',
  });
  final String id;
  final String tripId;
  final String title;
  final IncidentStatus status;
  final List<IncidentEvent> events;
  final String age;
  final String resolution;
  final String standbyVehicle;
  final int standbyEtaMinutes;
  final int notifiedParentCount;
  final String suggestedResolution;
  bool get isActive => status != IncidentStatus.resolved;
  String get badge => switch (status) {
    IncidentStatus.open => 'OPEN · ${age.toUpperCase()}',
    IncidentStatus.acknowledged => 'ACKNOWLEDGED',
    IncidentStatus.resolved => 'RESOLVED',
  };
  TripIncident copyWith({
    IncidentStatus? status,
    List<IncidentEvent>? events,
    String? resolution,
  }) => TripIncident(
    id: id,
    tripId: tripId,
    title: title,
    status: status ?? this.status,
    events: events == null ? this.events : List.unmodifiable(events),
    age: age,
    resolution: resolution ?? this.resolution,
    standbyVehicle: standbyVehicle,
    standbyEtaMinutes: standbyEtaMinutes,
    notifiedParentCount: notifiedParentCount,
    suggestedResolution: suggestedResolution,
  );
}
