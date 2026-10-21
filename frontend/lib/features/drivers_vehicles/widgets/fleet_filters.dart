import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/drivers_vehicles_controller.dart';
import '../models/driver_vehicle.dart';

class FleetFilters extends StatefulWidget {
  const FleetFilters({super.key});
  @override
  State<FleetFilters> createState() => _FleetFiltersState();
}

class _FleetFiltersState extends State<FleetFilters> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<DriversVehiclesController>();
    if (search.text != c.query) {
      search.value = TextEditingValue(
        text: c.query,
        selection: TextSelection.collapsed(offset: c.query.length),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fields = [
            TextField(
              key: const ValueKey('fleet-search'),
              controller: search,
              onChanged: c.search,
              decoration: const InputDecoration(
                labelText: 'Search drivers, vehicles, plates',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            DropdownButtonFormField<DriverStatus>(
              key: ValueKey('fleet-status-${c.statusFilter}'),
              initialValue: c.statusFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All statuses'),
                ),
                ...DriverStatus.values.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                ),
              ],
              onChanged: c.filterStatus,
            ),
            DropdownButtonFormField<ComplianceLevel>(
              key: ValueKey('fleet-compliance-${c.complianceFilter}'),
              initialValue: c.complianceFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Compliance'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All compliance')),
                DropdownMenuItem(
                  value: ComplianceLevel.valid,
                  child: Text('Valid'),
                ),
                DropdownMenuItem(
                  value: ComplianceLevel.warning,
                  child: Text('Under 45 days'),
                ),
                DropdownMenuItem(
                  value: ComplianceLevel.blocked,
                  child: Text('Expired / under 14 days'),
                ),
              ],
              onChanged: c.filterCompliance,
            ),
          ];
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final field in fields) ...[
                  field,
                  const SizedBox(height: 12),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: c.clearFilters,
                    child: const Text('Clear filters'),
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: fields[0]),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: fields[1]),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: fields[2]),
              const SizedBox(width: 8),
              TextButton(
                onPressed: c.clearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          );
        },
      ),
    );
  }
}
