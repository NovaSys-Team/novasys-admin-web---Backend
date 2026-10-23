import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

const reportMuted = TextStyle(
  color: DesignTokens.mutedText,
  fontSize: 12,
  height: 1.4,
);
const reportLabel = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

class ReportPanel extends StatelessWidget {
  const ReportPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: DesignTokens.border),
    ),
    child: child,
  );
}
