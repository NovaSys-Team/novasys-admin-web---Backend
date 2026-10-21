import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../controllers/support_controller.dart';
import '../widgets/support_conversation.dart';
import '../widgets/support_details.dart';
import '../widgets/support_ticket_list.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});
  static const title = 'Support desk';
  static const subtitle =
      'Chats waiting for an admin, complaints and service requests';
  @override
  Widget build(BuildContext context) {
    final c = context.watch<SupportController>();
    final t = c.selected;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8A9F9C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'NovaSysSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            foregroundColor: DesignTokens.text,
            side: const BorderSide(color: DesignTokens.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final list = const SupportTicketList();
            final conversation = t == null
                ? const SizedBox.shrink()
                : SupportConversation(key: ValueKey(t.id), ticket: t);
            final details = t == null
                ? const SizedBox.shrink()
                : SupportDetails(ticket: t);
            final wide = constraints.maxWidth >= 1050;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (constraints.maxWidth <
                    DesignTokens.compactPageHeaderWidth) ...[
                  const Text(
                    title,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(subtitle),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SupportHeaderActions(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 298, child: list),
                      const SizedBox(width: 16),
                      Expanded(child: conversation),
                      const SizedBox(width: 16),
                      SizedBox(width: 315, child: details),
                    ],
                  )
                else if (constraints.maxWidth >= 700)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 270, child: list),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            conversation,
                            const SizedBox(height: 16),
                            details,
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  list,
                  const SizedBox(height: 16),
                  conversation,
                  const SizedBox(height: 16),
                  details,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class SupportHeaderActions extends StatelessWidget {
  const SupportHeaderActions({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Search & filter tickets',
    onPressed: context.read<SupportController>().toggleFilters,
    icon: const Icon(Icons.search),
  );
}
