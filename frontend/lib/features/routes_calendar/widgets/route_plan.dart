import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/routes_calendar_controller.dart';
import '../models/school_route.dart';
import 'routes_calendar_styles.dart';
import 'routes_list_dialog.dart';

class RoutePlan extends StatelessWidget {
  const RoutePlan({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoutesCalendarController>();
    final route = c.route;
    final title = InkWell(
      key: const ValueKey('route-selector'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => showRoutesList(context, c),
      child: Tooltip(
        message: 'Choose route',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${route.id} · ${route.origin} '),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.arrow_forward,
                      size: 17,
                      color: DesignTokens.text,
                    ),
                  ),
                  TextSpan(text: ' ${route.destinations}'),
                ],
              ),
              style: RoutesCalendarStyles.heading,
            ),
            const SizedBox(height: 2),
            Text(
              '${route.driver} · ${route.plate} · ${c.planLabel}',
              style: RoutesCalendarStyles.muted,
            ),
          ],
        ),
      ),
    );
    final tabs = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 2,
        children: TripPeriod.values
            .map(
              (period) => Semantics(
                selected: c.period == period,
                child: TextButton(
                  key: ValueKey('period-${period.name}'),
                  onPressed: () => c.selectPeriod(period),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.standard,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(0, 36),
                    foregroundColor: c.period == period
                        ? DesignTokens.text
                        : DesignTokens.mutedText,
                    backgroundColor: c.period == period
                        ? Colors.white
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'NovaSysSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    period == TripPeriod.morning ? 'Morning' : 'Afternoon',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    var sequence = 0;
    final stops = route.stopsFor(c.period);
    return RoutesCalendarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 620 ||
                  MediaQuery.textScalerOf(context).scale(14) > 16) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), tabs],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  tabs,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (c.closedSchools.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                c.noTrips
                    ? 'No trips · School holiday · no absences needed'
                    : 'No-trip day: ${c.closedSchools.join(', ')}. Other schools remain on the plan.',
                style: const TextStyle(
                  color: DesignTokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (var i = 0; i < stops.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _StopTile(
              stop: stops[i],
              skipped: c.skipped(stops[i]),
              number: stops[i].kind != StopKind.depot && !c.skipped(stops[i])
                  ? ++sequence
                  : 0,
              time: c.stopTime(stops[i]),
              absenceToday: c.absent(stops[i]),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Stops are removed only when every student at that stop is absent. Completed stops are never reordered during an active trip.',
            style: RoutesCalendarStyles.muted,
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stop,
    required this.skipped,
    required this.number,
    required this.time,
    required this.absenceToday,
  });
  final RouteStop stop;
  final bool skipped, absenceToday;
  final int number;
  final String time;
  @override
  Widget build(BuildContext context) {
    final school = stop.kind == StopKind.school;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: skipped ? const Color(0xFFF9FBFA) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F4F3)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: skipped
                  ? const Color(0xFFFFEDE7)
                  : school
                  ? DesignTokens.sidebar
                  : stop.kind == StopKind.depot
                  ? const Color(0xFFEDF2F1)
                  : RoutesCalendarStyles.tealFill,
              borderRadius: BorderRadius.circular(school && !skipped ? 8 : 20),
            ),
            child: Text(
              skipped
                  ? '−'
                  : stop.kind == StopKind.depot
                  ? '•'
                  : '$number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: skipped
                    ? const Color(0xFFD33A00)
                    : school
                    ? Colors.white
                    : stop.kind == StopKind.depot
                    ? DesignTokens.mutedText
                    : DesignTokens.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: skipped ? DesignTokens.mutedText : DesignTokens.text,
                  ),
                ),
                Text(
                  skipped && !absenceToday
                      ? 'School no-trip day'
                      : !absenceToday && stop.absent
                      ? stop.description.split(' · ').first
                      : stop.description,
                  style: RoutesCalendarStyles.muted,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DesignTokens.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
