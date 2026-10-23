import 'package:flutter/foundation.dart';

import '../data/students_mock_data.dart';
import '../models/student.dart';

class StudentsController extends ChangeNotifier {
  StudentsController({List<Student> students = mockStudents})
    : _students = List.unmodifiable(students) {
    _selectedId = _students.firstOrNull?.id;
  }
  final List<Student> _students;
  String? _selectedId;
  String _query = '';
  String? _school;
  StudentFilter _filter = StudentFilter.all;
  String get query => _query;
  String? get school => _school;
  StudentFilter get filter => _filter;
  List<String> get schools =>
      (_students.map((s) => s.school).toSet().toList()..sort());
  String get subtitle {
    final assigned = _students.where((s) => s.hasVehicle).length;
    return '${_students.length} students · $assigned with a vehicle · ${_students.length - assigned} waiting';
  }

  List<Student> get visibleStudents => List.unmodifiable(
    _students.where((s) {
      final searchable = '${s.name} ${s.parent} ${s.plate ?? ''} ${s.driver}'
          .toLowerCase()
          .replaceAll('–', '-');
      return searchable.contains(
            _query.trim().toLowerCase().replaceAll('–', '-'),
          ) &&
          (_school == null || s.school == _school) &&
          (_filter == StudentFilter.all ||
              (_filter == StudentFilter.feesDue ? s.feesDue : !s.hasVehicle));
    }),
  );
  Student? get selected =>
      visibleStudents.where((s) => s.id == _selectedId).firstOrNull;
  void _update() {
    if (selected == null) _selectedId = visibleStudents.firstOrNull?.id;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    _update();
  }

  void setSchool(String? value) {
    _school = value;
    _update();
  }

  void setFilter(StudentFilter value) {
    _filter = value;
    _update();
  }

  void select(String id) {
    if (!visibleStudents.any((s) => s.id == id)) return;
    _selectedId = id;
    notifyListeners();
  }

  void reset() {
    _query = '';
    _school = null;
    _filter = StudentFilter.all;
    _update();
  }

  String exportCsv() {
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    return [
      [
        'Student',
        'Grade',
        'School',
        'Assigned vehicle',
        'Driver',
        'Fee',
        'Today',
      ],
      ...visibleStudents.map(
        (s) => [
          s.name,
          s.grade,
          s.school,
          s.plate ?? 'No vehicle',
          s.driver,
          s.fee.name,
          s.today,
        ],
      ),
    ].map((row) => row.map(quote).join(',')).join('\r\n');
  }
}
