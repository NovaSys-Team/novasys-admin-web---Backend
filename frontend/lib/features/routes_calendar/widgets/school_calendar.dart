import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/routes_calendar_controller.dart';
import '../models/school_calendar_event.dart';
import 'calendar_dialogs.dart';
import 'routes_calendar_styles.dart';

class SchoolCalendar extends StatelessWidget {
  const SchoolCalendar({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoutesCalendarController>();
    return RoutesCalendarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                key: const ValueKey('calendar-date-picker'),
                onTap: () => selectCalendarDate(context, c),
                borderRadius: BorderRadius.circular(8),
                child: Tooltip(
                  message: 'Choose calendar date',
                  child: Text(
                    c.monthLabel,
                    style: RoutesCalendarStyles.heading,
                  ),
                ),
              ),
              OutlinedButton(
                key: const ValueKey('add-no-trip-day'),
                onPressed: () => showNoTripDayDialog(context, c),
                style: RoutesCalendarStyles.outlineButton,
                child: const Text('Add no-trip day'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                .map(
                  (day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          day,
                          style: RoutesCalendarStyles.muted.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          for (var week = 0; week < c.calendarWeeks.length; week++) ...[
            if (week > 0) const SizedBox(height: 6),
            Row(
              children: [
                for (var day = 0; day < 5; day++) ...[
                  if (day > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _CalendarDay(
                      day: c.calendarWeeks[week][day],
                      controller: c,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (c.monthEvents.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...c.monthEvents.map((event) => _CalendarLegend(event: event)),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'No calendar events this month.',
              style: RoutesCalendarStyles.muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.controller});
  final DateTime? day;
  final RoutesCalendarController controller;
  @override
  Widget build(BuildContext context) {
    final date = day;
    if (date == null) return const SizedBox(height: 38);
    final events = controller.eventsOn(date);
    final holiday = events.any((e) => e.kind == SchoolEventKind.noTrip);
    final exams = events.any((e) => e.kind == SchoolEventKind.exams);
    final selected = controller.selectedDate == date;
    final fill = holiday
        ? RoutesCalendarStyles.holiday
        : exams
        ? const Color(0xFFFFF4DC)
        : selected
        ? RoutesCalendarStyles.tealFill
        : DesignTokens.background;
    final border = selected
        ? DesignTokens.primary
        : exams
        ? RoutesCalendarStyles.amberBorder
        : Colors.transparent;
    return Semantics(
      selected: selected,
      button: true,
      label:
          '${RoutesCalendarController.shortDate(date)} ${date.year}${holiday
              ? ', no-trip day'
              : exams
              ? ', exams'
              : ''}',
      child: Tooltip(
        message:
            '${RoutesCalendarController.shortDate(date)}${events.isEmpty ? '' : ': ${events.map((e) => '${e.description} (${e.school})').join(', ')}'}',
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: border, width: 1.3),
          ),
          child: InkWell(
            key: ValueKey(
              'calendar-day-${date.year}-${date.month}-${date.day}',
            ),
            borderRadius: BorderRadius.circular(10),
            onTap: () => controller.selectDate(date),
            child: SizedBox(
              height: 38,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: holiday
                        ? Colors.white
                        : exams
                        ? RoutesCalendarStyles.amber
                        : selected
                        ? DesignTokens.primary
                        : DesignTokens.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.event});
  final SchoolCalendarEvent event;
  @override
  Widget build(BuildContext context) {
    final holiday = event.kind == SchoolEventKind.noTrip;
    final date = event.start == event.end
        ? '${event.start.day}\n${RoutesCalendarController.monthNames[event.start.month - 1].substring(0, 3)}'
        : '${event.start.day}–${event.end.day}\n${RoutesCalendarController.monthNames[event.start.month - 1].substring(0, 3)}';
    final description = holiday
        ? '${event.description} (${event.school.toLowerCase() == 'all schools' ? 'all schools' : event.school}) · no trips, no absences needed'
        : '${event.school} ${event.description} · afternoon pickup ${event.afternoonPickup}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: holiday ? RoutesCalendarStyles.holiday : Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: holiday
                      ? RoutesCalendarStyles.holiday
                      : RoutesCalendarStyles.amberBorder,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44 * MediaQuery.textScalerOf(context).scale(13) / 13,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '· $description',
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
