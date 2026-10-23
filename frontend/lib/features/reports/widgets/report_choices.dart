import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/reports_controller.dart';
import '../models/report.dart';
import 'report_styles.dart';

class ReportChoices extends StatelessWidget {
  const ReportChoices({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportsController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 540
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final type in ReportType.values)
              SizedBox(
                width: width,
                child: Semantics(
                  selected: controller.type == type,
                  button: true,
                  label: '${type.label} report',
                  child: Material(
                    color: controller.type == type
                        ? Colors.white
                        : const Color(0xFFF9FBFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: controller.type == type
                            ? DesignTokens.primary
                            : DesignTokens.border,
                        width: controller.type == type ? 1.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('report-type-${type.name}'),
                      onTap: () => controller.selectType(type),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: columns == 4 && type.index < 4
                                ? 110
                                : 90,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ReportIcon(type),
                              const SizedBox(height: 10),
                              Text(
                                type.label,
                                style: reportLabel.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(type.description, style: reportMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReportIcon extends StatelessWidget {
  const _ReportIcon(this.type);
  final ReportType type;
  @override
  Widget build(BuildContext context) {
    final (icon, color, background) = switch (type) {
      ReportType.attendance => (
        Icons.event_available_outlined,
        DesignTokens.primary,
        const Color(0xFFE5F4F2),
      ),
      ReportType.trips => (
        Icons.alt_route,
        DesignTokens.primary,
        const Color(0xFFE5F4F2),
      ),
      ReportType.payments => (
        Icons.credit_card,
        const Color(0xFFD83B17),
        const Color(0xFFFFEDE6),
      ),
      ReportType.drivers => (
        Icons.star_border,
        const Color(0xFF956000),
        const Color(0xFFFFF3DB),
      ),
      ReportType.incidents => (
        Icons.warning_amber_outlined,
        const Color(0xFFE00022),
        const Color(0xFFFFECEF),
      ),
      ReportType.students => (
        Icons.directions_bus_outlined,
        DesignTokens.mutedText,
        const Color(0xFFEDF2F1),
      ),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
