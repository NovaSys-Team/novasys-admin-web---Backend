import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_styles.dart';

class MorningTripsTable extends StatelessWidget {
  const MorningTripsTable({
    super.key,
    required this.trips,
    required this.onOpenTrip,
    required this.onOpenMap,
  });
  final List<DashboardTrip> trips;
  final ValueChanged<DashboardTrip> onOpenTrip;
  final VoidCallback onOpenMap;
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
              spacing: 24,
              children: [
                const Text(
                  'Morning trips right now',
                  style: DashboardStyles.heading,
                ),
                DashboardActionLink(
                  onPressed: onOpenMap,
                  label: 'Open live map',
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: math.max(1050, constraints.maxWidth),
                ),
                child: IntrinsicWidth(
                  child: DataTable(
                    headingRowHeight: 34,
                    dataRowMinHeight: 58,
                    dataRowMaxHeight:
                        58 *
                        math.max(
                          1,
                          MediaQuery.textScalerOf(context).scale(14) / 14,
                        ),
                    horizontalMargin: 10,
                    columnSpacing: 24,
                    dividerThickness: .6,
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xFFEEF2F1)),
                    ),
                    headingTextStyle: const TextStyle(
                      fontSize: 12,
                      color: DesignTokens.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                    dataTextStyle: const TextStyle(
                      fontSize: 13,
                      color: DesignTokens.text,
                    ),
                    columns: [
                      for (final label in [
                        'Driver · vehicle',
                        'Route',
                        'On board',
                        'GPS',
                        'ETA school',
                        'Status',
                      ])
                        DataColumn(label: Text(label)),
                    ],
                    rows: [
                      for (final trip in trips)
                        DataRow(
                          cells: [
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.driver,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    trip.vehicle,
                                    style: DashboardStyles.secondary,
                                  ),
                                ],
                              ),
                            ),
                            DataCell(DashboardRouteLabel(route: trip.route)),
                            DataCell(Text(trip.onboard)),
                            DataCell(
                              Text(
                                trip.gps,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: trip.gpsStale
                                      ? DashboardStyles.foreground(
                                          DashboardTone.warning,
                                        )
                                      : DesignTokens.primary,
                                ),
                              ),
                            ),
                            DataCell(Text(trip.eta)),
                            DataCell(
                              TextButton(
                                onPressed: () => onOpenTrip(trip),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 28),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  foregroundColor: DashboardStyles.foreground(
                                    trip.tone,
                                  ),
                                  backgroundColor: DashboardStyles.background(
                                    trip.tone,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(trip.status),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward, size: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
