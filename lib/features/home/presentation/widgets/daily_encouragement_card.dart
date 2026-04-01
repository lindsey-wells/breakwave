// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_encouragement_card.dart
// Purpose: Daily encouragement card for the BW-02 home screen.
// Notes: Shell-first deterministic scaffold for BW-02.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class DailyEncouragementCard extends StatelessWidget {
  const DailyEncouragementCard({super.key});

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
              'Daily Encouragement',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'An urge is a wave, not a command.',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You do not have to win the whole week right now. '
              'You only need to stay with the next honest decision.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
