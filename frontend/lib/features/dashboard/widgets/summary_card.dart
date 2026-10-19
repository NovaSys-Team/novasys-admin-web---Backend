import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(DesignTokens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: DesignTokens.mutedText)),
          const SizedBox(height: DesignTokens.spacing),
          Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    ),
  );
}
