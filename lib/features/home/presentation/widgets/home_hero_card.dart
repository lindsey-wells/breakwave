// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_hero_card.dart
// Purpose: Hero section for the BW-02 BreakWave home screen.
// Notes: Shell-first deterministic scaffold for BW-02.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class HomeHeroCard extends StatelessWidget {
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenLog;

  const HomeHeroCard({
    super.key,
    required this.onOpenRescue,
    required this.onOpenLog,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ride the urge. Regain control.',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'BreakWave is being shaped into a calm, practical recovery tool. '
              'When an urge hits, go straight to Rescue. When something happens, log it fast.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: onOpenRescue,
                  icon: const Icon(Icons.waves),
                  label: const Text('Open Rescue'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenLog,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Quick Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
