import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/driver_verification_controller.dart';
import '../models/driver_application.dart';

class VerificationFiltersButton extends StatelessWidget {
  const VerificationFiltersButton({super.key});
  @override
  Widget build(BuildContext context) {
    final active = context.select<DriverVerificationController, bool>(
      (controller) => controller.hasFilters,
    );
    return IconButton(
      tooltip: 'Search and filter applications',
      icon: Icon(active ? Icons.filter_alt : Icons.search),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _FiltersDialog(
          controller: context.read<DriverVerificationController>(),
        ),
      ),
    );
  }
}

class _FiltersDialog extends StatefulWidget {
  const _FiltersDialog({required this.controller});
  final DriverVerificationController controller;
  @override
  State<_FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<_FiltersDialog> {
  late final _query = TextEditingController(text: widget.controller.query);
  late ApplicationFilter _filter = widget.controller.filter;
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Search and filter applications'),
    scrollable: true,
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('application-search'),
            controller: _query,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search applications',
              hintText: 'Name, NIC, vehicle or service area',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => _apply(),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<ApplicationFilter>(
            initialValue: _filter,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Verification status'),
            items: [
              for (final filter in ApplicationFilter.values)
                DropdownMenuItem(value: filter, child: Text(filter.label)),
            ],
            onChanged: (value) =>
                setState(() => _filter = value ?? ApplicationFilter.all),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          widget.controller.clearFilters();
          Navigator.of(context).pop();
        },
        child: const Text('Clear filters'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _apply, child: const Text('Apply filters')),
    ],
  );
  void _apply() {
    widget.controller.setFilters(query: _query.text, filter: _filter);
    Navigator.of(context).pop();
  }
}
