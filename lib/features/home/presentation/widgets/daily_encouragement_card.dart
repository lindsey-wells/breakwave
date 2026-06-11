// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_encouragement_card.dart
// Purpose: Daily encouragement card for the BW-02 home screen.
// Notes: BW-70A tightens Home layout while preserving the daily recovery anchor.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class DailyEncouragementCard extends StatelessWidget {
  const DailyEncouragementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Daily Encouragement',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'An urge is a wave, not a command.',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You only need to stay with the next honest decision.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
