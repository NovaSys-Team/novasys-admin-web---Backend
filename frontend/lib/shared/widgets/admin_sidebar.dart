import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/admin_navigation.dart';
import '../../core/theme/design_tokens.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.currentPath, this.onNavigate});
  final String currentPath;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) => Material(
    color: DesignTokens.sidebar,
    child: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Row(
              children: [
                _BrandMark(),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NovaSys',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Admin console',
                        style: TextStyle(
                          color: DesignTokens.sidebarText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AdminNavigation.destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final destination = AdminNavigation.destinations[index];
                final selected = destination.path == currentPath;
                final available = destination.path != null;
                return Tooltip(
                  message: available
                      ? destination.label
                      : '${destination.label} - Coming soon',
                  child: Semantics(
                    key: ValueKey('admin-navigation-$index'),
                    selected: selected,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 42),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        alignment: Alignment.centerLeft,
                        foregroundColor: selected
                            ? Colors.white
                            : DesignTokens.sidebarText,
                        disabledForegroundColor: DesignTokens.sidebarText,
                        backgroundColor: selected
                            ? DesignTokens.sidebarSelected
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onPressed: available
                          ? () {
                              context.go(destination.path!);
                              onNavigate?.call();
                            }
                          : null,
                      child: Row(
                        children: [
                          Icon(destination.icon, size: 18),
                          const SizedBox(width: 12),
                          Expanded(child: Text(destination.label)),
                          if (destination.badge != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? DesignTokens.danger
                                    : index == 4
                                    ? DesignTokens.accent
                                    : DesignTokens.sidebarSelected,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                destination.badge!,
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: index == 4
                                      ? DesignTokens.sidebar
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Tooltip(
              message: 'Sign out is unavailable in this mock workspace',
              child: TextButton(
                onPressed: null,
                style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  foregroundColor: WidgetStatePropertyAll(
                    DesignTokens.sidebarText,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 12),
                    Text('Sign out'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        const Text(
          'N',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: DesignTokens.primary,
          ),
        ),
        Positioned(
          top: 9,
          right: 9,
          child: Container(
            width: 5,
            height: 5,
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
