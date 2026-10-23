import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../models/student.dart';

const studentMuted = TextStyle(
  color: DesignTokens.mutedText,
  fontSize: 12,
  height: 1.2,
);

class StudentAvatar extends StatelessWidget {
  const StudentAvatar(this.student, {super.key, this.large = false});
  final Student student;
  final bool large;
  @override
  Widget build(BuildContext context) => Container(
    width: large ? 60 : 36,
    height: large ? 60 : 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: switch (student.id) {
        's1' || 's4' => const Color(0xFFFFD0C2),
        's2' => const Color(0xFFCCE8E6),
        's5' => const Color(0xFFFFF3DB),
        _ => const Color(0xFFE5DFF5),
      },
      borderRadius: BorderRadius.circular(large ? 18 : 12),
    ),
    child: Text(
      student.name[0],
      style: TextStyle(
        fontSize: large ? 23 : 14,
        fontWeight: FontWeight.w600,
        color: DesignTokens.sidebar,
      ),
    ),
  );
}

class StudentFeeBadge extends StatelessWidget {
  const StudentFeeBadge(this.fee, {super.key});
  final StudentFee fee;
  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (fee) {
      StudentFee.paid => (
        'Paid',
        const Color(0xFF008639),
        const Color(0xFFE3F5EB),
      ),
      StudentFee.due => (
        'Due',
        const Color(0xFF9D6400),
        const Color(0xFFFFF3DB),
      ),
      StudentFee.overdue => (
        'Overdue',
        const Color(0xFFD9001B),
        const Color(0xFFFFECEF),
      ),
      StudentFee.none => ('—', DesignTokens.mutedText, const Color(0xFFEDF2F1)),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

ButtonStyle studentButtonStyle({bool primary = false}) =>
    OutlinedButton.styleFrom(
      foregroundColor: primary ? DesignTokens.primary : DesignTokens.text,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: primary ? DesignTokens.primary : DesignTokens.border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
