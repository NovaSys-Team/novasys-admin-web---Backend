import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:novasys_admin_web/features/reports/controllers/reports_controller.dart';
import 'package:novasys_admin_web/features/reports/models/report.dart';
import 'package:novasys_admin_web/features/reports/models/report_document.dart';

void main() {
  late ReportsController controller;
  setUp(
    () => controller = ReportsController(clock: () => DateTime(2026, 10, 23)),
  );
  tearDown(() => controller.dispose());
  test('initial report, dates, format and three history rows match A09', () {
    expect(controller.type, ReportType.attendance);
    expect(controller.format, ReportFormat.pdf);
    expect(controller.from, DateTime(2026, 10));
    expect(controller.to, DateTime(2026, 10, 19));
    expect(controller.history.map((r) => r.type), [
      ReportType.payments,
      ReportType.attendance,
      ReportType.incidents,
    ]);
    expect(controller.filteredRows.length, 39);
  });
  test('school, inclusive date range and type control generated contents', () {
    controller.selectType(ReportType.trips);
    controller.selectFormat(ReportFormat.csv);
    controller.setSchool('Royal');
    controller.setFrom(DateTime(2026, 10, 1, 15));
    controller.setTo(DateTime(2026, 10, 2));
    final report = controller.generate()!;
    expect(report.rows.length, 2);
    expect(report.rows.every((row) => row[1] == 'Royal'), isTrue);
    expect(report.rows.first[0], '1 Oct 2026');
    expect(report.rows.last[0], '2 Oct 2026');
    expect(report.headers, contains('Delay (min)'));
    expect(report.format, ReportFormat.csv);
    expect(report.created, '23 Oct · Shehani K.');
    expect(controller.history.first, same(report));
  });
  test(
    'generation snapshots remain independent of subsequent filter changes',
    () {
      final first = controller.generate()!;
      controller.setSchool('Visakha');
      controller.selectType(ReportType.payments);
      final second = controller.generate()!;
      expect(first.type, ReportType.attendance);
      expect(first.school, isNull);
      expect(first.rows.length, 39);
      expect(second.rows.length, 13);
      expect(second.id, isNot(first.id));
      expect(() => first.rows.clear(), throwsUnsupportedError);
      expect(() => first.headers.clear(), throwsUnsupportedError);
      expect(() => controller.history.clear(), throwsUnsupportedError);
    },
  );
  test('invalid ranges, weekends and missing data never create reports', () {
    controller.setFrom(DateTime(2026, 10, 20));
    expect(controller.dateError, isNotNull);
    expect(controller.generate(), isNull);
    controller.setFrom(DateTime(2026, 10, 3));
    controller.setTo(DateTime(2026, 10, 4));
    expect(controller.dateError, isNull);
    expect(controller.generate(), isNull);
    final empty = ReportsController(entries: []);
    addTearDown(empty.dispose);
    expect(empty.generate(), isNull);
    expect(controller.history.length, 3);
  });
  test(
    'all six report types produce distinct columns and matching row widths',
    () {
      for (final type in ReportType.values) {
        controller.selectType(type);
        final report = controller.generate()!;
        expect(report.type, type);
        expect(report.rows, isNotEmpty);
        expect(
          report.rows.every((r) => r.length == report.headers.length),
          isTrue,
        );
      }
    },
  );
  test(
    'exports produce PDF pages, Excel workbook XML and correctly quoted CSV',
    () {
      for (final format in ReportFormat.values) {
        controller.selectFormat(format);
        final document = ReportDocument.fromReport(controller.generate()!);
        expect(document.filename, endsWith('.${format.extension}'));
        final content = utf8.decode(document.bytes);
        expect(content, contains('MOCK DATA'));
        if (format == ReportFormat.pdf) {
          expect(content, startsWith('%PDF-1.4'));
          expect(content, contains('/Type /Page'));
          final offset = int.parse(
            RegExp(r'startxref\n(\d+)').firstMatch(content)!.group(1)!,
          );
          expect(content.substring(offset), startsWith('xref'));
          expect(content, endsWith('%%EOF\n'));
        } else if (format == ReportFormat.excel) {
          expect(content, contains('<Workbook'));
          expect(content, contains('<Worksheet ss:Name="Mock report">'));
          expect(content, contains('Sanuli Perera'));
        } else {
          expect(content, contains('"Student","Boarded","Dropped","Absent"'));
          expect(content, contains('All schools'));
        }
      }
      final custom = GeneratedReport(
        id: 'x',
        type: ReportType.attendance,
        format: ReportFormat.csv,
        from: DateTime(2026),
        to: DateTime(2026),
        school: 'A&B',
        period: 'Test',
        created: 'Now',
        headers: ['Name'],
        rows: [
          ['A "quoted", student'],
        ],
      );
      expect(
        utf8.decode(ReportDocument.fromReport(custom).bytes),
        contains('"A ""quoted"", student"'),
      );
    },
  );
}
