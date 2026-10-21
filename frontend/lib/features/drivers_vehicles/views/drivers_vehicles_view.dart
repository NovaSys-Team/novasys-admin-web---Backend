import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../controllers/drivers_vehicles_controller.dart';
import '../widgets/driver_vehicle_details.dart';
import '../widgets/drivers_vehicles_table.dart';
import '../widgets/fleet_dialogs.dart';
import '../widgets/fleet_filters.dart';
import '../widgets/fleet_styles.dart';
import '../widgets/substitute_panel.dart';

class DriversVehiclesView extends StatelessWidget {
  const DriversVehiclesView({super.key});
  static const title = 'Drivers & vehicles';
  @override
  Widget build(BuildContext context) {
    final c = context.watch<DriversVehiclesController>();
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
        ),
      ),
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (constraints.maxWidth <
                  DesignTokens.compactPageHeaderWidth) ...[
                const Text(
                  title,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(c.subtitle, style: FleetStyles.muted),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: FleetHeaderActions(inContent: true),
                ),
                const SizedBox(height: 16),
              ],
              const SubstitutePanel(),
              const SizedBox(height: 18),
              if (c.filtersVisible ||
                  c.query.isNotEmpty ||
                  c.statusFilter != null ||
                  c.complianceFilter != null)
                const FleetFilters(),
              const DriversVehiclesTable(),
              const SizedBox(height: 18),
              const DriverVehicleDetails(),
              const SizedBox(height: 16),
              const Text(
                'Expiry colours: red = expired or under 14 days (driver cannot start trips) · amber = under 45 days (reminder sent) · green = valid. Suspensions are logged with a reason.',
                style: FleetStyles.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FleetHeaderActions extends StatelessWidget {
  const FleetHeaderActions({super.key, this.inContent = false});
  final bool inContent;
  @override
  Widget build(BuildContext context) {
    if (!inContent &&
        MediaQuery.sizeOf(context).width <
            DesignTokens.compactPageHeaderWidth + 64) {
      return IconButton(
        tooltip: 'Search & filter drivers',
        onPressed: context.read<DriversVehiclesController>().toggleFilters,
        icon: const Icon(Icons.search),
      );
    }
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Search & filter drivers',
          onPressed: context.read<DriversVehiclesController>().toggleFilters,
          icon: const Icon(Icons.search),
        ),
        FilledButton.icon(
          key: const ValueKey('fleet-add-vehicle'),
          onPressed: () => showAddVehicleDialog(
            context,
            context.read<DriversVehiclesController>(),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add vehicle'),
        ),
      ],
    );
  }
}
