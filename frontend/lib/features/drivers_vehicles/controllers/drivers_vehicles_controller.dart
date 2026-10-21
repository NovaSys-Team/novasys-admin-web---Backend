import 'package:flutter/foundation.dart';

import '../data/drivers_vehicles_mock_data.dart';
import '../models/driver_vehicle.dart';

class DriversVehiclesController extends ChangeNotifier {
  final List<DriverVehicle> _records = List.of(driverVehicleMockData);
  final List<FleetActivity> _activity = [];
  List<DriverVehicle> get records => List.unmodifiable(_records);
  List<FleetActivity> get activity => List.unmodifiable(_activity);
  String selectedId = 'DV-001';
  String query = '';
  DriverStatus? statusFilter;
  ComplianceLevel? complianceFilter;
  bool filtersVisible = false;
  SubstituteCandidate? assignedSubstitute;
  DriverVehicle get selected => _records.firstWhere((r) => r.id == selectedId);
  // A06's fleet-wide demo totals include drivers outside the five-row sample.
  int get verifiedCount =>
      42 + _records.where((r) => r.status == DriverStatus.verified).length - 4;
  String get subtitle =>
      '$verifiedCount verified drivers · ${assignedSubstitute == null ? 3 : 2} standby · compliance checked daily';
  List<DriverVehicle> get filteredRecords => _records.where((r) {
    final matches = '${r.name} ${r.plate} ${r.model}'.toLowerCase().contains(
      query.trim().toLowerCase(),
    );
    final levels = [r.licence.level, r.insurance.level, r.fitness.level];
    final worst = levels.contains(ComplianceLevel.blocked)
        ? ComplianceLevel.blocked
        : levels.contains(ComplianceLevel.warning)
        ? ComplianceLevel.warning
        : ComplianceLevel.valid;
    return matches &&
        (statusFilter == null || statusFilter == r.status) &&
        (complianceFilter == null || complianceFilter == worst);
  }).toList();
  void select(String id) {
    if (!_records.any((r) => r.id == id)) return;
    selectedId = id;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void filterStatus(DriverStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void filterCompliance(ComplianceLevel? value) {
    complianceFilter = value;
    notifyListeners();
  }

  void toggleFilters() {
    filtersVisible = !filtersVisible;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    statusFilter = null;
    complianceFilter = null;
    notifyListeners();
  }

  bool changeStatus(String id, DriverStatus expected, String reason) {
    final index = _records.indexWhere((r) => r.id == id);
    if (index < 0 ||
        reason.trim().isEmpty ||
        _records[index].status != expected ||
        expected == DriverStatus.pending) {
      return false;
    }
    final status = expected == DriverStatus.verified
        ? DriverStatus.suspended
        : DriverStatus.verified;
    _records[index] = _records[index].withStatus(status);
    _activity.add(FleetActivity(id, status.label, reason.trim()));
    notifyListeners();
    return true;
  }

  bool assignSubstitute(SubstituteCandidate candidate) {
    if (assignedSubstitute != null ||
        !substituteCandidates.contains(candidate) ||
        !candidate.eligible ||
        candidate.seats < 14) {
      return false;
    }
    assignedSubstitute = candidate;
    _activity.add(
      FleetActivity(
        'DV-001',
        'Substitute assigned',
        '${candidate.name} · Fri 23 Oct · AM and PM',
      ),
    );
    notifyListeners();
    return true;
  }

  bool logMessage(String id, String message) {
    if (!_records.any((r) => r.id == id) || message.trim().isEmpty) {
      return false;
    }
    _activity.add(FleetActivity(id, 'Mock message', message.trim()));
    notifyListeners();
    return true;
  }

  String? addVehicle({
    required String name,
    required String plate,
    required String model,
    required int year,
    required int seats,
    required int price,
    required bool ac,
    required bool attendant,
  }) {
    final normalizedPlate = plate.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (name.trim().isEmpty ||
        normalizedPlate.isEmpty ||
        model.trim().isEmpty ||
        year < 1980 ||
        year > 2026 ||
        seats < 1 ||
        seats > 80 ||
        price < 1) {
      return 'Enter valid vehicle and driver details.';
    }
    if (_records.any(
      (r) =>
          r.plate.replaceAll(RegExp(r'[^A-Z0-9]'), '') ==
          normalizedPlate.replaceAll(RegExp(r'[^A-Z0-9]'), ''),
    )) {
      return 'A vehicle with this plate already exists.';
    }
    final id = 'DV-${(_records.length + 1).toString().padLeft(3, '0')}';
    const pending = ComplianceDocument(
      'Not submitted',
      ComplianceLevel.blocked,
    );
    _records.add(
      DriverVehicle(
        id: id,
        name: name.trim(),
        plate: normalizedPlate,
        model: model.trim(),
        year: year,
        seats: seats,
        usedSeats: 0,
        licence: pending,
        insurance: pending,
        fitness: pending,
        rating: null,
        status: DriverStatus.pending,
        phone: 'Not provided',
        since: 'Demo session',
        schools: '—',
        home: 'Not provided',
        onTime: 'New',
        price: price,
        ac: ac,
        attendant: attendant,
      ),
    );
    _activity.add(
      FleetActivity(id, 'Vehicle added', 'Pending document verification'),
    );
    selectedId = id;
    query = '';
    statusFilter = null;
    complianceFilter = null;
    notifyListeners();
    return null;
  }
}
