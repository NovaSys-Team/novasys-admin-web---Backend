import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/page_container.dart';
import '../../../core/theme/design_tokens.dart';
import '../controllers/driver_verification_controller.dart';
import '../models/driver_application.dart';
import '../widgets/application_details.dart';
import '../widgets/application_list.dart';
import '../widgets/verification_confirmation_dialog.dart';

class DriverVerificationView extends StatelessWidget {
  const DriverVerificationView({super.key});
  static const title = 'Driver verification';
  static const subtitle =
      'Check identity, licence and vehicle before a driver can take students.';
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DriverVerificationController>();
    final selected = controller.selected;
    final list = ApplicationList(
      applications: controller.filteredApplications,
      selectedId: selected?.id,
      onSelect: controller.selectApplication,
      onClearFilters: controller.clearFilters,
      hasFilters: controller.hasFilters,
    );
    final details = selected == null
        ? const Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Select an application to review its documents.'),
            ),
          )
        : ApplicationDetails(
            application: selected,
            actionError: controller.actionError,
            onNoteChanged: (note) => controller.updateNote(selected.id, note),
            onDecision: (decision) =>
                _decide(context, controller, selected, decision),
          );
    return Semantics(
      label: title,
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeader =
                constraints.maxWidth < DesignTokens.compactPageHeaderWidth;
            final heading = <Widget>[
              if (compactHeader) ...[
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text(
                  subtitle,
                  style: TextStyle(color: DesignTokens.mutedText),
                ),
                const SizedBox(height: 20),
              ],
            ];
            if (constraints.maxWidth < 1000) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...heading,
                  list,
                  const SizedBox(height: 16),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 362, child: list),
                const SizedBox(width: 16),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    DriverVerificationController controller,
    DriverApplication application,
    VerificationDecision decision,
  ) async {
    if (!controller.validateDecision(application.id, decision)) return;
    final confirmed = await confirmVerificationDecision(
      context,
      application,
      decision,
    );
    if (!confirmed || !context.mounted) return;
    if (controller.decide(application.id, decision)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${application.name} ${decision.pastTense} (demo only).',
          ),
        ),
      );
    }
  }
}
