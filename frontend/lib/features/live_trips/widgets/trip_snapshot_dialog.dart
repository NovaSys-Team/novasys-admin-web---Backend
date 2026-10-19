import 'package:flutter/material.dart';

import '../models/live_trip.dart';

Future<void> showTripSnapshot(
  BuildContext context,
  LiveTrip trip,
  String status,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(trip.driver),
    scrollable: true,
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mock trip snapshot',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            '${trip.vehicle}\n${trip.route.replaceAll(' → ', ' to ')}\nOn board: ${trip.onboard} / ${trip.capacity}\nGPS snapshot: ${trip.gpsLabel}\nETA school: ${trip.eta}\nStatus: $status',
          ),
          const SizedBox(height: 16),
          const Text(
            'No live GPS connection, driver contact or real trip changes are made.',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    ],
  ),
);
