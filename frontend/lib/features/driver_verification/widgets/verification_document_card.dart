import 'package:flutter/material.dart';

import '../models/driver_application.dart';
import 'verification_styles.dart';

class VerificationDocumentCard extends StatelessWidget {
  const VerificationDocumentCard({
    super.key,
    required this.document,
    required this.onOpen,
  });
  final DriverDocument document;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: VerificationStyles.documentBorder(document.status),
        width: .8,
      ),
    ),
    child: InkWell(
      key: ValueKey('document-${document.id}'),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 96,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            color: const Color(0xFFEEF2F1),
            child: Text(
              document.scanLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5E6F6D),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (document.status != DocumentStatus.expiring)
                      Icon(
                        document.status == DocumentStatus.valid
                            ? Icons.check
                            : Icons.close,
                        size: 14,
                        color: VerificationStyles.documentColor(
                          document.status,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        document.statusText,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: VerificationStyles.documentColor(
                            document.status,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
