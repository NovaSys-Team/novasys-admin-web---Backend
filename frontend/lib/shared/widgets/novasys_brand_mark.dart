import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

class NovaSysBrandMark extends StatelessWidget {
  const NovaSysBrandMark({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(size * 11 / 36),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'N',
          style: TextStyle(
            fontSize: size * 20 / 36,
            fontWeight: FontWeight.w700,
            color: DesignTokens.primary,
          ),
        ),
        Positioned(
          top: size / 4,
          right: size / 4,
          child: Container(
            width: size * 5 / 36,
            height: size * 5 / 36,
            decoration: const BoxDecoration(
              color: DesignTokens.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}
