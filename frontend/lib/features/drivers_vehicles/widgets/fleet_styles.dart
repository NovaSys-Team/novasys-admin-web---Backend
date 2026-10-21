import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/driver_vehicle.dart';

abstract final class FleetStyles {
  static const muted = TextStyle(fontSize: 12, color: DesignTokens.mutedText);
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const green = Color(0xFF008537);
  static const amber = Color(0xFF995F00);
  static const red = Color(0xFFE22529);
  static Color complianceColor(ComplianceLevel level) => switch (level) {
    ComplianceLevel.valid => green,
    ComplianceLevel.warning => amber,
    ComplianceLevel.blocked => red,
  };
  static ButtonStyle button({Color? color}) => OutlinedButton.styleFrom(
    foregroundColor: color ?? DesignTokens.text,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    side: BorderSide(
      color: color?.withValues(alpha: 0.5) ?? DesignTokens.border,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(
      fontFamily: 'NovaSysSans',
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

class FleetCard extends StatelessWidget {
  const FleetCard({
    super.key,
    required this.child,
    this.borderColor = DesignTokens.border,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor),
    ),
    child: child,
  );
}

class FleetBadge extends StatelessWidget {
  const FleetBadge(this.label, {super.key, this.danger = false});
  final String label;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: danger ? const Color(0xFFFFECEB) : const Color(0xFFE5F5F3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: danger ? FleetStyles.red : DesignTokens.primary,
      ),
    ),
  );
}

void fleetFeedback(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
