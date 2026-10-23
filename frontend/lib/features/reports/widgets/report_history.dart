import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/reports_controller.dart';
import '../models/report.dart';
import '../models/report_document.dart';
import '../services/report_download.dart';
import 'report_styles.dart';

class ReportHistory extends StatelessWidget {
  const ReportHistory({super.key});
  void _download(BuildContext context, GeneratedReport report) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      final document = ReportDocument.fromReport(report);
      final downloaded = downloadReportDocument(document);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloaded
                ? 'Mock report download started · ${document.filename}'
                : 'Mock ${report.format.label} prepared · ${report.rows.length} records. File downloads are available in the web app.',
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not prepare the mock report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ReportsController>().history;
    Widget cell(Widget child, int flex) => Expanded(flex: flex, child: child);
    return ReportPanel(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 760 ? 760 : constraints.maxWidth,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  child: Row(
                    children: [
                      for (final column in [
                        ('Report', 26),
                        ('Period', 17),
                        ('Created', 29),
                        ('Format', 16),
                        ('', 13),
                      ])
                        cell(
                          Text(
                            column.$1,
                            style: reportMuted.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          column.$2,
                        ),
                    ],
                  ),
                ),
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No reports yet. Choose a report and generate it above.',
                    ),
                  ),
                for (final report in history)
                  Container(
                    key: ValueKey('report-history-${report.id}'),
                    constraints: const BoxConstraints(minHeight: 43),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFF0F4F3))),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        cell(Text(report.type.label, style: reportLabel), 26),
                        cell(
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(report.period),
                          ),
                          17,
                        ),
                        cell(Text(report.created), 29),
                        cell(
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF2F1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                report.format.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          16,
                        ),
                        cell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: ValueKey('report-download-${report.id}'),
                              onPressed: () => _download(context, report),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Download',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          13,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
