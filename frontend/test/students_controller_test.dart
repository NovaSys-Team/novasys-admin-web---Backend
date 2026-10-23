import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/students/controllers/students_controller.dart';
import 'package:novasys_admin_web/features/students/models/student.dart';

void main() {
  late StudentsController controller;
  setUp(() => controller = StudentsController());
  tearDown(() => controller.dispose());
  test('search matches student, parent and normalized plate', () {
    controller.search('  SANULI ');
    expect(controller.visibleStudents.single.name, 'Sanuli Perera');
    controller.search('Nadeesha');
    expect(controller.visibleStudents.length, 2);
    controller.search('WP PH-4521');
    expect(controller.visibleStudents.length, 3);
  });
  test('school and fee filters compose and maintain visible selection', () {
    controller.select('s3');
    controller.setFilter(StudentFilter.feesDue);
    expect(controller.visibleStudents.length, 3);
    expect(controller.selected?.id, 's3');
    controller.setSchool('Visakha');
    expect(controller.visibleStudents.map((s) => s.id), ['s4', 's5']);
    expect(controller.selected?.id, 's4');
    controller.select('s5');
    expect(controller.selected?.name, 'Hiruni Bandara');
    controller.setFilter(StudentFilter.noVehicle);
    expect(controller.selected, isNull);
    controller.reset();
    expect(controller.visibleStudents.length, 6);
    expect(controller.selected, isNotNull);
    expect(controller.subtitle, '6 students · 5 with a vehicle · 1 waiting');
  });
  test('no vehicle and empty data are handled without stale details', () {
    controller.setFilter(StudentFilter.noVehicle);
    expect(controller.selected?.name, 'Nethmi Fernando');
    controller.search('unknown');
    expect(controller.selected, isNull);
    final empty = StudentsController(students: []);
    addTearDown(empty.dispose);
    expect(empty.selected, isNull);
    expect(empty.visibleStudents, isEmpty);
  });
  test('CSV includes only filtered rows and escapes quoted fields', () {
    controller.setSchool('Royal');
    expect(controller.exportCsv(), contains('"Kavin Perera"'));
    expect(controller.exportCsv(), isNot(contains('Sanuli')));
    expect(controller.exportCsv().split('\r\n').length, 3);
    final custom = StudentsController(
      students: [
        const Student(
          id: 'x',
          name: 'A "quoted", name',
          grade: '1',
          school: 'School',
          parent: 'Parent',
          phone: '1',
          fee: StudentFee.none,
          today: 'Not riding',
        ),
      ],
    );
    addTearDown(custom.dispose);
    expect(custom.exportCsv(), contains('"A ""quoted"", name"'));
  });
}
