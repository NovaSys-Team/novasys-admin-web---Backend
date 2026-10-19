import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/dashboard_summary.dart';

abstract final class DashboardStyles {
  static Color foreground(DashboardTone tone) => switch (tone) {
    DashboardTone.neutral => DesignTokens.mutedText,
    DashboardTone.teal => const Color(0xFF0A6A60),
    DashboardTone.success => const Color(0xFF087D35),
    DashboardTone.warning => const Color(0xFF8A5A00),
    DashboardTone.danger => const Color(0xFFC62A2F),
    DashboardTone.orange => const Color(0xFFB8401F),
  };
  static Color background(DashboardTone tone) => switch (tone) {
    DashboardTone.neutral => const Color(0xFFEEF2F1),
    DashboardTone.teal => const Color(0xFFE5F4F2),
    DashboardTone.success => const Color(0xFFE5F6EC),
    DashboardTone.warning => const Color(0xFFFFF4DC),
    DashboardTone.danger => const Color(0xFFFDECEC),
    DashboardTone.orange => const Color(0xFFFFEDE7),
  };
  static const heading = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: DesignTokens.text,
  );
  static const secondary = TextStyle(
    fontSize: 12,
    height: 1.2,
    color: DesignTokens.mutedText,
  );
  static const panelBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    side: BorderSide(color: DesignTokens.border, width: .8),
  );
}

class DashboardActionLink extends StatelessWidget {
  const DashboardActionLink({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward, size: 13),
      ],
    ),
  );
}

class DashboardRouteLabel extends StatelessWidget {
  const DashboardRouteLabel({super.key, required this.route});
  final String route;
  @override
  Widget build(BuildContext context) {
    final parts = route.split(' → ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(parts.first),
        if (parts.length > 1) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Icon(Icons.arrow_forward, size: 13),
          ),
          Text(parts.last),
        ],
      ],
    );
  }
}
