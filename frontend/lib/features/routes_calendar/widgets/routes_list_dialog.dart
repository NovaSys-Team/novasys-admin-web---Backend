import 'package:flutter/material.dart';

import '../controllers/routes_calendar_controller.dart';
import 'routes_calendar_styles.dart';

Future<void> showRoutesList(
  BuildContext context,
  RoutesCalendarController controller,
) => showDialog<void>(
  context: context,
  builder: (_) => _RoutesListDialog(controller: controller),
);

class _RoutesListDialog extends StatefulWidget {
  const _RoutesListDialog({required this.controller});
  final RoutesCalendarController controller;
  @override
  State<_RoutesListDialog> createState() => _RoutesListDialogState();
}

class _RoutesListDialogState extends State<_RoutesListDialog> {
  late final search = TextEditingController(text: widget.controller.routeQuery);
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      return AlertDialog(
        title: const Text('Routes'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('route-search'),
                  controller: search,
                  onChanged: c.searchRoutes,
                  decoration: RoutesCalendarStyles.input(
                    'Search routes, drivers, vehicles',
                  ).copyWith(prefixIcon: const Icon(Icons.search)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: ValueKey('route-school-${c.schoolFilter}'),
                  initialValue: c.schoolFilter,
                  isExpanded: true,
                  decoration: RoutesCalendarStyles.input('School'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All schools'),
                    ),
                    ...c.schools.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                  ],
                  onChanged: c.filterSchool,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      search.clear();
                      c.clearRouteFilters();
                    },
                    child: const Text('Clear filters'),
                  ),
                ),
                if (c.filteredRoutes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No matching routes.'),
                  ),
                ...c.filteredRoutes.map(
                  (r) => ListTile(
                    key: ValueKey('choose-route-${r.id}'),
                    contentPadding: EdgeInsets.zero,
                    selected: c.selectedRouteId == r.id,
                    leading: const Icon(Icons.alt_route),
                    title: Text('${r.id} · ${r.origin} · ${r.destinations}'),
                    subtitle: Text('${r.driver} · ${r.plate}'),
                    trailing: c.selectedRouteId == r.id
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      c.selectRoute(r.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
