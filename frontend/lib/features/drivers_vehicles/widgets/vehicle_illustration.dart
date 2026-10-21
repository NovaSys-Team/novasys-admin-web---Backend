import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

class VehicleIllustration extends StatelessWidget {
  const VehicleIllustration({super.key, required this.plate});
  final String plate;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Illustration of vehicle $plate',
    image: true,
    child: Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFDCEFEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _VanPainter())),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DesignTokens.text,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                plate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _VanPainter extends CustomPainter {
  const _VanPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.width < 240 ? size.width / 260 : 1.0;
    canvas.translate((size.width - 220 * scale) / 2, 48);
    canvas.scale(scale);
    final paint = Paint();
    canvas.drawOval(
      const Rect.fromLTWH(0, 91, 220, 9),
      paint..color = const Color(0xFFBDD2CE),
    );
    final body = Path()
      ..moveTo(4, 76)
      ..lineTo(4, 28)
      ..quadraticBezierTo(4, 8, 25, 8)
      ..lineTo(158, 8)
      ..quadraticBezierTo(176, 8, 188, 25)
      ..lineTo(212, 57)
      ..quadraticBezierTo(217, 64, 217, 76)
      ..close();
    canvas.drawPath(
      body,
      paint
        ..color = const Color(0xFFF5F9F8)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      body,
      paint
        ..color = const Color(0xFFAEC2BE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2C4C49);
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(20 + i * 47, 19, 39, 26),
          const Radius.circular(5),
        ),
        paint,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(158, 19)
        ..lineTo(170, 19)
        ..lineTo(191, 45)
        ..lineTo(158, 45)
        ..close(),
      paint,
    );
    for (final x in [44.0, 177.0]) {
      canvas.drawCircle(
        Offset(x, 79),
        16,
        paint..color = const Color(0xFF1B302E),
      );
      canvas.drawCircle(
        Offset(x, 79),
        6.5,
        paint..color = const Color(0xFFCBD8D5),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VanPainter oldDelegate) => false;
}
