import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../widgets/report_choices.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_history.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});
  static const title = 'Reports';
  static const subtitle = 'Pick a report, set the dates and download';
  @override
  Widget build(BuildContext context) => PageContainer(
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraints.maxWidth < DesignTokens.compactPageHeaderWidth) ...[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text(
              subtitle,
              style: TextStyle(color: DesignTokens.mutedText),
            ),
            const SizedBox(height: 16),
          ],
          const ReportChoices(),
          const SizedBox(height: 18),
          const ReportFilters(),
          const SizedBox(height: 18),
          const ReportHistory(),
        ],
      ),
    ),
  );
}
