import 'package:flutter/material.dart';

/// All dashboard drill-downs explicitly identify their local demo data.
Future<void> showDashboardDetails(
  BuildContext context, {
  required String title,
  required String description,
  Widget? content,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    scrollable: true,
    content: SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Mock data preview',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(description.replaceAll(' → ', ' to ')),
          if (content != null) ...[const SizedBox(height: 16), content],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    ],
  ),
);
