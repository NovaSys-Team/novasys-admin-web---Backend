enum StudentFilter { all, feesDue, noVehicle }

enum StudentFee { paid, due, overdue, none }

class Student {
  const Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.school,
    required this.parent,
    required this.phone,
    required this.fee,
    required this.today,
    this.plate,
    this.driver = 'Kumari W.',
    this.vehicle = 'Toyota HiAce',
    this.pickup = '42 Lake Drive',
    this.attendance = '11 / 12 days',
    this.health = 'None reported',
    this.pickupPeople = '3 (1 PIN only)',
  });

  final String id, name, grade, school, parent, phone;
  final String? plate;
  final String driver, vehicle, pickup, attendance, health, pickupPeople, today;
  final StudentFee fee;
  bool get hasVehicle => plate != null;
  bool get feesDue => fee == StudentFee.due || fee == StudentFee.overdue;
}
