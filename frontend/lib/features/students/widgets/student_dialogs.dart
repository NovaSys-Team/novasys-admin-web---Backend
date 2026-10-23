import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/students_controller.dart';
import '../models/student.dart';
import 'student_styles.dart';

void studentFeedback(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

Future<void> showStudentExport(
  BuildContext context,
  StudentsController controller,
) {
  final csv = controller.exportCsv();
  final count = controller.visibleStudents.length;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Export list'),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count mock student records · current search and filters'),
              const SizedBox(height: 16),
              SelectableText(
                csv,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
        OutlinedButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: csv));
            if (context.mounted) {
              studentFeedback(
                context,
                'CSV copied · $count mock student records',
              );
            }
          },
          child: const Text('Copy CSV'),
        ),
      ],
    ),
  );
}

Future<void> showVehicleChange(BuildContext context, Student student) async {
  String? plate;
  DateTime? start;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Change vehicle'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${student.name} · ${student.plate ?? 'No vehicle'}'),
                const SizedBox(height: 16),
                const Text(
                  'Preview an exception locally. No assignment or notification will be sent.',
                  style: studentMuted,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: plate,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'New vehicle'),
                  items: [
                    for (final entry in [
                      ('WP PH–4521', 'Ruwan J.'),
                      ('WP NB–7731', 'Kumari W.'),
                      ('WP CAB–1190', 'Dilshan F.'),
                    ])
                      if (entry.$1 != student.plate)
                        DropdownMenuItem(
                          value: entry.$1,
                          child: Text(
                            '${entry.$1} · ${entry.$2}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                  ],
                  onChanged: (value) => setState(() => plate = value),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateUtils.dateOnly(DateTime.now());
                    final date = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1, now.month, now.day),
                      initialDate: start ?? now,
                    );
                    if (date != null && context.mounted) {
                      setState(() => start = date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    start == null
                        ? 'Choose start date'
                        : 'Starts ${start!.year}-${start!.month.toString().padLeft(2, '0')}-${start!.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'In production, both drivers and the parent would be notified, with the date it starts.',
                  style: studentMuted,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: plate == null || start == null
                ? null
                : () => Navigator.pop(dialogContext, true),
            child: const Text('Preview change'),
          ),
        ],
      ),
    ),
  );
  if (confirmed == true && context.mounted) {
    studentFeedback(
      context,
      'Mock preview: ${student.name} → $plate. Assignment unchanged.',
    );
  }
}

Future<void> showParentMessage(BuildContext context, Student student) async {
  final text = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Message parent'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${student.parent} · ${student.phone}'),
                const SizedBox(height: 16),
                TextField(
                  controller: text,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Text(
                  'Local demo only. No message will be sent.',
                  style: studentMuted,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: text.text.trim().isEmpty
                ? null
                : () => Navigator.pop(dialogContext, true),
            child: const Text('Preview message'),
          ),
        ],
      ),
    ),
  );
  // Dispose after the closing route has finished using the text field.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  text.dispose();
  if (confirmed == true && context.mounted) {
    studentFeedback(
      context,
      'Mock message preview completed for ${student.parent}. Nothing sent.',
    );
  }
}

Future<void> showStudentTracking(BuildContext context, Student student) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Track · ${student.name}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.route, size: 40),
              const SizedBox(height: 12),
              Text('${student.plate} · ${student.driver}'),
              const SizedBox(height: 12),
              Text('Today: ${student.today}'),
              Text('Pickup: ${student.pickup}'),
              const SizedBox(height: 12),
              const Text(
                'Mock trip snapshot · no live location feed.',
                style: studentMuted,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
