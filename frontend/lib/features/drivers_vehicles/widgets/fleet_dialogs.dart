import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/drivers_vehicles_controller.dart';
import '../models/driver_vehicle.dart';
import 'fleet_styles.dart';
import 'vehicle_illustration.dart';

Future<void> showDriverStatusDialog(
  BuildContext context,
  DriversVehiclesController c,
  DriverVehicle r,
) async {
  final action = r.status == DriverStatus.suspended ? 'Reinstate' : 'Suspend';
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(
      title: '$action ${r.name}?',
      label: 'Reason',
      button: 'Confirm $action',
      description:
          '$action this driver in the local demo. A reason will be recorded.${!r.canStartTrips && action == 'Reinstate' ? '\nExpired or near-expiry documents will still prevent trips.' : ''}\nNo real driver records will be updated.',
    ),
  );
  if (reason == null || !context.mounted) return;
  final ok = c.changeStatus(r.id, r.status, reason);
  fleetFeedback(
    context,
    ok
        ? '$action simulated. Reason logged locally.'
        : 'The driver status has changed. Try again.',
  );
}

Future<void> showSubstituteDialog(
  BuildContext context,
  DriversVehiclesController c,
  SubstituteCandidate candidate,
) async {
  final eligible = candidate.eligible && c.assignedSubstitute == null;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(candidate.name),
      content: SingleChildScrollView(
        child: Text(
          '${candidate.vehicle} · ${candidate.seats} seats\n${candidate.availability}\n\n${c.assignedSubstitute != null
              ? 'A substitute has already been assigned in this demo.'
              : eligible
              ? 'Assign this substitute for Ruwan’s 14 students, AM and PM on Fri 23 Oct? This is a local simulation. No notifications will be sent.'
              : 'This candidate cannot cover both trips for all 14 students.'}',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(eligible ? 'Cancel' : 'Close'),
        ),
        if (eligible)
          FilledButton(
            key: const ValueKey('fleet-confirm-substitute'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm assignment'),
          ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  fleetFeedback(
    context,
    c.assignSubstitute(candidate)
        ? 'Substitute assigned locally. No notifications sent.'
        : 'This substitute is no longer available.',
  );
}

Future<void> showMessageDriverDialog(
  BuildContext context,
  DriversVehiclesController c,
  DriverVehicle r,
) async {
  final message = await showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(
      title: 'Message ${r.name}',
      label: 'Message',
      button: 'Record demo message',
      description: 'Write a mock message for this demo session. No real message will be sent.',
    ),
  );
  if (message == null || !context.mounted) return;
  fleetFeedback(
    context,
    c.logMessage(r.id, message)
        ? 'Mock message recorded locally. Nothing was sent.'
        : 'Unable to record this message.',
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.label,
    required this.button,
    required this.description,
  });
  final String title, label, button, description;
  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final form = GlobalKey<FormState>();
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.description),
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('fleet-action-text'),
                controller: text,
                minLines: 3,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? '${widget.label} is required.'
                    : null,
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
        key: const ValueKey('fleet-confirm-action'),
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, text.text.trim());
          }
        },
        child: Text(widget.button),
      ),
    ],
  );
}

Future<void> showVehicleDialog(
  BuildContext context,
  DriverVehicle r,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Vehicle · ${r.plate}'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VehicleIllustration(plate: r.plate),
            const SizedBox(height: 16),
            Text(
              '${r.model} · ${r.year}\nDriver: ${r.name}\nSeats: ${r.usedSeats} / ${r.seats}\nA/C: ${r.ac ? 'Yes' : 'No'} · Attendant: ${r.attendant ? 'Yes' : 'No'}\nPrice: LKR ${r.price}/km\n\nMock vehicle information. No real records are connected.',
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);
Future<void> showStudentsDialog(
  BuildContext context,
  DriverVehicle r,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Students · ${r.name}'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${r.usedSeats} students assigned · mock roster',
              style: FleetStyles.muted,
            ),
            const SizedBox(height: 12),
            if (r.usedSeats == 0) const Text('No students assigned.'),
            for (var i = 0; i < r.usedSeats; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(
                  i == 0 && r.id == 'DV-001'
                      ? 'Thisal G. · Grade 7'
                      : 'Demo student ${(i + 1).toString().padLeft(2, '0')}',
                ),
                subtitle: Text('AM and PM · ${r.schools.split(',').first}'),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);
Future<void> showDocumentsDialog(
  BuildContext context,
  DriverVehicle r,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Documents · ${r.name}'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...{
              'Licence': r.licence,
              'Insurance': r.insurance,
              'Fitness': r.fitness,
            }.entries.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  e.value.level == ComplianceLevel.blocked
                      ? Icons.error_outline
                      : e.value.level == ComplianceLevel.warning
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                  color: FleetStyles.complianceColor(e.value.level),
                ),
                title: Text(e.key),
                subtitle: Text(
                  e.value.label,
                  style: TextStyle(
                    color: FleetStyles.complianceColor(e.value.level),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              r.canStartTrips
                  ? 'Eligible to start trips in this demo.'
                  : 'Trips blocked by driver status or document compliance.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Red: expired or under 14 days. Amber: under 45 days (reminder sent). Green: valid.\n\nThese are mock document summaries; no real files are stored.',
              style: FleetStyles.muted,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);

Future<void> showAddVehicleDialog(
  BuildContext context,
  DriversVehiclesController c,
) async {
  final added = await showDialog<bool>(
    context: context,
    builder: (_) => _AddVehicleDialog(controller: c),
  );
  if (added == true && context.mounted) {
    fleetFeedback(
      context,
      'Mock vehicle added. Pending document verification.',
    );
  }
}

class _AddVehicleDialog extends StatefulWidget {
  const _AddVehicleDialog({required this.controller});
  final DriversVehiclesController controller;
  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final form = GlobalKey<FormState>();
  final fields = {
    for (final name in ['name', 'plate', 'model', 'year', 'seats', 'price'])
      name: TextEditingController(),
  };
  bool ac = true, attendant = true;
  String? error;
  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    final result = widget.controller.addVehicle(
      name: fields['name']!.text,
      plate: fields['plate']!.text,
      model: fields['model']!.text,
      year: int.parse(fields['year']!.text),
      seats: int.parse(fields['seats']!.text),
      price: int.parse(fields['price']!.text),
      ac: ac,
      attendant: attendant,
    );
    if (result != null) {
      setState(() => error = result);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add vehicle'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create a local mock driver and vehicle. New entries await document verification.',
                style: FleetStyles.muted,
              ),
              const SizedBox(height: 16),
              ...{
                'name': 'Driver name',
                'plate': 'Vehicle plate',
                'model': 'Vehicle model',
                'year': 'Year',
                'seats': 'Seats',
                'price': 'Price (LKR/km)',
              }.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    key: ValueKey('add-vehicle-${e.key}'),
                    controller: fields[e.key],
                    keyboardType: ['year', 'seats', 'price'].contains(e.key)
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: e.value,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return '${e.value} is required.';
                      if (['year', 'seats', 'price'].contains(e.key)) {
                        final number = int.tryParse(v);
                        if (number == null) return 'Enter a whole number.';
                        if (e.key == 'year' &&
                            (number < 1980 || number > 2026)) {
                          return 'Enter a year from 1980 to 2026.';
                        }
                        if (e.key == 'seats' && (number < 1 || number > 80)) {
                          return 'Enter 1 to 80 seats.';
                        }
                        if (e.key == 'price' && number < 1) {
                          return 'Enter a positive price.';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('A/C'),
                value: ac,
                onChanged: (v) => setState(() => ac = v!),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Attendant'),
                value: attendant,
                onChanged: (v) => setState(() => attendant = v!),
              ),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: DesignTokens.danger),
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
        key: const ValueKey('fleet-add-confirm'),
        onPressed: submit,
        child: const Text('Add mock vehicle'),
      ),
    ],
  );
}
