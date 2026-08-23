// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pattern_prepare_card.dart
// Purpose: Explicit user-controlled handoff from Recognize to Prepare.
// Notes: BW-89A10B opens the existing Personal Recovery Plan without
// importing, inferring, or saving Pattern Picture observations.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class PatternPrepareCard extends StatelessWidget {
  const PatternPrepareCard({
    super.key,
    required this.onPrepare,
  });

  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey<String>('pattern-prepare-card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prepare intentionally',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you notice a pattern, choose what you want ready '
              'before the next wave. BreakWave will not choose for you.',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onPrepare,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Prepare for the next wave'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
