import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/live_trip.dart';
import '../models/trip_incident.dart';
import 'incident_action_dialog.dart';
import 'live_trips_styles.dart';

class IncidentDetailsPanel extends StatelessWidget {
  const IncidentDetailsPanel({
    super.key,
    required this.incident,
    required this.trip,
    required this.incidents,
    required this.onSelectIncident,
    required this.onAction,
    required this.minHeight,
    this.error,
  });
  final TripIncident incident;
  final LiveTrip trip;
  final List<TripIncident> incidents;
  final ValueChanged<String> onSelectIncident;
  final ValueChanged<IncidentAction> onAction;
  final double minHeight;
  final String? error;
  @override
  Widget build(BuildContext context) {
    final open = incident.status == IncidentStatus.open;
    final resolved = incident.status == IncidentStatus.resolved;
    final badgeColor = resolved
        ? LiveTripsStyles.success
        : open
        ? DesignTokens.danger
        : LiveTripsStyles.warning;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LiveTripsStyles.incidentColor(incident.status),
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: resolved
                      ? const Color(0xFFE5F6EC)
                      : open
                      ? const Color(0xFFFDECEC)
                      : const Color(0xFFFFF4DD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  incident.badge,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Select incident',
                initialValue: incident.id,
                onSelected: onSelectIncident,
                itemBuilder: (_) => [
                  for (final item in incidents)
                    PopupMenuItem(
                      value: item.id,
                      child: Text('${item.id} · ${item.status.name}'),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          incident.id,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.mutedText,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: DesignTokens.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            incident.title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Driver', value: '${trip.driver} · ${trip.phone}'),
          _DetailRow(label: 'Vehicle', value: trip.vehicle),
          _DetailRow(
            label: 'On board',
            value:
                '${trip.onboard} students · ${trip.schools} ${trip.schools == 1 ? 'school' : 'schools'}',
          ),
          _DetailRow(
            label: 'Location',
            value:
                '${trip.location} · ${trip.gpsSeconds < 60 ? 'live ${trip.gpsSeconds}s ago' : 'snapshot ${trip.gpsSeconds ~/ 60} min ago'}',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (var i = 0; i < incident.events.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          incident.events[i].time,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.mutedText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          incident.events[i].description,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (open)
            FilledButton(
              key: const ValueKey('acknowledge-incident'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.danger,
                minimumSize: const Size(0, 52),
                visualDensity: VisualDensity.standard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => onAction(IncidentAction.acknowledge),
              child: const Text(
                'Acknowledge & call driver',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          if (incident.status == IncidentStatus.acknowledged) ...[
            Row(
              children: [
                Expanded(
                  child: _DemoStatusButton(
                    label: 'Standby dispatched',
                    title: 'Demo standby plan',
                    description:
                        'Standby van ${incident.standbyVehicle} · ETA ${incident.standbyEtaMinutes} min. This is a simulated record. No van was dispatched.',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DemoStatusButton(
                    label: 'Parents notified',
                    title: 'Demo parent update',
                    description:
                        '${incident.notifiedParentCount} parents are included in the demo update. No notifications or messages were sent.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              key: const ValueKey('resolve-incident'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                visualDensity: VisualDensity.standard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => onAction(IncidentAction.resolve),
              child: const Text(
                'Mark resolved',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (resolved)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F6EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                incident.resolution,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: LiveTripsStyles.success,
                ),
              ),
            ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: const TextStyle(color: DesignTokens.danger),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'NovaSys does not dispatch emergency services. Call 1990 / 119 directly if anyone is hurt.',
            style: LiveTripsStyles.muted,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: DesignTokens.mutedText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DemoStatusButton extends StatelessWidget {
  const _DemoStatusButton({
    required this.label,
    required this.title,
    required this.description,
  });
  final String label;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 44),
      visualDensity: VisualDensity.standard,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: DesignTokens.primary, width: .8),
    ),
    onPressed: () => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.check, size: 14),
      ],
    ),
  );
}
