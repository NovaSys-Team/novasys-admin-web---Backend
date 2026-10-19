import 'package:flutter/material.dart';

import '../models/demo_credentials.dart';

class DemoCredentialsPanel extends StatelessWidget {
  const DemoCredentialsPanel({super.key, required this.onUse});
  final VoidCallback? onUse;
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 8),
    shape: const Border(),
    collapsedShape: const Border(),
    title: const Text(
      'Demo credentials',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    subtitle: const Text(
      'Public sample account · No real credentials',
      style: TextStyle(fontSize: 12),
    ),
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: SelectableText(
          'Email: ${DemoCredentials.email}\nPassword: ${DemoCredentials.password}',
          style: TextStyle(fontSize: 13),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: onUse,
          child: const Text('Use demo credentials'),
        ),
      ),
    ],
  );
}
