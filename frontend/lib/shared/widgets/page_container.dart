import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

/// Constrains wide browser content and allows vertical scrolling.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(
      DesignTokens.shellPadding,
      0,
      DesignTokens.shellPadding,
      DesignTokens.shellPadding,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DesignTokens.contentWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}
