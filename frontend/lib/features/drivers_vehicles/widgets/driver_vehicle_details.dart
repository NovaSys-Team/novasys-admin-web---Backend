import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/drivers_vehicles_controller.dart';
import '../models/driver_vehicle.dart';
import 'fleet_dialogs.dart';
import 'fleet_styles.dart';
import 'vehicle_illustration.dart';

class DriverVehicleDetails extends StatelessWidget {
  const DriverVehicleDetails({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<DriversVehiclesController>();
    final r = c.selected;
    final vehicle = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VehicleIllustration(plate: r.plate),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final entries = {
              'Model': r.model,
              'Year': '${r.year}',
              'Seats': '${r.seats}',
              'A/C': r.ac ? 'Yes' : 'No',
              'Attendant': r.attendant ? 'Yes' : 'No',
              'Price':
                  'LKR ${r.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}/km',
            }.entries.toList();
            final columns = constraints.maxWidth < 350 ? 2 : 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries
                  .map(
                    (e) => Container(
                      width:
                          (constraints.maxWidth - 8 * (columns - 1)) / columns,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key,
                            style: FleetStyles.muted.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
    );
    final profile = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DesignTokens.avatarBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                r.initials,
                style: FleetStyles.heading.copyWith(
                  color: DesignTokens.sidebar,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: FleetStyles.heading),
                  Text(
                    '${r.phone} · since ${r.since}',
                    style: FleetStyles.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DesignTokens.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...{
                'Schools': r.schools,
                'Students assigned':
                    '${r.usedSeats}${r.usedSeats == r.seats ? ' (full)' : ''}',
                'Home point': r.home,
                'On-time (30 days)': r.onTime,
                'Open complaints': '${r.complaints}',
              }.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          e.key,
                          style: const TextStyle(color: DesignTokens.mutedText),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: Text(
                          e.value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => showStudentsDialog(context, r),
              style: FleetStyles.button(color: DesignTokens.primary),
              child: const Text('View students'),
            ),
            OutlinedButton(
              onPressed: () => showDocumentsDialog(context, r),
              style: FleetStyles.button(),
              child: const Text('Documents'),
            ),
            OutlinedButton(
              onPressed: () => showMessageDriverDialog(context, c, r),
              style: FleetStyles.button(),
              child: const Text('Message driver'),
            ),
          ],
        ),
        if (r.status != DriverStatus.verified)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FleetBadge(
              r.status.label,
              danger: r.status == DriverStatus.suspended,
            ),
          ),
      ],
    );
    return FleetCard(
      key: ValueKey('fleet-details-${r.id}'),
      borderColor: DesignTokens.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 850) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [vehicle, const SizedBox(height: 20), profile],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: vehicle),
              const SizedBox(width: 20),
              Expanded(child: profile),
            ],
          );
        },
      ),
    );
  }
}
