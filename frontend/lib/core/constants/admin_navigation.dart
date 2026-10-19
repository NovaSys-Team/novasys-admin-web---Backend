import 'package:flutter/material.dart';

/// Shared destination metadata. Only implemented destinations have a path.
class AdminDestination {
  const AdminDestination(this.label, this.icon, {this.path, this.badge});
  final String label;
  final IconData icon;
  final String? path;
  final String? badge;
}

abstract final class AdminNavigation {
  static const dashboardPath = '/dashboard';
  static const verificationPath = '/driver-verification';
  static const liveTripsPath = '/live-trips';
  static const paymentsPath = '/payments';
  static const settlementsPath = '/payments/settlements';
  static const destinations = [
    AdminDestination('Overview', Icons.bar_chart_outlined, path: dashboardPath),
    AdminDestination(
      'Live trips',
      Icons.location_on_outlined,
      path: liveTripsPath,
      badge: 'SOS 1',
    ),
    AdminDestination('Students', Icons.people_outline),
    AdminDestination('Drivers & vehicles', Icons.directions_bus_outlined),
    AdminDestination(
      'Verification',
      Icons.verified_user_outlined,
      path: verificationPath,
      badge: '4',
    ),
    AdminDestination(
      'Payments',
      Icons.credit_card_outlined,
      path: paymentsPath,
    ),
    AdminDestination('Send notification', Icons.campaign_outlined),
    AdminDestination('Reports', Icons.description_outlined),
    AdminDestination('Support', Icons.chat_bubble_outline, badge: '9'),
    AdminDestination('Routes & calendar', Icons.alt_route),
  ];
}
