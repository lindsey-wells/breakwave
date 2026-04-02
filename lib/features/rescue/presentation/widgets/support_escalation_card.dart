// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_escalation_card.dart
// Purpose: Support and escalation card for the BW-03 rescue flow.
// Notes: Neutral rescue flow scaffold for BW-03.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class SupportEscalationCard extends StatelessWidget {
  const SupportEscalationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Support and Escalation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'If the wave keeps rising, reduce isolation and raise support. The next right move can be another person.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _SupportRow(
              icon: Icons.person_outline,
              text: 'Reach out to a trusted person.',
            ),
            const SizedBox(height: 10),
            const _SupportRow(
              icon: Icons.shield_outlined,
              text: 'Move to a safer, less private environment.',
            ),
            const SizedBox(height: 10),
            const _SupportRow(
              icon: Icons.support_agent_outlined,
              text: 'Use the Support tab when you need more help tools.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_outlined),
              label: const Text('Support tools expanding soon'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SupportRow({
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
