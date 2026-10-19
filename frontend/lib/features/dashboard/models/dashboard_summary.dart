class DashboardSummary {
  const DashboardSummary({
    required this.activeTrips,
    required this.pendingVerifications,
    required this.openIncidents,
  });
  final int activeTrips;
  final int pendingVerifications;
  final int openIncidents;
}
