import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/driver_application.dart';

abstract final class VerificationStyles {
  static const success = Color(0xFF157A40);
  static const warning = Color(0xFF8A5A00);
  static const danger = Color(0xFFC62A2F);
  static const muted = TextStyle(
    fontSize: 12,
    height: 1.3,
    color: DesignTokens.mutedText,
  );
  static const panelShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    side: BorderSide(color: DesignTokens.border, width: .8),
  );
  static Color avatar(int index) => const [
    Color(0xFFE6E1F5),
    Color(0xFFFFD2C4),
    Color(0xFFCFE8E4),
    Color(0xFFFFF4DD),
  ][index % 4];
  static Color documentColor(DocumentStatus status) => switch (status) {
    DocumentStatus.valid => success,
    DocumentStatus.unreadable => danger,
    DocumentStatus.expiring => warning,
  };
  static Color documentBorder(DocumentStatus status) => switch (status) {
    DocumentStatus.valid => const Color(0xFF9ED7B5),
    DocumentStatus.unreadable => const Color(0xFFFFBEC1),
    DocumentStatus.expiring => const Color(0xFFFFD58A),
  };
}

class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({
    super.key,
    required this.application,
    this.detail = false,
  });
  final DriverApplication application;
  final bool detail;
  @override
  Widget build(BuildContext context) {
    final success =
        application.status == ApplicationStatus.verified ||
        (!detail && application.canApprove);
    final warning =
        (detail && application.status == ApplicationStatus.pending) ||
        application.status == ApplicationStatus.reuploadRequested;
    final color = success
        ? const Color(0xFF0A6A60)
        : warning
        ? VerificationStyles.warning
        : VerificationStyles.danger;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: detail ? 12 : 9,
        vertical: detail ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: success
            ? const Color(0xFFE6F5F3)
            : warning
            ? const Color(0xFFFFF4DD)
            : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        detail ? application.detailStatus : application.listStatus,
        style: TextStyle(
          fontSize: detail ? 12 : 10,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
