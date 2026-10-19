import 'package:flutter/material.dart';

import '../models/driver_application.dart';
import 'verification_styles.dart';

Future<void> showDocumentPreview(
  BuildContext context,
  DriverApplication application,
  DriverDocument document,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('${document.name} · ${application.name}'),
    scrollable: true,
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFEEF2F1),
            child: Text(document.scanLabel, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          Text(
            document.statusText,
            style: TextStyle(
              color: VerificationStyles.documentColor(document.status),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mock document preview only. No real scan is loaded and no identity or document checks are performed.',
          ),
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
