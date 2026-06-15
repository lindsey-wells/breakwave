// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_completion_card.dart
// Purpose: Wave completion card for the BW-03 rescue flow.
// Notes: BW-71A adds honest Rescue outcomes for victory, still-strong urges, and slips.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class WaveCompletionCard extends StatelessWidget {
  final Future<void> Function() onComplete;
  final Future<void> Function()? onStillStrong;
  final Future<void> Function()? onSlipped;

  const WaveCompletionCard({
    super.key,
    required this.onComplete,
    this.onStillStrong,
    this.onSlipped,
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
              'When the sharpest part passes, mark the truth. Wins, still-strong urges, and slips can all become useful recovery data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onComplete(),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('I made it through this wave'),
            ),
            if (onStillStrong != null) ...<Widget>[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => onStillStrong!(),
                icon: const Icon(Icons.waves_outlined),
                label: const Text('Still strong'),
              ),
            ],
            if (onSlipped != null) ...<Widget>[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => onSlipped!(),
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('I slipped'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
