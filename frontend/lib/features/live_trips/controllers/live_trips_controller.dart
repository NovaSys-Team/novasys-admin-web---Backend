import 'package:flutter/foundation.dart';

import '../models/live_trip.dart';
import '../models/trip_incident.dart';
import '../models/live_trips_mock_data.dart';

class LiveTripsController extends ChangeNotifier {
  final List<LiveTrip> _trips = List.of(LiveTripsMockData.trips);
  final List<TripIncident> _incidents = List.of(
    LiveTripsMockData.initialIncidents,
  );
  String _selectedIncidentId = LiveTripsMockData.initialIncidents.first.id;
  String _selectedTripId = LiveTripsMockData.trips.first.id;
  String _query = '';
  TripFilter _filter = TripFilter.all;
  TripSortField? _sortField;
  bool _ascending = true;
  int _page = 0;
  int _refreshCount = 0;
  String? _actionError;
  static const pageSize = 5;
  List<LiveTrip> get trips => List.unmodifiable(_trips);
  List<TripIncident> get incidents => List.unmodifiable(_incidents);
  TripIncident get selectedIncident =>
      _incidents.firstWhere((incident) => incident.id == _selectedIncidentId);
  LiveTrip get incidentTrip =>
      _trips.firstWhere((trip) => trip.id == selectedIncident.tripId);
  String get selectedTripId => _selectedTripId;
  String get query => _query;
  TripFilter get filter => _filter;
  TripSortField? get sortField => _sortField;
  bool get ascending => _ascending;
  int get page => _page;
  int get refreshCount => _refreshCount;
  String? get actionError => _actionError;
  int get activeIncidentCount =>
      _incidents.where((incident) => incident.isActive).length;
  int get runningCount =>
      _trips.where((trip) => trip.condition != TripCondition.completed).length;
  int count(TripCondition condition) =>
      _trips.where((trip) => trip.condition == condition).length;
  bool get hasFilters => _query.trim().isNotEmpty || _filter != TripFilter.all;
  String get subtitle =>
      'Morning session · $runningCount vans running · refreshed every 10 s';
  TripIncident? incidentForTrip(String id) {
    for (final incident in _incidents) {
      if (incident.tripId == id) return incident;
    }
    return null;
  }

  String tripStatus(LiveTrip trip) =>
      trip.condition == TripCondition.sos &&
          incidentForTrip(trip.id)?.status == IncidentStatus.acknowledged
      ? 'SOS acknowledged'
      : trip.statusLabel;
  List<LiveTrip> get filteredTrips {
    final result = _trips.where((trip) {
      final text =
          '${trip.driver} ${trip.vehicle} ${trip.route} ${trip.location}'
              .toLowerCase();
      if (!text.contains(_query.trim().toLowerCase())) return false;
      return _filter == TripFilter.all || trip.condition.name == _filter.name;
    }).toList();
    if (_sortField != null) {
      result.sort((a, b) {
        final comparison = switch (_sortField!) {
          TripSortField.driver => a.driver.compareTo(b.driver),
          TripSortField.vehicle => a.vehicle.compareTo(b.vehicle),
          TripSortField.route => a.route.compareTo(b.route),
          TripSortField.onboard => a.onboard.compareTo(b.onboard),
          TripSortField.gps => a.gpsSeconds.compareTo(b.gpsSeconds),
          TripSortField.eta => a.eta.compareTo(b.eta),
          TripSortField.status => tripStatus(a).compareTo(tripStatus(b)),
        };
        final stable = comparison == 0 ? a.id.compareTo(b.id) : comparison;
        return _ascending ? stable : -stable;
      });
    }
    return List.unmodifiable(result);
  }

  List<LiveTrip> get mapTrips =>
      filteredTrips.where((trip) => trip.visibleOnMap).toList(growable: false);
  List<LiveTrip> get pageTrips => filteredTrips
      .skip(_page * pageSize)
      .take(pageSize)
      .toList(growable: false);
  int get pageCount => (filteredTrips.length / pageSize).ceil().clamp(1, 1000);
  void setQuery(String value) {
    _query = value;
    _page = 0;
    notifyListeners();
  }

  void setFilter(TripFilter value) {
    _filter = value;
    _page = 0;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _filter = TripFilter.all;
    _page = 0;
    notifyListeners();
  }

  void sortBy(TripSortField field) {
    _ascending = _sortField == field ? !_ascending : true;
    _sortField = field;
    _page = 0;
    notifyListeners();
  }

  void setPage(int value) {
    if (value < 0 || value >= pageCount) return;
    _page = value;
    notifyListeners();
  }

  void refreshMockSnapshot() {
    _refreshCount++;
    notifyListeners();
  }

  void selectIncident(String id) {
    if (!_incidents.any((incident) => incident.id == id)) return;
    _selectedIncidentId = id;
    _selectedTripId = selectedIncident.tripId;
    _actionError = null;
    notifyListeners();
  }

  void selectTrip(String id) {
    if (!_trips.any((trip) => trip.id == id)) return;
    _selectedTripId = id;
    final incident = incidentForTrip(id);
    if (incident != null) _selectedIncidentId = incident.id;
    _actionError = null;
    notifyListeners();
  }

  bool acknowledgeIncident(String id) {
    final index = _incidents.indexWhere((incident) => incident.id == id);
    if (index < 0 || _incidents[index].status != IncidentStatus.open) {
      _actionError = 'Only an open demo incident can be acknowledged.';
      notifyListeners();
      return false;
    }
    final incident = _incidents[index];
    _incidents[index] = incident.copyWith(
      status: IncidentStatus.acknowledged,
      events: [...incident.events, ...LiveTripsMockData.acknowledgementEvents],
    );
    _actionError = null;
    notifyListeners();
    return true;
  }

  bool resolveIncident(String id, String resolution) {
    final index = _incidents.indexWhere((incident) => incident.id == id);
    if (index < 0 || _incidents[index].status != IncidentStatus.acknowledged) {
      _actionError = 'Acknowledge the demo incident before resolving it.';
      notifyListeners();
      return false;
    }
    if (resolution.trim().isEmpty) {
      _actionError = 'Add a resolution note.';
      notifyListeners();
      return false;
    }
    final incident = _incidents[index];
    _incidents[index] = incident.copyWith(
      status: IncidentStatus.resolved,
      resolution: resolution.trim(),
      events: [
        ...incident.events,
        const IncidentEvent('07:41', 'Resolved · students at school'),
      ],
    );
    final tripIndex = _trips.indexWhere((trip) => trip.id == incident.tripId);
    if (tripIndex >= 0) _trips[tripIndex] = _trips[tripIndex].completed();
    _page = _page.clamp(0, pageCount - 1);
    _actionError = null;
    notifyListeners();
    return true;
  }
}
