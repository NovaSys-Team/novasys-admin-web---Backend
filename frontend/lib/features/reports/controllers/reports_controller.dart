import 'package:flutter/foundation.dart';

import '../data/reports_mock_data.dart';
import '../models/report.dart';

class ReportsController extends ChangeNotifier {
  ReportsController({List<ReportEntry>? entries, DateTime Function()? clock})
    : _entries = List.unmodifiable(entries ?? createMockReportEntries()),
      _clock = clock ?? DateTime.now {
    _history = createMockReportHistory(_entries);
  }
  final List<ReportEntry> _entries;
  final DateTime Function() _clock;
  late final List<GeneratedReport> _history;
  ReportType _type = ReportType.attendance;
  ReportFormat _format = ReportFormat.pdf;
  DateTime _from = DateTime(2026, 10, 1), _to = DateTime(2026, 10, 19);
  String? _school;
  int _sequence = 0;
  ReportType get type => _type;
  ReportFormat get format => _format;
  DateTime get from => _from;
  DateTime get to => _to;
  String? get school => _school;
  List<GeneratedReport> get history => List.unmodifiable(_history);
  String? get dateError =>
      _from.isAfter(_to) ? 'From date must be on or before To date.' : null;
  List<List<String>> get filteredRows => dateError != null
      ? []
      : [
          for (final entry in _entries)
            if (entry.type == _type &&
                !entry.date.isBefore(_from) &&
                !entry.date.isAfter(_to) &&
                (_school == null || entry.school == _school))
              [reportDate(entry.date), entry.school, ...entry.values],
        ];
  void selectType(ReportType value) {
    _type = value;
    notifyListeners();
  }

  void selectFormat(ReportFormat value) {
    _format = value;
    notifyListeners();
  }

  void setSchool(String? value) {
    if (value != null && !reportSchools.contains(value)) return;
    _school = value;
    notifyListeners();
  }

  void setFrom(DateTime value) {
    _from = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  void setTo(DateTime value) {
    _to = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  GeneratedReport? generate() {
    final rows = filteredRows;
    if (dateError != null || rows.isEmpty) return null;
    final now = _clock();
    final report = GeneratedReport(
      id: 'local-${++_sequence}',
      type: _type,
      format: _format,
      from: _from,
      to: _to,
      school: _school,
      period: '${reportDate(_from)} – ${reportDate(_to)}',
      created: '${now.day} ${reportMonths[now.month - 1]} · Shehani K.',
      headers: reportHeaders(_type),
      rows: rows,
    );
    _history.insert(0, report);
    notifyListeners();
    return report;
  }
}
