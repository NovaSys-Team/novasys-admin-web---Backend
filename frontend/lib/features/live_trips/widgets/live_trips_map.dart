import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/live_trip.dart';
import '../models/trip_incident.dart';
import 'live_trips_styles.dart';

class LiveTripsMap extends StatefulWidget {
  const LiveTripsMap({
    super.key,
    required this.trips,
    required this.selectedTripId,
    required this.incident,
    required this.incidentTrip,
    required this.onSelect,
    required this.statusForTrip,
  });
  final List<LiveTrip> trips;
  final String selectedTripId;
  final TripIncident incident;
  final LiveTrip incidentTrip;
  final ValueChanged<LiveTrip> onSelect;
  final String Function(LiveTrip) statusForTrip;
  @override
  State<LiveTripsMap> createState() => _LiveTripsMapState();
}

class _LiveTripsMapState extends State<LiveTripsMap> {
  final _transform = TransformationController();
  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _zoom() {
    final scale = (_transform.value.getMaxScaleOnAxis() + .25).clamp(1.0, 2.5);
    _transform.value = Matrix4.diagonal3Values(scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Illustrative trip map. No live GPS connection.',
    child: AspectRatio(
      aspectRatio: 670 / 622,
      child: LayoutBuilder(builder: _buildMap),
    ),
  );
  Widget _buildMap(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth, height = constraints.maxHeight;
    final layers = <Widget>[
      const Positioned.fill(child: CustomPaint(painter: _MapRoadsPainter())),
    ];
    for (final position in const [
      Offset(286, 88),
      Offset(556, 328),
      Offset(18, 408),
    ]) {
      layers.add(
        Positioned(
          left: position.dx / 670 * width - 19,
          top: position.dy / 622 * height - 24,
          child: const _SchoolPin(),
        ),
      );
    }
    for (final trip in widget.trips) {
      layers.add(_marker(trip, width, height));
    }
    if (widget.incidentTrip.visibleOnMap &&
        widget.trips.any((trip) => trip.id == widget.incidentTrip.id)) {
      layers.add(
        _label(
          '${widget.incident.status == IncidentStatus.resolved ? 'Resolved' : 'SOS'} · ${widget.incidentTrip.vehicle} · ${widget.incidentTrip.onboard} kids',
          width: width,
          height: height,
          left: widget.incidentTrip.mapX! / 670 * width + 20,
          top: widget.incidentTrip.mapY! / 622 * height - 50,
          preferredWidth: 196,
          color: DesignTokens.text,
          foreground: Colors.white,
        ),
      );
    }
    for (final trip in widget.trips) {
      if (trip.condition == TripCondition.gpsStale) {
        layers.add(
          _label(
            '${trip.vehicle.replaceFirst('WP ', '').replaceAll('–', '-')} · ${trip.gpsSeconds ~/ 60} min',
            width: width,
            height: height,
            left: trip.mapX! / 670 * width + 16,
            top: trip.mapY! / 622 * height - 20,
            preferredWidth: 128,
            color: Colors.white,
            foreground: DesignTokens.mutedText,
          ),
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: 2.5,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(children: layers),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: IgnorePointer(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: math.max(100, width - 80),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Illustrative map · No live GPS',
                  style: TextStyle(fontSize: 10, color: DesignTokens.mutedText),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: _zoom,
                    icon: const Icon(Icons.add, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Reset map view',
                    onPressed: () => _transform.value = Matrix4.identity(),
                    icon: const Icon(Icons.center_focus_strong, size: 18),
                  ),
                ],
              ),
            ),
          ),
          if (widget.trips.isEmpty)
            const Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No matching trips on this map.'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _marker(LiveTrip trip, double width, double height) {
    final markerSize = (width / 670 * 34).clamp(22.0, 34.0);
    final diameter = trip.condition == TripCondition.sos ? 68.0 : markerSize;
    final marker = trip.condition == TripCondition.sos
        ? _SosMarker(color: LiveTripsStyles.tripColor(trip.condition))
        : Container(
            width: markerSize,
            height: markerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LiveTripsStyles.tripColor(trip.condition),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: trip.id == widget.selectedTripId
                    ? DesignTokens.text
                    : Colors.white,
                width: 2.5,
              ),
            ),
            child: Icon(
              trip.condition == TripCondition.completed
                  ? Icons.check
                  : Icons.directions_bus_outlined,
              color: Colors.white,
              size: markerSize * .6,
            ),
          );
    return Positioned(
      left: trip.mapX! / 670 * width - diameter / 2,
      top: trip.mapY! / 622 * height - diameter / 2,
      child: Tooltip(
        message:
            '${trip.driver} · ${trip.vehicle} · ${widget.statusForTrip(trip)}',
        child: Semantics(
          button: true,
          selected: trip.id == widget.selectedTripId,
          label: 'Select trip ${trip.driver}',
          child: InkWell(
            key: ValueKey('map-trip-${trip.id}'),
            onTap: () => widget.onSelect(trip),
            borderRadius: BorderRadius.circular(12),
            child: marker,
          ),
        ),
      ),
    );
  }

  Widget _label(
    String text, {
    required double width,
    required double height,
    required double left,
    required double top,
    required double preferredWidth,
    required Color color,
    required Color foreground,
  }) {
    final labelWidth = math.min(preferredWidth, width - 16);
    return Positioned(
      left: left.clamp(8.0, math.max(8.0, width - labelWidth - 8)),
      top: top.clamp(8.0, math.max(8.0, height - 60)),
      child: IgnorePointer(
        child: Container(
          width: labelWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color == Colors.white ? DesignTokens.border : color,
              width: .8,
            ),
          ),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _SosMarker extends StatelessWidget {
  const _SosMarker({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 68,
    height: 68,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .16),
      shape: BoxShape.circle,
    ),
    child: Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
      ),
    ),
  );
}

class _SchoolPin extends StatelessWidget {
  const _SchoolPin();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 38,
    height: 48,
    child: CustomPaint(
      painter: _SchoolPinPainter(),
      child: Align(
        alignment: Alignment(0, -.35),
        child: Icon(Icons.home, color: Colors.white, size: 24),
      ),
    ),
  );
}

class _SchoolPinPainter extends CustomPainter {
  const _SchoolPinPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(19, 46)
      ..cubicTo(8, 34, 1, 27, 1, 19)
      ..cubicTo(1, -5, 37, -5, 37, 19)
      ..cubicTo(37, 27, 30, 35, 19, 46)
      ..close();
    canvas.drawPath(path, Paint()..color = DesignTokens.sidebar);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _SchoolPinPainter oldDelegate) => false;
}

class _MapRoadsPainter extends CustomPainter {
  const _MapRoadsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 670, size.height / 622);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 670, 622),
      Paint()..color = const Color(0xFFE3ECE9),
    );
    final water = Path()
      ..moveTo(494, 0)
      ..lineTo(670, 0)
      ..lineTo(670, 106)
      ..quadraticBezierTo(566, 104, 494, 0);
    canvas.drawPath(water, Paint()..color = const Color(0xFFCDE5EE));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 380, 200, 140),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFCEE5DA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(395, 300, 180, 120),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFD5E2DD),
    );
    final roads = Paint()..color = Colors.white;
    for (final x in [55.0, 195.0, 315.0, 455.0, 615.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x - 4, 0, x == 315 || x == 455 ? 16 : 8, 622),
        roads,
      );
    }
    for (final y in [141.0, 261.0, 461.0, 561.0]) {
      canvas.drawRect(Rect.fromLTWH(0, y - 4, 670, y == 461 ? 16 : 8), roads);
    }
    final route = Path()
      ..moveTo(55, 561)
      ..lineTo(55, 461)
      ..lineTo(195, 461)
      ..lineTo(195, 261)
      ..lineTo(315, 261);
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF80BCB6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapRoadsPainter oldDelegate) => false;
}
