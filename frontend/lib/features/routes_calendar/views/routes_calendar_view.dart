import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../controllers/routes_calendar_controller.dart';
import '../widgets/route_plan.dart';
import '../widgets/routes_list_dialog.dart';
import '../widgets/school_calendar.dart';
import '../widgets/trip_rules_card.dart';

class RoutesCalendarView extends StatelessWidget {
  const RoutesCalendarView({super.key});
  static const title = 'Routes & school calendar';
  static const subtitle =
      'Stop order, geofence rules, cutoffs and no-trip days';
  @override
  Widget build(BuildContext context) => PageContainer(
    child: LayoutBuilder(
      builder: (context, constraints) {
        const plan = RoutePlan();
        const calendar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SchoolCalendar(), SizedBox(height: 16), TripRulesCard()],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (constraints.maxWidth < DesignTokens.compactPageHeaderWidth) ...[
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text(
                subtitle,
                style: TextStyle(color: DesignTokens.mutedText),
              ),
              const SizedBox(height: 18),
            ],
            if (constraints.maxWidth >= 950)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 63, child: plan),
                  SizedBox(width: 16),
                  Expanded(flex: 37, child: calendar),
                ],
              )
            else ...[
              plan,
              const SizedBox(height: 16),
              calendar,
            ],
          ],
        );
      },
    ),
  );
}

class RoutesCalendarHeaderActions extends StatelessWidget {
  const RoutesCalendarHeaderActions({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Find a route',
    onPressed: () =>
        showRoutesList(context, context.read<RoutesCalendarController>()),
    icon: const Icon(Icons.search),
  );
}
