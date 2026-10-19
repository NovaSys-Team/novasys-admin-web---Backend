import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/novasys_brand_mark.dart';

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(compact ? 24 : 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            NovaSysBrandMark(size: 44),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'NovaSys Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (!compact) ...[
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Every school ride, safe\nand on time.',
                  style: TextStyle(
                    fontSize: 36,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -.6,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Monitor live trips, verify drivers, manage payments and support parents from one place.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: DesignTokens.sidebarText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// Native Flutter painting of the decorative circle, dotted route and bus.
class AuthIllustration extends CustomPainter {
  const AuthIllustration();
  @override
  void paint(Canvas canvas, Size size) {
    final boundary = size.width / 2;
    final bottom = size.height;
    canvas.drawCircle(
      Offset(boundary - 60, bottom - 200),
      200,
      Paint()..color = DesignTokens.primary.withValues(alpha: .4),
    );
    final route = Path()
      ..moveTo(boundary - 420, bottom - 50)
      ..cubicTo(
        boundary - 300,
        bottom - 110,
        boundary - 220,
        bottom - 5,
        boundary - 120,
        bottom - 75,
      )
      ..cubicTo(
        boundary - 20,
        bottom - 155,
        boundary + 35,
        bottom - 165,
        boundary + 100,
        bottom - 120,
      );
    final metric = route.computeMetrics().first;
    final dotPaint = Paint()..color = const Color(0xFF0E9F8E);
    for (var distance = 0.0; distance < metric.length; distance += 28) {
      canvas.drawCircle(
        metric.getTangentForOffset(distance)!.position,
        6.5,
        dotPaint,
      );
    }
    final left = boundary - 190;
    final top = bottom - 170;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, 120, 66),
        const Radius.circular(18),
      ),
      Paint()..color = DesignTokens.accent,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 12 + i * 34, top + 12, 28, 20),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFFFFF4EF),
      );
    }
    for (final dx in [30.0, 92.0]) {
      canvas.drawCircle(
        Offset(left + dx, top + 68),
        11,
        Paint()..color = DesignTokens.text,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AuthIllustration oldDelegate) => false;
}
