import 'package:flutter/material.dart';

import '../models/trip_incident.dart';

enum IncidentAction { acknowledge, resolve }

Future<String?> confirmIncidentAction(
  BuildContext context,
  TripIncident incident,
  IncidentAction action,
) => showDialog<String>(
  context: context,
  builder: (_) => _IncidentActionDialog(incident: incident, action: action),
);

class _IncidentActionDialog extends StatefulWidget {
  const _IncidentActionDialog({required this.incident, required this.action});
  final TripIncident incident;
  final IncidentAction action;
  @override
  State<_IncidentActionDialog> createState() => _IncidentActionDialogState();
}

class _IncidentActionDialogState extends State<_IncidentActionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _note = TextEditingController(
    text: widget.incident.suggestedResolution,
  );
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolving = widget.action == IncidentAction.resolve;
    return AlertDialog(
      title: Text(resolving ? 'Resolve incident?' : 'Acknowledge incident?'),
      scrollable: true,
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.incident.id,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                resolving
                    ? 'Simulate resolution of this incident. This does not confirm real student locations or change any real trip.'
                    : 'Record the demo acknowledgement, standby plan and parent-update entries. This does not place a call, dispatch a van or send notifications.',
              ),
              if (resolving) ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('resolution-note'),
                  controller: _note,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Resolution note (demo)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Add a resolution note.'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('confirm-incident-action'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context)
                  .pop(resolving ? _note.text : 'acknowledged');
            }
          },
          child: Text(resolving ? 'Resolve (demo)' : 'Acknowledge (demo)'),
        ),
      ],
    );
  }
}
