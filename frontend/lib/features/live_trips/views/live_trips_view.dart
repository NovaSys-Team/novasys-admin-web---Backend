import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/page_container.dart';
import '../controllers/live_trips_controller.dart';
import '../models/live_trip.dart';
import '../widgets/incident_action_dialog.dart';
import '../widgets/incident_details_panel.dart';
import '../widgets/live_trip_summary.dart';
import '../widgets/live_trips_map.dart';
import '../widgets/live_trips_table.dart';
import '../widgets/trip_snapshot_dialog.dart';

class LiveTripsView extends StatefulWidget {
  const LiveTripsView({super.key});
  static const title = 'Live trips';
  @override
  State<LiveTripsView> createState() => _LiveTripsViewState();
}

class _LiveTripsViewState extends State<LiveTripsView> {
  final _panelKey = GlobalKey();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Advance only the local snapshot counter; no GPS or network is involved.
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        context.read<LiveTripsController>().refreshMockSnapshot();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LiveTripsController>();
    return Semantics(
      label: 'Live trips and incidents',
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < DesignTokens.compactPageHeaderWidth;
            final map = LiveTripsMap(
              trips: c.mapTrips,
              selectedTripId: c.selectedTripId,
              incident: c.selectedIncident,
              incidentTrip: c.incidentTrip,
              onSelect: (trip) => _selectTrip(c, trip),
              statusForTrip: c.tripStatus,
            );
            Widget panel(double height) => IncidentDetailsPanel(
              key: _panelKey,
              incident: c.selectedIncident,
              trip: c.incidentTrip,
              incidents: c.incidents,
              onSelectIncident: c.selectIncident,
              onAction: (action) => _act(c, action),
              minHeight: height,
              error: c.actionError,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compact) ...[
                  Text(
                    LiveTripsView.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.subtitle,
                    style: const TextStyle(color: DesignTokens.mutedText),
                  ),
                  const SizedBox(height: 16),
                ],
                if (constraints.maxWidth < 900) ...[
                  const LiveTripSummary(),
                  const SizedBox(height: 16),
                ],
                if (constraints.maxWidth >= 1000)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 60, child: map),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 41,
                        child: panel(
                          (constraints.maxWidth - 16) * 60 / 101 * 622 / 670,
                        ),
                      ),
                    ],
                  )
                else ...[
                  map,
                  const SizedBox(height: 16),
                  panel(0),
                ],
                const SizedBox(height: 20),
                LiveTripsTable(
                  controller: c,
                  onSelect: (trip) => _selectTrip(c, trip),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectTrip(LiveTripsController c, LiveTrip trip) async {
    c.selectTrip(trip.id);
    if (c.incidentForTrip(trip.id) == null) {
      await showTripSnapshot(context, trip, c.tripStatus(trip));
    } else {
      await Future<void>.delayed(Duration.zero);
      if (mounted && _panelKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _panelKey.currentContext!,
          duration: const Duration(milliseconds: 200),
        );
      }
    }
  }

  Future<void> _act(LiveTripsController c, IncidentAction action) async {
    final incident = c.selectedIncident;
    final result = await confirmIncidentAction(context, incident, action);
    if (result == null || !mounted) return;
    final success = action == IncidentAction.acknowledge
        ? c.acknowledgeIncident(incident.id)
        : c.resolveIncident(incident.id, result);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == IncidentAction.acknowledge
                ? 'Incident acknowledged (demo only). No calls, dispatches or messages were sent.'
                : 'Incident resolved (demo only). No real trip or student location was changed.',
          ),
        ),
      );
    }
  }
}
