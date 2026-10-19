import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/live_trips/controllers/live_trips_controller.dart';
import 'package:novasys_admin_web/features/live_trips/models/live_trip.dart';
import 'package:novasys_admin_web/features/live_trips/models/trip_incident.dart';
import 'package:novasys_admin_web/features/live_trips/models/live_trips_mock_data.dart';

void main() {
  late LiveTripsController controller;
  setUp(() => controller = LiveTripsController());
  tearDown(() => controller.dispose());
  test('Initial mock counts and selected incident match A03', () {
    expect(controller.trips, hasLength(18));
    expect(controller.runningCount, 18);
    expect(controller.count(TripCondition.onTime), 14);
    expect(controller.count(TripCondition.late), 2);
    expect(controller.count(TripCondition.gpsStale), 1);
    expect(controller.count(TripCondition.sos), 1);
    expect(controller.activeIncidentCount, 1);
    expect(controller.selectedIncident.id, 'INC-2026-0087');
    expect(controller.selectedIncident.events, hasLength(1));
    expect(controller.mapTrips, hasLength(12));
  });
  test('Acknowledgement appends A03.2 events once and leaves other records unchanged', () {
    expect(controller.acknowledgeIncident('INC-2026-0087'), isTrue);
    expect(controller.selectedIncident.status, IncidentStatus.acknowledged);
    expect(controller.selectedIncident.events.map((event) => event.time), [
      '07:12',
      '07:13',
      '07:16',
      '07:17',
    ]);
    expect(controller.tripStatus(controller.incidentTrip), 'SOS acknowledged');
    expect(controller.activeIncidentCount, 1);
    expect(controller.acknowledgeIncident('INC-2026-0087'), isFalse);
    expect(controller.selectedIncident.events, hasLength(4));
    expect(controller.incidents[1].events, hasLength(2));
  });
  test('Resolution requires acknowledgement and a nonempty note', () {
    expect(controller.resolveIncident('INC-2026-0087', 'Done'), isFalse);
    expect(controller.selectedIncident.status, IncidentStatus.open);
    controller.acknowledgeIncident('INC-2026-0087');
    expect(controller.resolveIncident('INC-2026-0087', '   '), isFalse);
    expect(controller.actionError, 'Add a resolution note.');
    expect(controller.selectedIncident.status, IncidentStatus.acknowledged);
  });
  test(
    'Resolution matches A03.3 and updates running, SOS and completed counts',
    () {
      controller.acknowledgeIncident('INC-2026-0087');
      expect(
        controller.resolveIncident(
          'INC-2026-0087',
          LiveTripsMockData.defaultResolution,
        ),
        isTrue,
      );
      expect(controller.selectedIncident.status, IncidentStatus.resolved);
      expect(controller.selectedIncident.events.last.time, '07:41');
      expect(controller.selectedIncident.events, hasLength(5));
      expect(
        controller.selectedIncident.resolution,
        LiveTripsMockData.defaultResolution,
      );
      expect(controller.activeIncidentCount, 0);
      expect(controller.count(TripCondition.sos), 0);
      expect(controller.runningCount, 17);
      expect(controller.incidentTrip.condition, TripCondition.completed);
      expect(controller.incidentTrip.eta, 'At school');
      expect(controller.resolveIncident('INC-2026-0087', 'Repeat'), isFalse);
      expect(controller.selectedIncident.events, hasLength(5));
    },
  );
  test(
    'Search and filters combine and leave the incident independently selected',
    () {
      controller.setFilter(TripFilter.onTime);
      expect(controller.filteredTrips, hasLength(14));
      controller.setQuery(' KUMARI ');
      expect(controller.filteredTrips.single.id, 'kumari');
      controller.setFilter(TripFilter.sos);
      expect(controller.filteredTrips, isEmpty);
      expect(controller.selectedIncident.id, 'INC-2026-0087');
      controller.clearFilters();
      controller.setQuery('PH–4521');
      expect(controller.filteredTrips.single.id, 'ruwan');
      controller.clearFilters();
      expect(controller.filteredTrips, hasLength(18));
    },
  );
  test('Sorting toggles direction, pagination is bounded and filters reset the page', () {
    expect(controller.pageTrips, hasLength(5));
    expect(controller.pageCount, 4);
    controller.setPage(3);
    expect(controller.pageTrips, hasLength(3));
    controller.setPage(4);
    expect(controller.page, 3);
    controller.sortBy(TripSortField.driver);
    expect(controller.page, 0);
    expect(controller.pageTrips.first.driver, 'Amila Fernando');
    controller.sortBy(TripSortField.driver);
    expect(controller.pageTrips.first.driver, 'Sunil Perera');
    controller.sortBy(TripSortField.onboard);
    expect(controller.pageTrips.first.onboard, 8);
    controller.setPage(2);
    controller.setFilter(TripFilter.gpsStale);
    expect(controller.page, 0);
    expect(controller.pageTrips.single.id, 'dilshan');
  });
  test('Trip and incident selection handles historical records and unknown IDs safely', () {
    controller.selectTrip('kumari');
    expect(controller.selectedIncident.id, 'INC-2026-0081');
    controller.selectTrip('dilshan');
    expect(controller.selectedTripId, 'dilshan');
    expect(controller.selectedIncident.id, 'INC-2026-0081');
    controller.selectIncident('INC-2026-0087');
    expect(controller.selectedTripId, 'ruwan');
    controller.selectIncident('unknown');
    controller.selectTrip('unknown');
    expect(controller.selectedTripId, 'ruwan');
    expect(controller.acknowledgeIncident('unknown'), isFalse);
    expect(controller.resolveIncident('unknown', 'Resolved'), isFalse);
  });
  test('Live search preserves spaces while matching multiple words', () {
    controller.setQuery('Ruwan ');
    expect(controller.query, 'Ruwan ');
    expect(controller.filteredTrips.single.id, 'ruwan');
    controller.setQuery('Ruwan J');
    expect(controller.filteredTrips.single.id, 'ruwan');
  });
  test(
    'Mock refresh preserves snapshots and public collections are immutable',
    () {
      final before = controller.trips.first;
      controller.refreshMockSnapshot();
      expect(controller.refreshCount, 1);
      expect(identical(controller.trips.first, before), isTrue);
      expect(() => controller.trips.clear(), throwsUnsupportedError);
      expect(() => controller.incidents.clear(), throwsUnsupportedError);
    },
  );
}
