import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/drivers_vehicles_controller.dart';
import '../models/driver_vehicle.dart';
import 'fleet_dialogs.dart';
import 'fleet_styles.dart';

class DriversVehiclesTable extends StatelessWidget {
  const DriversVehiclesTable({super.key});
  static const widths = [20, 19, 9, 7, 9, 7.5, 6.5, 12, 10];
  @override
  Widget build(BuildContext context) {
    final c = context.watch<DriversVehiclesController>();
    final minimumWidth = 1100 * MediaQuery.textScalerOf(context).scale(14) / 14;
    return FleetCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(minimumWidth, constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row(
                  const [
                    'Driver',
                    'Vehicle',
                    'Seats used',
                    'Licence',
                    'Insurance',
                    'Fitness',
                    'Rating',
                    'Status',
                    '',
                  ].map((s) => Text(s, style: FleetStyles.muted)).toList(),
                  header: true,
                ),
                for (final r in c.filteredRecords)
                  Semantics(
                    selected: c.selectedId == r.id,
                    child: Material(
                      color: c.selectedId == r.id
                          ? const Color(0xFFE5F5F3)
                          : Colors.white,
                      child: InkWell(
                        key: ValueKey('fleet-row-${r.id}'),
                        onTap: () => c.select(r.id),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 59),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFF0F4F3)),
                            ),
                          ),
                          child: _row([
                            TextButton(
                              key: ValueKey('driver-${r.id}'),
                              onPressed: () => c.select(r.id),
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.zero,
                                foregroundColor: c.selectedId == r.id
                                    ? DesignTokens.primary
                                    : DesignTokens.text,
                              ),
                              child: Text(
                                r.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            TextButton(
                              key: ValueKey('vehicle-${r.id}'),
                              onPressed: () => showVehicleDialog(context, r),
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.zero,
                                foregroundColor: DesignTokens.text,
                              ),
                              child: Text(
                                '${r.plate} · ${r.vehicleType}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text('${r.usedSeats} / ${r.seats}'),
                            ...[r.licence, r.insurance, r.fitness].map(
                              (d) => Text(
                                d.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: FleetStyles.complianceColor(d.level),
                                ),
                              ),
                            ),
                            if (r.rating == null)
                              const Text('New')
                            else
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14),
                                  const SizedBox(width: 3),
                                  Text(r.rating!.toStringAsFixed(1)),
                                ],
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FleetBadge(
                                r.status.label,
                                danger: r.status == DriverStatus.suspended,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: r.status == DriverStatus.pending
                                  ? const Text(
                                      'Awaiting review',
                                      style: FleetStyles.muted,
                                    )
                                  : OutlinedButton(
                                      key: ValueKey('status-action-${r.id}'),
                                      onPressed: () =>
                                          showDriverStatusDialog(context, c, r),
                                      style:
                                          FleetStyles.button(
                                            color:
                                                r.status ==
                                                    DriverStatus.suspended
                                                ? DesignTokens.primary
                                                : FleetStyles.red,
                                          ).copyWith(
                                            minimumSize:
                                                const WidgetStatePropertyAll(
                                                  Size(0, 34),
                                                ),
                                            padding:
                                                const WidgetStatePropertyAll(
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                                ),
                                          ),
                                      child: Text(
                                        r.status == DriverStatus.suspended
                                            ? 'Reinstate'
                                            : 'Suspend',
                                      ),
                                    ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                if (c.filteredRecords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('No matching drivers or vehicles.'),
                        TextButton(
                          onPressed: c.clearFilters,
                          child: const Text('Clear filters'),
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

  Widget _row(List<Widget> cells, {bool header = false}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: header ? 0 : 6),
    child: Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(
            flex: (widths[i] * 10).round(),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: header
                  ? SizedBox(
                      height: 27,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: cells[i],
                      ),
                    )
                  : cells[i],
            ),
          ),
      ],
    ),
  );
}
