import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/page_container.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/attention_panel.dart';
import '../widgets/dashboard_details_dialog.dart';
import '../widgets/incident_banner.dart';
import '../widgets/morning_trips_table.dart';
import '../widgets/summary_card.dart';
import '../widgets/transport_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final chart = TransportChart(
      days: controller.days,
      selectedIndex: controller.selectedDayIndex,
      onSelect: context.read<DashboardController>().selectDay,
      onReport: () => showDashboardDetails(
        context,
        title: 'Students transported report',
        description:
            'Last 10 school days · both trips. Total: ${controller.totalTransported} student journeys. Counts are mock values; 19 October is a partial day.',
        content: Column(
          children: [
            for (final day in controller.days)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(day.label), Text('${day.count}')],
                ),
              ),
          ],
        ),
      ),
    );
    final attention = AttentionPanel(
      items: controller.attention,
      onOpen: (item) => showDashboardDetails(
        context,
        title: item.title,
        description: '${item.count} · ${item.description}\n\n${item.detail}',
      ),
    );
    return Semantics(
      label: 'Admin overview',
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncidentBanner(
              incident: controller.incident,
              onOpen: () => showDashboardDetails(
                context,
                title: 'SOS · Breakdown',
                description:
                    '${controller.incident.headline}\n\nThis is a local incident preview. No driver, parent or emergency service has been contacted.',
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 5
                    : constraints.maxWidth >= 850
                    ? 4
                    : constraints.maxWidth >= 600
                    ? 3
                    : constraints.maxWidth >= 400
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final metric in controller.metrics)
                      SizedBox(
                        width: width,
                        child: SummaryCard(
                          metric: metric,
                          onTap: () => showDashboardDetails(
                            context,
                            title: metric.label,
                            description:
                                '${metric.value}\n${metric.description}\n\n${metric.detail}',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1000) {
                  return Column(
                    children: [chart, const SizedBox(height: 20), attention],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 61, child: chart),
                    const SizedBox(width: 16),
                    Expanded(flex: 39, child: attention),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            MorningTripsTable(
              trips: controller.trips,
              onOpenTrip: (trip) => showDashboardDetails(
                context,
                title: trip.driver,
                description:
                    '${trip.vehicle}\n${trip.route}\nOn board: ${trip.onboard}\nGPS snapshot: ${trip.gps}\nETA school: ${trip.eta}\nStatus: ${trip.status}\n\nNo real GPS connection or trip changes are made.',
              ),
              onOpenMap: () => showDashboardDetails(
                context,
                title: 'Live map preview',
                description: 'Live GPS is not connected. These are the four mock route snapshots shown in the table.',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final trip in controller.trips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${trip.driver}\n${trip.route.replaceAll(' → ', ' to ')} · ${trip.gps}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
