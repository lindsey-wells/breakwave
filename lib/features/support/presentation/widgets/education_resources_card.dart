// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: education_resources_card.dart
// Purpose: Education and resources card for the BW-05 support flow.
// Notes: Neutral support scaffold for BW-05.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class EducationResourcesCard extends StatelessWidget {
  const EducationResourcesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Education and Resources',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This area will later help users understand patterns, triggers, and recovery strategies with practical language.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _ResourceRow(
              icon: Icons.waves_outlined,
              text: 'Future urge-surfing guidance and recovery education.',
            ),
            const SizedBox(height: 10),
            const _ResourceRow(
              icon: Icons.psychology_outlined,
              text: 'Future pattern education about stress, boredom, and habit loops.',
            ),
            const SizedBox(height: 10),
            const _ResourceRow(
              icon: Icons.school_outlined,
              text: 'Future premium learning modules and deeper explainers.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Resource library placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ResourceRow({
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
