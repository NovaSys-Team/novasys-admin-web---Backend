import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

/// Persistent admin chrome; routed features provide only their page content.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentPath,
    required this.child,
    this.title,
    this.subtitle,
    this.headerActions,
    this.verificationCount,
    this.liveIncidentCount,
  });
  final String currentPath;
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerActions;
  final int? verificationCount;
  final int? liveIncidentCount;

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
                    verificationCount: verificationCount,
                    liveIncidentCount: liveIncidentCount,
                    onNavigate: () => Scaffold.of(context).closeDrawer(),
                  ),
                ),
              ),
        body: Row(
          children: [
            if (desktop)
              SizedBox(
                width: DesignTokens.sidebarWidth,
                child: AdminSidebar(
                  currentPath: currentPath,
                  verificationCount: verificationCount,
                  liveIncidentCount: liveIncidentCount,
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Builder(
                    builder: (context) => AdminHeader(
                      title: title,
                      subtitle: subtitle,
                      actions: headerActions,
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
