import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/support_controller.dart';
import '../models/support_ticket.dart';
import 'support_styles.dart';

class SupportTicketList extends StatefulWidget {
  const SupportTicketList({super.key});
  @override
  State<SupportTicketList> createState() => _SupportTicketListState();
}

class _SupportTicketListState extends State<SupportTicketList> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SupportController>();
    if (search.text != c.query) {
      search.value = TextEditingValue(
        text: c.query,
        selection: TextSelection.collapsed(offset: c.query.length),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.filtersVisible) ...[
          TextFormField(
            key: const ValueKey('support-search'),
            controller: search,
            onChanged: c.search,
            decoration: const InputDecoration(
              labelText: 'Search tickets',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TicketStatus>(
            key: ValueKey('status-${c.statusFilter}'),
            initialValue: c.statusFilter,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All statuses')),
              ...TicketStatus.values.map(
                (s) => DropdownMenuItem(value: s, child: Text(s.label)),
              ),
            ],
            onChanged: c.filterStatus,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('category-${c.categoryFilter}'),
            initialValue: c.categoryFilter,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All categories'),
              ),
              ...c.tickets
                  .map((t) => t.category)
                  .toSet()
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))),
            ],
            onChanged: c.filterCategory,
          ),
          TextButton(
            onPressed: c.clearFilters,
            child: const Text('Clear filters'),
          ),
          const SizedBox(height: 8),
        ],
        if (c.filteredTickets.isEmpty)
          const SupportCard(
            child: Text('No matching tickets. Try clearing filters.'),
          ),
        ...c.filteredTickets.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              selected: c.selected?.id == t.id,
              child: Material(
                color: c.selected?.id == t.id
                    ? Colors.white
                    : const Color(0xFFF9FBFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: c.selected?.id == t.id
                        ? DesignTokens.primary
                        : DesignTokens.border,
                    width: c.selected?.id == t.id ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  key: ValueKey('ticket-${t.id}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => c.select(t.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${t.id} · ${t.category}',
                                style: supportMuted.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(t.age, style: supportMuted),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.subject,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            SupportBadge(t.status.label, status: t.status),
                            SupportBadge(t.role),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
