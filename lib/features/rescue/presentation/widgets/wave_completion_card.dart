// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_completion_card.dart
// Purpose: Wave completion card for the BW-03 rescue flow.
// Notes: BW-10 completion callback support.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class WaveCompletionCard extends StatelessWidget {
  final Future<void> Function() onComplete;

  const WaveCompletionCard({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Wave Completion',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When the sharpest part passes, mark the win. Small interrupted waves still count.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onComplete(),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('I made it through this wave'),
            ),
          ],
        ),
      ),
    );
  }
}
