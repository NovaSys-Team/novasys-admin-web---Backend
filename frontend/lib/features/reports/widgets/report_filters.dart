import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/reports_controller.dart';
import '../data/reports_mock_data.dart';
import '../models/report.dart';
import 'report_styles.dart';

class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key});
  Future<void> _date(
    BuildContext context,
    ReportsController controller,
    bool from,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: from ? controller.from : controller.to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
    );
    if (date != null) {
      if (from) {
        controller.setFrom(date);
      } else {
        controller.setTo(date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportsController>();
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final controlHeight = 46.0 * (textScale < 1 ? 1 : textScale);
    Widget field(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: reportLabel),
        const SizedBox(height: 4),
        child,
      ],
    );
    Widget date(bool from) => field(
      from ? 'From' : 'To',
      OutlinedButton(
        key: ValueKey(from ? 'report-from' : 'report-to'),
        onPressed: () => _date(context, controller, from),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fixedSize: Size.fromHeight(controlHeight),
          alignment: Alignment.centerLeft,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          foregroundColor: DesignTokens.text,
          side: const BorderSide(color: DesignTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          reportDate(from ? controller.from : controller.to),
          style: reportLabel,
        ),
      ),
    );
    final school = field(
      'School',
      Container(
        height: controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignTokens.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: const ValueKey('report-school'),
            value: controller.school ?? '',
            isExpanded: true,
            style: reportLabel.copyWith(color: DesignTokens.text),
            items: [
              const DropdownMenuItem(value: '', child: Text('All schools')),
              ...reportSchools.map(
                (school) =>
                    DropdownMenuItem(value: school, child: Text(school)),
              ),
            ],
            onChanged: (value) =>
                controller.setSchool(value == '' ? null : value),
          ),
        ),
      ),
    );
    final formats = field(
      'Format',
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF2F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final format in ReportFormat.values)
              Expanded(
                child: Semantics(
                  selected: controller.format == format,
                  child: TextButton(
                    key: ValueKey('report-format-${format.name}'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.standard,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fixedSize: Size.fromHeight(controlHeight - 8),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: controller.format == format
                          ? DesignTokens.text
                          : DesignTokens.mutedText,
                      backgroundColor: controller.format == format
                          ? Colors.white
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: () => controller.selectFormat(format),
                    child: Text(
                      format.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    final generate = FilledButton(
      key: const ValueKey('generate-report'),
      onPressed: controller.dateError == null
          ? () {
              final result = controller.generate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result == null
                        ? 'No mock data for this report, school and date range. Try 1–19 Oct 2026.'
                        : 'Mock ${result.type.label} report generated · ${result.rows.length} records. Ready to download.',
                  ),
                ),
              );
            }
          : null,
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        fixedSize: Size.fromHeight(controlHeight),
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Generate ${controller.format.label}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
    return ReportPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controls = [date(true), date(false), school, formats];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (constraints.maxWidth >= 1000)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < controls.length; i++) ...[
                      Expanded(
                        flex: i == 2
                            ? 25
                            : i == 3
                            ? 18
                            : 23,
                        child: controls[i],
                      ),
                      const SizedBox(width: 14),
                    ],
                    generate,
                  ],
                )
              else ...[
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final control in controls)
                      SizedBox(
                        width: constraints.maxWidth >= 500
                            ? (constraints.maxWidth - 14) / 2
                            : constraints.maxWidth,
                        child: control,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(alignment: Alignment.centerRight, child: generate),
              ],
              if (controller.dateError != null) ...[
                const SizedBox(height: 8),
                Text(
                  controller.dateError!,
                  style: const TextStyle(color: DesignTokens.danger),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
