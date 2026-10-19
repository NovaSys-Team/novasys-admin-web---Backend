import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/design_tokens.dart';
import '../controllers/live_trips_controller.dart';
import '../models/live_trip.dart';
import 'live_trips_styles.dart';

class LiveTripSummary extends StatelessWidget {
  const LiveTripSummary({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveTripsController>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final condition in TripCondition.values)
          if (condition != TripCondition.completed ||
              controller.count(condition) > 0)
            FilterChip(
              key: ValueKey('summary-${condition.name}'),
              selected: controller.filter.name == condition.name,
              showCheckmark: false,
              backgroundColor: condition == TripCondition.sos
                  ? const Color(0xFFFDECEC)
                  : Colors.white,
              side: BorderSide(
                color: condition == TripCondition.sos
                    ? const Color(0xFFFFBEC1)
                    : DesignTokens.border,
                width: .8,
              ),
              shape: const StadiumBorder(),
              avatar: Icon(
                condition == TripCondition.gpsStale
                    ? Icons.radio_button_unchecked
                    : condition == TripCondition.sos
                    ? Icons.square
                    : Icons.circle,
                size: condition == TripCondition.sos ? 14 : 10,
                color: LiveTripsStyles.tripColor(condition),
              ),
              label: Text(
                '${TripFilter.values.firstWhere((filter) => filter.name == condition.name).label} ${controller.count(condition)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: condition == TripCondition.sos
                      ? DesignTokens.danger
                      : DesignTokens.text,
                ),
              ),
              onSelected: (_) => controller.setFilter(
                controller.filter.name == condition.name
                    ? TripFilter.all
                    : TripFilter.values.firstWhere(
                        (filter) => filter.name == condition.name,
                      ),
              ),
            ),
      ],
    );
  }
}

class LiveTripsHeaderActions extends StatelessWidget {
  const LiveTripsHeaderActions({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth =
        screenWidth -
        (screenWidth >= DesignTokens.sidebarBreakpoint
            ? DesignTokens.sidebarWidth
            : 0) -
        2 * DesignTokens.shellPadding;
    if (contentWidth >= 900) return const LiveTripSummary();
    return IconButton(
      tooltip: 'Trip status filters',
      icon: const Icon(Icons.tune),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LiveTripsController>(),
          child: AlertDialog(
            title: const Text('Trip status filters'),
            scrollable: true,
            content: const SizedBox(width: 420, child: LiveTripSummary()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
