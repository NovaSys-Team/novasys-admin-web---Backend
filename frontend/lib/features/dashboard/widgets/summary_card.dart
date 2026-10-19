import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_styles.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.metric, required this.onTap});
  final SummaryMetric metric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: DesignTokens.border, width: .8),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.mutedText,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF8A9B98),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: DesignTokens.text,
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (metric.tone == DashboardTone.success)
                  Icon(
                    Icons.arrow_drop_up,
                    size: 14,
                    color: DashboardStyles.foreground(metric.tone),
                  ),
                Flexible(
                  child: Text(
                    metric.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DashboardStyles.foreground(metric.tone),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
