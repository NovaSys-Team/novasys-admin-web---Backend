import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

/// Persistent admin chrome; routed features provide only their page content.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.currentPath, required this.child});
  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= DesignTokens.sidebarBreakpoint;
      return Scaffold(
        drawer: desktop
            ? null
            : Drawer(
                width: DesignTokens.sidebarWidth,
                shape: const RoundedRectangleBorder(),
                child: Builder(
                  builder: (context) => AdminSidebar(
                    currentPath: currentPath,
                    onNavigate: () => Scaffold.of(context).closeDrawer(),
                  ),
                ),
              ),
        body: Row(
          children: [
            if (desktop)
              SizedBox(
                width: DesignTokens.sidebarWidth,
                child: AdminSidebar(currentPath: currentPath),
              ),
            Expanded(
              child: Column(
                children: [
                  Builder(
                    builder: (context) => AdminHeader(
                      onOpenMenu: desktop
                          ? null
                          : () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
