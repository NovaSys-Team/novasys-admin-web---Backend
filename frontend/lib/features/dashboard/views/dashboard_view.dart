import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/page_container.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/summary_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final summary = controller.summary;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: DesignTokens.spacing),
          const Text('Dashboard placeholder - Mock data only'),
          const SizedBox(height: DesignTokens.pagePadding),
          Wrap(
            spacing: DesignTokens.spacing,
            runSpacing: DesignTokens.spacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${controller.sessionLabel} session'),
              OutlinedButton.icon(
                onPressed: context.read<DashboardController>().toggleSession,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch mock session'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.pagePadding),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= DesignTokens.expandedBreakpoint
                  ? 3
                  : constraints.maxWidth >= 600
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth -
                      (columns - 1) * DesignTokens.spacing) /
                  columns;
              return Wrap(
                spacing: DesignTokens.spacing,
                runSpacing: DesignTokens.spacing,
                children: [
                  SizedBox(
                    width: width,
                    child: SummaryCard(
                      label: 'Active trips',
                      value: summary.activeTrips,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SummaryCard(
                      label: 'Pending verifications',
                      value: summary.pendingVerifications,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SummaryCard(
                      label: 'Open incidents',
                      value: summary.openIncidents,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
