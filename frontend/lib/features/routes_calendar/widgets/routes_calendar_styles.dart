import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

abstract final class RoutesCalendarStyles {
  static const muted = TextStyle(
    fontSize: 12,
    color: DesignTokens.mutedText,
    height: 1.4,
  );
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const amber = Color(0xFF9A6100);
  static const amberBorder = Color(0xFFD98D00);
  static const holiday = Color(0xFF102E2B);
  static const tealFill = Color(0xFFE5F5F3);
  static ButtonStyle get outlineButton => OutlinedButton.styleFrom(
    visualDensity: VisualDensity.standard,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: DesignTokens.primary,
    side: const BorderSide(color: DesignTokens.primary, width: 0.7),
    minimumSize: const Size(0, 34),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(
      fontFamily: 'NovaSysSans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
  static InputDecoration input(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}

class RoutesCalendarCard extends StatelessWidget {
  const RoutesCalendarCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: DesignTokens.border),
    ),
    child: child,
  );
}

void calendarFeedback(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
