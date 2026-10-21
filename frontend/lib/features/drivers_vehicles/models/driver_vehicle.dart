enum DriverStatus {
  verified('VERIFIED'),
  suspended('SUSPENDED'),
  pending('PENDING');

  const DriverStatus(this.label);
  final String label;
}

enum ComplianceLevel { valid, warning, blocked }

class ComplianceDocument {
  const ComplianceDocument(this.label, this.level);
  final String label;
  final ComplianceLevel level;
}

class DriverVehicle {
  const DriverVehicle({
    required this.id,
    required this.name,
    required this.plate,
    required this.model,
    required this.year,
    required this.seats,
    required this.usedSeats,
    required this.licence,
    required this.insurance,
    required this.fitness,
    required this.rating,
    required this.status,
    required this.phone,
    required this.since,
    required this.schools,
    required this.home,
    required this.onTime,
    this.complaints = 0,
    this.ac = true,
    this.attendant = true,
    this.price = 1200,
  });
  final String id, name, plate, model, phone, since, schools, home, onTime;
  final int year, seats, usedSeats, complaints, price;
  final bool ac, attendant;
  final ComplianceDocument licence, insurance, fitness;
  final double? rating;
  final DriverStatus status;
  String get vehicleType => model.split(' ').last;
  String get initials => name.split(' ').take(2).map((s) => s[0]).join();
  bool get canStartTrips =>
      status == DriverStatus.verified &&
      ![
        licence,
        insurance,
        fitness,
      ].any((d) => d.level == ComplianceLevel.blocked);
  DriverVehicle withStatus(DriverStatus value) => DriverVehicle(
    id: id,
    name: name,
    plate: plate,
    model: model,
    year: year,
    seats: seats,
    usedSeats: usedSeats,
    licence: licence,
    insurance: insurance,
    fitness: fitness,
    rating: rating,
    status: value,
    phone: phone,
    since: since,
    schools: schools,
    home: home,
    onTime: onTime,
    complaints: complaints,
    ac: ac,
    attendant: attendant,
    price: price,
  );
}

class SubstituteCandidate {
  const SubstituteCandidate(
    this.name,
    this.vehicle,
    this.seats,
    this.availability,
    this.eligible,
  );
  final String name, vehicle, availability;
  final int seats;
  final bool eligible;
}

class FleetActivity {
  const FleetActivity(this.driverId, this.action, this.reason);
  final String driverId, action, reason;
}
