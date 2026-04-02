// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: emergency_help_card.dart
// Purpose: Emergency help card for the BW-05 support flow.
// Notes: Neutral support scaffold for BW-05.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class EmergencyHelpCard extends StatelessWidget {
  const EmergencyHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Emergency Help',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'If you feel overwhelmed or unsafe, stop trying to manage it alone and move toward real-world support immediately.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _HelpRow(
              icon: Icons.call_outlined,
              text: 'Call emergency services if there is immediate danger.',
            ),
            const SizedBox(height: 10),
            const _HelpRow(
              icon: Icons.person_outline,
              text: 'Reach a trusted person and tell them you need support now.',
            ),
            const SizedBox(height: 10),
            const _HelpRow(
              icon: Icons.place_outlined,
              text: 'Move into a safer, more public, less isolated environment.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency and crisis contact tools can be wired in a later pass.'),
                  ),
                );
              },
              icon: const Icon(Icons.warning_amber_outlined),
              label: const Text('Emergency tools placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
