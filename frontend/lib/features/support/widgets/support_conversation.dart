import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/support_controller.dart';
import '../models/support_ticket.dart';
import 'support_styles.dart';

class SupportConversation extends StatefulWidget {
  const SupportConversation({super.key, required this.ticket});
  final SupportTicket ticket;
  @override
  State<SupportConversation> createState() => _SupportConversationState();
}

class _SupportConversationState extends State<SupportConversation> {
  late final TextEditingController draft;
  bool pending = false;
  @override
  void initState() {
    super.initState();
    draft = TextEditingController(
      text: context.read<SupportController>().draftFor(widget.ticket.id),
    );
  }

  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  Future<void> act(String action) async {
    final c = context.read<SupportController>();
    final t = widget.ticket;
    final body = draft.text;
    if (action == 'Reply' && body.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a reply before continuing.')),
      );
      return;
    }
    setState(() => pending = true);
    final confirmed = await confirmSupportAction(
      context,
      '$action?',
      switch (action) {
        'Reply' => 'Add this reply to #${t.id}?\n\n$body',
        'Resolve' => 'Mark #${t.id} as resolved? Replying will be disabled.',
        _ => 'Simulate ending Ruwan’s assignment for Thisal from 1 Nov and opening a request to Kumari W. (2 PM seats free)?',
      },
    );
    if (!mounted) return;
    if (confirmed) {
      final success = switch (action) {
        'Reply' => c.reply(t.id, body),
        'Resolve' => c.resolve(t.id),
        _ => c.approveReassignment(t.id),
      };
      if (success && action == 'Reply') draft.clear();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '$action simulated successfully. No messages sent.'
                  : 'This action is no longer available.',
            ),
          ),
        );
    }
    setState(() => pending = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final enabled = !pending && t.status != TicketStatus.resolved;
    return SupportCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.subject, style: supportTitle),
                    const SizedBox(height: 3),
                    Text(
                      '${t.requester} · ${t.role.toLowerCase()}${t.reassignment ? ' of Thisal' : ''}',
                      style: supportMuted,
                    ),
                  ],
                ),
                SupportBadge(t.status.label, status: t.status),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 346),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FBFA),
              border: Border.symmetric(
                horizontal: BorderSide(color: Color(0xFFF0F4F3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: t.messages
                  .map(
                    (m) => Container(
                      width: 385,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: m.author == 'Assistant (auto)'
                            ? const Color(0xFFEDF2F1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: m.author == 'Assistant (auto)'
                            ? null
                            : Border.all(color: DesignTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.author,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            m.body,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: m.author == 'Assistant (auto)'
                                  ? DesignTokens.mutedText
                                  : DesignTokens.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (t.reassignment)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.reassignmentApproved
                          ? 'Reassignment approved in this demo. A new request to Kumari W. has been recorded locally.'
                          : 'Driver change is an exception. Approving ends Ruwan’s assignment for Thisal from 1 Nov and opens a new request to Kumari W. (2 PM seats free). Both drivers and the parent are notified.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF925B00),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: enabled && !t.reassignmentApproved
                          ? () => act('Approve reassignment')
                          : null,
                      child: Text(
                        t.reassignmentApproved
                            ? 'Reassignment approved'
                            : 'Approve reassignment',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1, color: DesignTokens.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final field = TextField(
                  key: const ValueKey('support-reply'),
                  controller: draft,
                  onChanged: (text) =>
                      context.read<SupportController>().saveDraft(t.id, text),
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: t.status == TicketStatus.resolved
                        ? 'Ticket resolved'
                        : 'Write a reply...',
                  ),
                );
                final actions = Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: enabled ? () => act('Reply') : null,
                      child: const Text('Reply'),
                    ),
                    OutlinedButton(
                      onPressed: enabled ? () => act('Resolve') : null,
                      child: const Text('Resolve'),
                    ),
                  ],
                );
                if (constraints.maxWidth < 390) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [field, const SizedBox(height: 10), actions],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 10),
                    actions,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
