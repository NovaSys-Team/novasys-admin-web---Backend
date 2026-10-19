import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_styles.dart';

class AttentionPanel extends StatelessWidget {
  const AttentionPanel({super.key, required this.items, required this.onOpen});
  final List<AttentionItem> items;
  final ValueChanged<AttentionItem> onOpen;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: DashboardStyles.panelBorder,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Needs attention', style: DashboardStyles.heading),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Material(
              color: DesignTokens.background,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onOpen(items[i]),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: DashboardStyles.background(items[i].tone),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${items[i].count}',
                          style: TextStyle(
                            color: DashboardStyles.foreground(items[i].tone),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].title,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              items[i].description,
                              style: DashboardStyles.secondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: DesignTokens.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
