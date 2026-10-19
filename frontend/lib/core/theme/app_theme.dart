import 'package:flutter/material.dart';

import 'design_tokens.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DesignTokens.primary,
      primary: DesignTokens.primary,
      surface: Colors.white,
      onSurface: DesignTokens.text,
    ),
    scaffoldBackgroundColor: DesignTokens.background,
    dividerColor: DesignTokens.border,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.cornerRadius),
        side: const BorderSide(color: DesignTokens.border),
      ),
    ),
  );
}
