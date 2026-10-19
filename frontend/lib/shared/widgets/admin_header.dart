import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    this.onOpenMenu,
    this.title,
    this.subtitle,
    this.actions,
  });
  final VoidCallback? onOpenMenu;
  final String? title;
  final String? subtitle;
  final Widget? actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.shellPadding,
      vertical: 24,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (title != null) {
          // Feature pages place their full heading in the scrollable content
          // at narrow widths, leaving room for navigation and filter controls.
          if (constraints.maxWidth < DesignTokens.compactPageHeaderWidth) {
            return Row(
              children: [
                if (onOpenMenu != null)
                  IconButton(
                    tooltip: 'Open navigation',
                    onPressed: onOpenMenu,
                    icon: const Icon(Icons.menu),
                  ),
                const Spacer(),
                ?actions,
              ],
            );
          }
          return Row(
            children: [
              if (onOpenMenu != null) ...[
                IconButton(
                  tooltip: 'Open navigation',
                  onPressed: onOpenMenu,
                  icon: const Icon(Icons.menu),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(height: 1.2),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignTokens.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...[const SizedBox(width: 12), actions!],
            ],
          );
        }
        final showSearch = constraints.maxWidth >= 850;
        return Row(
          children: [
            if (onOpenMenu != null) ...[
              IconButton(
                tooltip: 'Open navigation',
                onPressed: onOpenMenu,
                icon: const Icon(Icons.menu),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo workspace',
                    style: TextStyle(
                      color: DesignTokens.mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Good morning, Shehani',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (showSearch) ...[
              const SizedBox(
                width: 290,
                child: Tooltip(
                  message: 'Search is coming soon',
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Search students, drivers, plates',
                      prefixIcon: Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: DesignTokens.border),
                      ),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: DesignTokens.mutedText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Tooltip(
              message: 'Shehani - Demo administrator',
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DesignTokens.avatarBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SK',
                  style: TextStyle(
                    color: DesignTokens.sidebar,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
