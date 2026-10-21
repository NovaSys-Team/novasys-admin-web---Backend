import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/drivers_vehicles_controller.dart';
import '../data/drivers_vehicles_mock_data.dart';
import 'fleet_dialogs.dart';
import 'fleet_styles.dart';

class SubstitutePanel extends StatelessWidget {
  const SubstitutePanel({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<DriversVehiclesController>();
    return FleetCard(
      borderColor: const Color(0xFFFFD9CD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substitute needed · Fri 23 Oct',
                    style: FleetStyles.heading,
                  ),
                  SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ruwan Jayasinghe on planned leave · 14 students AM, 14 PM · Rajagiriya ',
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: DesignTokens.mutedText,
                          ),
                        ),
                        TextSpan(text: ' Visakha, Royal'),
                      ],
                    ),
                    style: FleetStyles.muted,
                  ),
                ],
              ),
              FleetBadge(
                c.assignedSubstitute == null ? 'NEEDS ASSIGNMENT' : 'ASSIGNED',
                danger: c.assignedSubstitute == null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = substituteCandidates
                  .map(
                    (candidate) => Material(
                      color: candidate.eligible
                          ? Colors.white
                          : DesignTokens.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: DesignTokens.border),
                      ),
                      child: InkWell(
                        key: ValueKey('substitute-${candidate.name}'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () =>
                            showSubstituteDialog(context, c, candidate),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidate.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${candidate.vehicle} · ${candidate.seats} seats',
                                style: FleetStyles.muted,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.assignedSubstitute == candidate
                                    ? 'Assigned · AM and PM'
                                    : candidate.availability,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: candidate.eligible
                                      ? FleetStyles.green
                                      : const Color(0xFFCF3700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList();
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      cards[i],
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
