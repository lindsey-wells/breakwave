// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: calm_reset_card.dart
// Purpose: Calm reset guidance card for the BW-03 rescue flow.
// Notes: Neutral rescue flow scaffold for BW-03.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class CalmResetCard extends StatelessWidget {
  const CalmResetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Calm Reset',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Reset the body first. A slower body gives you a better next decision.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _StepRow(
              icon: Icons.looks_one_outlined,
              text: 'Inhale through the nose for 4 seconds.',
            ),
            const SizedBox(height: 10),
            const _StepRow(
              icon: Icons.looks_two_outlined,
              text: 'Hold gently for 4 seconds.',
            ),
            const SizedBox(height: 10),
            const _StepRow(
              icon: Icons.looks_3_outlined,
              text: 'Exhale slowly for 6 seconds.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.self_improvement_outlined),
              label: const Text('Start reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StepRow({
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
