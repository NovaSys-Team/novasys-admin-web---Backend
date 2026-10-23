import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/routes_calendar_controller.dart';
import '../models/trip_rule.dart';
import 'calendar_dialogs.dart';
import 'routes_calendar_styles.dart';

class TripRulesCard extends StatelessWidget {
  const TripRulesCard({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoutesCalendarController>();
    return RoutesCalendarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Trip rules', style: RoutesCalendarStyles.heading),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18
                  ? 1
                  : 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TripRule.values
                    .map(
                      (rule) => SizedBox(
                        width:
                            (constraints.maxWidth - 10 * (columns - 1)) /
                            columns,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rule.label,
                              style: RoutesCalendarStyles.muted.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Semantics(
                              button: true,
                              label: 'Edit ${rule.label}',
                              child: InkWell(
                                key: ValueKey('rule-${rule.name}'),
                                borderRadius: BorderRadius.circular(10),
                                onTap: () =>
                                    showTripRuleDialog(context, c, rule),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(
                                    minHeight: 42,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: DesignTokens.border,
                                    ),
                                  ),
                                  child: Text(
                                    c.ruleDisplay(rule),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
