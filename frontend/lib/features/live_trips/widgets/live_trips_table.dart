import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../controllers/live_trips_controller.dart';
import '../models/live_trip.dart';
import 'live_trips_styles.dart';

class LiveTripsTable extends StatefulWidget {
  const LiveTripsTable({
    super.key,
    required this.controller,
    required this.onSelect,
  });
  final LiveTripsController controller;
  final ValueChanged<LiveTrip> onSelect;
  @override
  State<LiveTripsTable> createState() => _LiveTripsTableState();
}

class _LiveTripsTableState extends State<LiveTripsTable> {
  late final _search = TextEditingController(text: widget.controller.query);
  @override
  void didUpdateWidget(covariant LiveTripsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_search.text != widget.controller.query) {
      _search.text = widget.controller.query;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final total = c.filteredTrips.length;
    final start = total == 0 ? 0 : c.page * LiveTripsController.pageSize + 1;
    final end = math.min((c.page + 1) * LiveTripsController.pageSize, total);
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DesignTokens.border, width: .8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live trip list',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Mock data only · No real GPS, calls, dispatches or notifications. Snapshot ${c.refreshCount + 1}.',
              style: LiveTripsStyles.muted,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final search = TextField(
                  key: const ValueKey('trip-search'),
                  controller: _search,
                  onChanged: c.setQuery,
                  decoration: InputDecoration(
                    labelText: 'Search trips',
                    hintText: 'Driver, vehicle or route',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: c.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () => c.setQuery(''),
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    isDense: true,
                  ),
                );
                final filters = DropdownButtonFormField<TripFilter>(
                  key: ValueKey('trip-filter-${c.filter.name}'),
                  initialValue: c.filter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Trip status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    isDense: true,
                  ),
                  items: [
                    for (final filter in TripFilter.values)
                      DropdownMenuItem(
                        value: filter,
                        child: Text(filter.label),
                      ),
                  ],
                  onChanged: (value) => c.setFilter(value ?? TripFilter.all),
                );
                final actions = Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (c.hasFilters)
                      TextButton(
                        onPressed: c.clearFilters,
                        child: const Text('Clear filters'),
                      ),
                    IconButton(
                      tooltip: 'Refresh mock snapshot',
                      onPressed: () {
                        c.refreshMockSnapshot();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mock snapshot refreshed. No GPS request was made.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                );
                if (constraints.maxWidth < 650) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: 12),
                      filters,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    SizedBox(width: 180, child: filters),
                    const SizedBox(width: 8),
                    actions,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No trips match your search or filters.'),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: math.max(1050, constraints.maxWidth),
                    ),
                    child: IntrinsicWidth(
                      child: DataTable(
                        showCheckboxColumn: false,
                        sortColumnIndex: c.sortField?.index,
                        sortAscending: c.ascending,
                        headingRowHeight: 44,
                        dataRowMinHeight: 62,
                        dataRowMaxHeight:
                            74 *
                            math.max(
                              1,
                              MediaQuery.textScalerOf(context).scale(14) / 14,
                            ),
                        horizontalMargin: 10,
                        columnSpacing: 24,
                        dividerThickness: .6,
                        headingTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.mutedText,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 13,
                          color: DesignTokens.text,
                        ),
                        columns: [
                          for (final field in TripSortField.values)
                            DataColumn(
                              label: Text(switch (field) {
                                TripSortField.driver => 'Driver',
                                TripSortField.vehicle => 'Vehicle',
                                TripSortField.route => 'Route',
                                TripSortField.onboard => 'On board',
                                TripSortField.gps => 'GPS',
                                TripSortField.eta => 'ETA school',
                                TripSortField.status => 'Status',
                              }),
                              onSort: (_, _) => c.sortBy(field),
                            ),
                        ],
                        rows: [
                          for (final trip in c.pageTrips)
                            DataRow(
                              key: ValueKey('trip-row-${trip.id}'),
                              selected: trip.id == c.selectedTripId,
                              onSelectChanged: (_) => widget.onSelect(trip),
                              cells: [
                                DataCell(Text(trip.driver)),
                                DataCell(Text(trip.vehicle)),
                                DataCell(
                                  Text(trip.route.replaceAll(' → ', ' to ')),
                                ),
                                DataCell(
                                  Text('${trip.onboard} / ${trip.capacity}'),
                                ),
                                DataCell(
                                  Text(
                                    trip.gpsLabel,
                                    style: TextStyle(
                                      color:
                                          trip.condition ==
                                              TripCondition.gpsStale
                                          ? LiveTripsStyles.warning
                                          : DesignTokens.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(Text(trip.eta)),
                                DataCell(
                                  TextButton(
                                    key: ValueKey('trip-status-${trip.id}'),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 28),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      foregroundColor:
                                          LiveTripsStyles.tripColor(
                                            trip.condition,
                                          ),
                                      backgroundColor:
                                          LiveTripsStyles.statusBackground(
                                            trip.condition,
                                          ),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () => widget.onSelect(trip),
                                    child: Text(c.tripStatus(trip)),
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
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  '$start–$end of $total trips',
                  style: LiveTripsStyles.muted,
                ),
                IconButton(
                  tooltip: 'Previous trips',
                  onPressed: c.page > 0 ? () => c.setPage(c.page - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Next trips',
                  onPressed: c.page < c.pageCount - 1
                      ? () => c.setPage(c.page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
