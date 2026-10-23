import 'package:flutter/material.dart';

import '../controllers/routes_calendar_controller.dart';
import '../models/school_calendar_event.dart';
import '../models/trip_rule.dart';
import 'routes_calendar_styles.dart';

Future<DateTime?> _pickDate(BuildContext context, DateTime date) =>
    showDatePicker(
      context: context,
      initialDate: date,
      firstDate: RoutesCalendarController.firstDate,
      lastDate: RoutesCalendarController.lastDate,
      currentDate: RoutesCalendarController.demoToday,
      selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
      helpText: 'Select school calendar date',
    );
Future<void> selectCalendarDate(
  BuildContext context,
  RoutesCalendarController c,
) async {
  final day = await _pickDate(context, c.selectedDate);
  if (day != null && context.mounted) c.selectDate(day);
}

Future<void> showNoTripDayDialog(
  BuildContext context,
  RoutesCalendarController c,
) async {
  final added = await showDialog<bool>(
    context: context,
    builder: (_) => _NoTripDayDialog(controller: c),
  );
  if (added == true && context.mounted) {
    calendarFeedback(
      context,
      'No-trip day added to this demo. No notifications sent.',
    );
  }
}

class _NoTripDayDialog extends StatefulWidget {
  const _NoTripDayDialog({required this.controller});
  final RoutesCalendarController controller;
  @override
  State<_NoTripDayDialog> createState() => _NoTripDayDialogState();
}

class _NoTripDayDialogState extends State<_NoTripDayDialog> {
  final form = GlobalKey<FormState>();
  final reason = TextEditingController(text: 'School holiday');
  late DateTime date = widget.controller.selectedDate;
  String school = SchoolCalendarEvent.allSchools;
  String? error;
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  void confirm() {
    if (!form.currentState!.validate()) return;
    final result = widget.controller.addNoTripDay(
      date: date,
      school: school,
      reason: reason.text,
    );
    if (result != null) {
      setState(() => error = result);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add no-trip day'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirm a no-trip day for the selected school. No absences are needed for affected students. This change stays in this demo.',
                style: RoutesCalendarStyles.muted,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                key: const ValueKey('no-trip-date'),
                onPressed: () async {
                  final selected = await _pickDate(context, date);
                  if (selected != null && mounted) {
                    setState(() => date = selected);
                  }
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${RoutesCalendarController.shortDate(date)} ${date.year}',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const ValueKey('no-trip-school'),
                initialValue: school,
                isExpanded: true,
                decoration: RoutesCalendarStyles.input('School'),
                items:
                    [
                          SchoolCalendarEvent.allSchools,
                          ...widget.controller.schools,
                        ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (value) => setState(() => school = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('no-trip-reason'),
                controller: reason,
                maxLength: 120,
                decoration: RoutesCalendarStyles.input('Reason'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reason.'
                    : null,
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const ValueKey('confirm-no-trip'),
        onPressed: confirm,
        child: const Text('Confirm no-trip day'),
      ),
    ],
  );
}

Future<void> showTripRuleDialog(
  BuildContext context,
  RoutesCalendarController c,
  TripRule rule,
) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => _TripRuleDialog(controller: c, rule: rule),
  );
  if (value == null || !context.mounted) return;
  final error = c.updateRule(rule, value);
  calendarFeedback(context, error ?? '${rule.label} updated in this demo.');
}

class _TripRuleDialog extends StatefulWidget {
  const _TripRuleDialog({required this.controller, required this.rule});
  final RoutesCalendarController controller;
  final TripRule rule;
  @override
  State<_TripRuleDialog> createState() => _TripRuleDialogState();
}

class _TripRuleDialogState extends State<_TripRuleDialog> {
  final form = GlobalKey<FormState>();
  late final value = TextEditingController(
    text: widget.controller.ruleValue(widget.rule),
  );
  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit ${widget.rule.label}'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirm a local trip-rule change. No real trips or GPS settings will be changed.',
                style: RoutesCalendarStyles.muted,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('trip-rule-value'),
                controller: value,
                keyboardType: widget.rule.isTime
                    ? TextInputType.datetime
                    : TextInputType.number,
                decoration: RoutesCalendarStyles.input(widget.rule.label)
                    .copyWith(
                      hintText: widget.rule.isTime ? 'HH:MM' : null,
                      suffixText: widget.rule.unit.isEmpty
                          ? null
                          : widget.rule.unit,
                    ),
                validator: (text) =>
                    widget.controller.validateRule(widget.rule, text ?? ''),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const ValueKey('confirm-trip-rule'),
        onPressed: () {
          if (form.currentState!.validate()) Navigator.pop(context, value.text);
        },
        child: const Text('Apply demo rule'),
      ),
    ],
  );
}
