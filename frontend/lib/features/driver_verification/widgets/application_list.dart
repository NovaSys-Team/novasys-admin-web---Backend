import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../models/driver_application.dart';
import 'verification_styles.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({
    super.key,
    required this.applications,
    required this.selectedId,
    required this.onSelect,
    required this.onClearFilters,
    required this.hasFilters,
  });
  final List<DriverApplication> applications;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearFilters;
  final bool hasFilters;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (hasFilters)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${applications.length} matching applications',
                style: VerificationStyles.muted,
              ),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      if (applications.isEmpty)
        const Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No applications match your search.'),
          ),
        ),
      for (var i = 0; i < applications.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        _ApplicationTile(
          application: applications[i],
          selected: applications[i].id == selectedId,
          onTap: () => onSelect(applications[i].id),
        ),
      ],
    ],
  );
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.application,
    required this.selected,
    required this.onTap,
  });
  final DriverApplication application;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: Material(
      color: selected ? Colors.white : const Color(0xFFFAFCFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? DesignTokens.primary : DesignTokens.border,
          width: selected ? 1.6 : .8,
        ),
      ),
      child: InkWell(
        key: ValueKey('application-${application.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.name,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(application.subtitle, style: VerificationStyles.muted),
                  if (constraints.maxWidth < 300) ...[
                    const SizedBox(height: 6),
                    VerificationStatusBadge(application: application),
                  ],
                ],
              );
              return Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: VerificationStyles.avatar(application.avatarIndex),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.sidebar,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: text),
                  if (constraints.maxWidth >= 300) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: VerificationStatusBadge(application: application),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
