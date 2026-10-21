import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/controllers/drivers_vehicles_controller.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/data/drivers_vehicles_mock_data.dart';
import 'package:novasys_admin_web/features/drivers_vehicles/models/driver_vehicle.dart';

void main() {
  late DriversVehiclesController c;
  setUp(() => c = DriversVehiclesController());
  tearDown(() => c.dispose());
  test('A06 initial fleet and document compliance rules', () {
    expect(c.records, hasLength(5));
    expect(c.verifiedCount, 42);
    expect(c.selected.plate, 'WP PH-4521');
    expect(c.records[0].canStartTrips, true);
    expect(c.records[3].canStartTrips, false);
    expect(c.records[4].canStartTrips, false);
  });
  test('search and intersecting status and worst compliance filters', () {
    c.search('  hiace ');
    expect(c.filteredRecords, hasLength(2));
    c.filterCompliance(ComplianceLevel.blocked);
    expect(c.filteredRecords.single.name, 'Asanka Perera');
    c.filterStatus(DriverStatus.suspended);
    expect(c.filteredRecords, isEmpty);
    c.clearFilters();
    c.filterCompliance(ComplianceLevel.warning);
    expect(c.filteredRecords, hasLength(2));
    c.clearFilters();
    c.search('wp nb-7731');
    expect(c.filteredRecords.single.id, 'DV-002');
    c.clearFilters();
    expect(c.filteredRecords, hasLength(5));
  });
  test(
    'status mutations require reasons, validate stale state and log activity',
    () {
      expect(c.changeStatus('DV-001', DriverStatus.verified, ' '), false);
      expect(c.changeStatus('missing', DriverStatus.verified, 'Reason'), false);
      expect(
        c.changeStatus('DV-001', DriverStatus.verified, 'Safety review'),
        true,
      );
      expect(c.selected.status, DriverStatus.suspended);
      expect(c.verifiedCount, 41);
      expect(c.activity.single.reason, 'Safety review');
      expect(
        c.changeStatus('DV-001', DriverStatus.verified, 'Stale request'),
        false,
      );
      expect(
        c.changeStatus('DV-001', DriverStatus.suspended, 'Review completed'),
        true,
      );
      expect(c.verifiedCount, 42);
      expect(
        c.changeStatus('DV-005', DriverStatus.suspended, 'Demo review'),
        true,
      );
      c.select('DV-005');
      expect(c.selected.canStartTrips, false);
    },
  );
  test(
    'only eligible known substitute covers both trips and is assigned once',
    () {
      expect(c.assignSubstitute(substituteCandidates.first), false);
      expect(c.assignSubstitute(substituteCandidates.last), false);
      expect(
        c.assignSubstitute(
          const SubstituteCandidate('Unknown', 'Van', 14, 'Free', true),
        ),
        false,
      );
      expect(c.assignSubstitute(substituteCandidates[1]), true);
      expect(c.assignedSubstitute!.name, 'Tharindu Rajapaksha');
      expect(c.assignSubstitute(substituteCandidates[1]), false);
      expect(c.activity.single.action, 'Substitute assigned');
    },
  );
  String? add({String plate = 'WP XX-1234', int year = 2020, int seats = 14}) =>
      c.addVehicle(
        name: 'Demo Driver',
        plate: plate,
        model: 'Toyota HiAce',
        year: year,
        seats: seats,
        price: 1200,
        ac: true,
        attendant: false,
      );
  test('add validates fields, plate uniqueness and pending document state', () {
    expect(add(plate: 'wp ph 4521'), isNotNull);
    expect(add(year: 3000), isNotNull);
    expect(add(seats: 0), isNotNull);
    c.filterStatus(DriverStatus.suspended);
    expect(add(), isNull);
    expect(c.selected.plate, 'WP XX-1234');
    expect(c.selected.status, DriverStatus.pending);
    expect(c.selected.canStartTrips, false);
    expect(c.selected.attendant, false);
    expect(c.verifiedCount, 42);
    expect(c.filteredRecords, hasLength(6));
    expect(
      c.changeStatus(c.selectedId, DriverStatus.pending, 'Skip review'),
      false,
    );
    expect(add(plate: 'wp xx-1234'), isNotNull);
  });
  test('selection, messages, notifications and session isolation', () {
    var notifications = 0;
    c.addListener(() => notifications++);
    c.select('unknown');
    expect(notifications, 0);
    c.select('DV-002');
    expect(c.selected.name, 'Kumari Wickramasinghe');
    expect(c.logMessage('DV-002', ' '), false);
    expect(c.logMessage('unknown', 'Hi'), false);
    expect(c.logMessage('DV-002', '  Demo message  '), true);
    expect(c.activity.single.reason, 'Demo message');
    expect(notifications, 2);
    c.changeStatus('DV-001', DriverStatus.verified, 'Demo review');
    final other = DriversVehiclesController();
    expect(other.records.first.status, DriverStatus.verified);
    expect(other.activity, isEmpty);
    other.dispose();
  });
}
