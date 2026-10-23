enum TripRule {
  morningCutoff('Morning absence cutoff', '06:30', ''),
  afternoonCutoff('Afternoon cutoff', '13:00', ''),
  arrivalRadius('Arrival radius', '100', 'm'),
  departureRadius('Departure radius', '150', 'm'),
  maxGpsAge('Max GPS age', '120', 's'),
  maxGpsAccuracy('Max GPS accuracy', '100', 'm');

  const TripRule(this.label, this.initialValue, this.unit);
  final String label, initialValue, unit;
  bool get isTime => unit.isEmpty;
}

class RuleChange {
  const RuleChange(this.rule, this.previous, this.value);
  final TripRule rule;
  final String previous, value;
}
