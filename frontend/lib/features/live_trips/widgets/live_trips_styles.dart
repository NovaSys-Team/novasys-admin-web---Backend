import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/live_trip.dart';
import '../models/trip_incident.dart';

abstract final class LiveTripsStyles {
  static const success = Color(0xFF157A40);
  static const warning = Color(0xFF8A5A00);
  static const late = Color(0xFFE8603F);
  static const muted = TextStyle(
    fontSize: 12,
    height: 1.3,
    color: DesignTokens.mutedText,
  );
  static Color incidentColor(IncidentStatus status) => switch (status) {
    IncidentStatus.open => DesignTokens.danger,
    IncidentStatus.acknowledged => const Color(0xFFFFD27C),
    IncidentStatus.resolved => const Color(0xFF9ED7B5),
  };
  static Color tripColor(TripCondition condition) => switch (condition) {
    TripCondition.onTime => DesignTokens.primary,
    TripCondition.late => late,
    TripCondition.gpsStale => const Color(0xFF8A9B98),
    TripCondition.sos => DesignTokens.danger,
    TripCondition.completed => success,
  };
  static Color statusBackground(TripCondition condition) => switch (condition) {
    TripCondition.onTime || TripCondition.completed => const Color(0xFFE5F6EC),
    TripCondition.late => const Color(0xFFFFEDE7),
    TripCondition.gpsStale => const Color(0xFFFFF4DD),
    TripCondition.sos => const Color(0xFFFDECEC),
  };
}
