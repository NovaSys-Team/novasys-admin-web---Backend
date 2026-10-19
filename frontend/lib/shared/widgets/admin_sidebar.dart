import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/admin_navigation.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/auth/controllers/demo_session_controller.dart';
import 'novasys_brand_mark.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.currentPath,
    this.onNavigate,
    this.verificationCount,
    this.liveIncidentCount,
  });
  final String currentPath;
  final VoidCallback? onNavigate;
  final int? verificationCount;
  final int? liveIncidentCount;

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
                NovaSysBrandMark(),
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
                final selected =
                    destination.path != null &&
                    (destination.path == currentPath ||
                        currentPath.startsWith('${destination.path}/'));
                final available = destination.path != null;
                final String? badge;
                if (destination.path == AdminNavigation.verificationPath &&
                    verificationCount != null) {
                  badge = '$verificationCount';
                } else if (destination.path == AdminNavigation.liveTripsPath &&
                    liveIncidentCount != null) {
                  badge = liveIncidentCount == 0
                      ? null
                      : 'SOS $liveIncidentCount';
                } else {
                  badge = destination.badge;
                }
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
                          if (badge != null) ...[
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
                                badge,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Tooltip(
              message: 'End this demo session',
              child: TextButton(
                onPressed: () =>
                    context.read<DemoSessionController>().signOut(),
                style: const ButtonStyle(
                  alignment: Alignment.centerLeft,
                  foregroundColor: WidgetStatePropertyAll(
                    DesignTokens.sidebarText,
                  ),
                ),
                child: const Row(
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
