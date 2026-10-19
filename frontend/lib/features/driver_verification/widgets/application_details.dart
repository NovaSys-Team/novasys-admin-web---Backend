import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/driver_application.dart';
import 'document_preview_dialog.dart';
import 'verification_document_card.dart';
import 'verification_styles.dart';

class ApplicationDetails extends StatefulWidget {
  const ApplicationDetails({
    super.key,
    required this.application,
    required this.actionError,
    required this.onNoteChanged,
    required this.onDecision,
  });
  final DriverApplication application;
  final String? actionError;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<VerificationDecision> onDecision;
  @override
  State<ApplicationDetails> createState() => _ApplicationDetailsState();
}

class _ApplicationDetailsState extends State<ApplicationDetails> {
  late final _note = TextEditingController(text: widget.application.note);
  @override
  void didUpdateWidget(covariant ApplicationDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_note.text != widget.application.note) {
      _note.text = widget.application.note;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: VerificationStyles.panelShape,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final identity = Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: VerificationStyles.avatar(app.avatarIndex),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        app.initials,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.sidebar,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${app.phone} · NIC ${app.nic}',
                            style: VerificationStyles.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      identity,
                      const SizedBox(height: 12),
                      VerificationStatusBadge(application: app, detail: true),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: 12),
                    VerificationStatusBadge(application: app, detail: true),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600
                    ? 3
                    : constraints.maxWidth >= 400
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: width,
                      child: _MetadataCard(
                        label: 'Vehicle',
                        value: app.vehicle,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _MetadataCard(
                        label: 'Service area',
                        value: app.serviceArea,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _MetadataCard(
                        label: 'Applied',
                        value: app.applied,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Documents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 650
                    ? 3
                    : constraints.maxWidth >= 420
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final document in app.documents)
                      SizedBox(
                        width: width,
                        child: VerificationDocumentCard(
                          document: document,
                          onOpen: () =>
                              showDocumentPreview(context, app, document),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Note to driver (shown if rejected or re-upload requested)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('driver-note'),
              controller: _note,
              readOnly: app.isFinal,
              minLines: 2,
              maxLines: 5,
              onChanged: widget.onNoteChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14),
                hintText: 'Add a clear reason for the driver',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: DesignTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: DesignTokens.border,
                    width: .8,
                  ),
                ),
              ),
            ),
            if (widget.actionError != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  widget.actionError!,
                  style: const TextStyle(
                    color: VerificationStyles.danger,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    key: const ValueKey('reject-driver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VerificationStyles.danger,
                      minimumSize: const Size(0, 48),
                      visualDensity: VisualDensity.standard,
                      side: const BorderSide(color: Color(0xFFFFBEC1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: app.isFinal
                        ? null
                        : () => widget.onDecision(VerificationDecision.reject),
                    child: const Text('Reject'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('request-reupload'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.text,
                      minimumSize: const Size(0, 48),
                      visualDensity: VisualDensity.standard,
                      side: const BorderSide(color: DesignTokens.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        app.isFinal ||
                            app.status == ApplicationStatus.reuploadRequested
                        ? null
                        : () => widget.onDecision(
                            VerificationDecision.requestReupload,
                          ),
                    child: const Text('Request re-upload'),
                  ),
                  FilledButton(
                    key: const ValueKey('approve-driver'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      visualDensity: VisualDensity.standard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: app.canApprove
                        ? () => widget.onDecision(VerificationDecision.approve)
                        : null,
                    child: const Text('Approve driver'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                app.isFinal
                    ? 'Demo decision saved locally. No real account or audit log was changed.'
                    : app.canApprove
                    ? 'Demo only: approval changes local state, not real driver accounts or audit logs.'
                    : 'Approve is disabled until every required document passes.',
                style: VerificationStyles.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 74),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: DesignTokens.background,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 1.2,
            color: DesignTokens.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
