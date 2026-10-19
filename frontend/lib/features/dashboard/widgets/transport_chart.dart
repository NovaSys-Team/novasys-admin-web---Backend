import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_styles.dart';

class TransportChart extends StatelessWidget {
  const TransportChart({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelect,
    required this.onReport,
  });
  final List<TransportDay> days;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onReport;

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
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 6,
              children: [
                const Text(
                  'Students transported per day',
                  style: DashboardStyles.heading,
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    const Text(
                      'Last 10 school days · both trips',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.mutedText,
                      ),
                    ),
                    DashboardActionLink(
                      onPressed: onReport,
                      label: 'Full report',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hover a bar for the exact count',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth < 580 ? 580 : constraints.maxWidth,
                height: 230,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('500', style: DashboardStyles.secondary),
                          Text('250', style: DashboardStyles.secondary),
                          Text('0', style: DashboardStyles.secondary),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Divider(height: 1, color: Color(0xFFEEF2F1)),
                          ),
                          const Positioned(
                            top: 100,
                            left: 0,
                            right: 0,
                            child: Divider(height: 1, color: Color(0xFFEEF2F1)),
                          ),
                          const Positioned(
                            top: 200,
                            left: 0,
                            right: 0,
                            child: Divider(
                              height: 1,
                              color: DesignTokens.border,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < days.length; i++)
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            widthFactor: .65,
                                            child: Tooltip(
                                              message:
                                                  '${days[i].label}: ${days[i].count} students',
                                              waitDuration: const Duration(
                                                milliseconds: 100,
                                              ),
                                              child: Semantics(
                                                label:
                                                    '${days[i].label}: ${days[i].count} students',
                                                selected: selectedIndex == i,
                                                button: true,
                                                child: Material(
                                                  color: selectedIndex == i
                                                      ? DesignTokens.sidebar
                                                      : i == days.length - 1
                                                      ? const Color(0xFF9FD8CF)
                                                      : DesignTokens.primary,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                  child: InkWell(
                                                    key: ValueKey(
                                                      'transport-bar-$i',
                                                    ),
                                                    onTap: () => onSelect(i),
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            4,
                                                          ),
                                                        ),
                                                    child: SizedBox(
                                                      height:
                                                          days[i].count /
                                                          500 *
                                                          200,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 18,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            days[i].label,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: DesignTokens.mutedText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: selectedIndex == null
                ? const SizedBox.shrink()
                : Text(
                    '${days[selectedIndex!].label}: ${days[selectedIndex!].count} students · Mock data',
                    style: DashboardStyles.secondary,
                  ),
          ),
        ],
      ),
    ),
  );
}
