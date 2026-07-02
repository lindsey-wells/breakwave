// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_encouragement_card.dart
// Purpose: Daily encouragement card for the BW-02 home screen.
// Notes: BW-70A tightens Home layout while preserving the daily recovery anchor.
// Notes: BW-81C rotates grounded recovery encouragement by day.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class DailyEncouragementCard extends StatelessWidget {
  const DailyEncouragementCard({super.key});

  static const DateTime _rotationStartDate = DateTime(2026, 1, 1);

  static const List<_DailyEncouragementLine> _encouragementLines =
      <_DailyEncouragementLine>[
    _DailyEncouragementLine(
      title: 'An urge is a wave, not a command.',
      body: 'You only need to stay with the next honest decision.',
    ),
    _DailyEncouragementLine(
      title: 'This moment is not your identity.',
      body: 'Pause, breathe, and choose the next right action.',
    ),
    _DailyEncouragementLine(
      title: 'You do not have to negotiate with the wave.',
      body: 'Name what is happening and move toward support.',
    ),
    _DailyEncouragementLine(
      title: 'One honest check-in can change the next hour.',
      body: 'Come back to what is true before the urge gets louder.',
    ),
    _DailyEncouragementLine(
      title: 'Recovery is built in small returns.',
      body: 'A reset today still counts as movement toward freedom.',
    ),
    _DailyEncouragementLine(
      title: 'The wave can rise without ruling you.',
      body: 'Open Rescue before pressure becomes a plan.',
    ),
    _DailyEncouragementLine(
      title: 'You are allowed to interrupt the pattern.',
      body: 'Change the room, change the rhythm, and log what you notice.',
    ),
    _DailyEncouragementLine(
      title: 'Clarity beats secrecy.',
      body: 'Bring the moment into the light with one honest entry.',
    ),
    _DailyEncouragementLine(
      title: 'The next choice matters more than the last urge.',
      body: 'Start again with a practical step you can do right now.',
    ),
    _DailyEncouragementLine(
      title: 'You can ride this out without giving in.',
      body: 'Stay present, stay honest, and let the wave pass.',
    ),
  ];

  static _DailyEncouragementLine _lineForDate(DateTime date) {
    final DateTime today = DateTime(date.year, date.month, date.day);
    final int daysSinceStart = today.difference(_rotationStartDate).inDays;
    final int index = daysSinceStart % _encouragementLines.length;

    return _encouragementLines[index];
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final _DailyEncouragementLine line = _lineForDate(DateTime.now());

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
              line.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              line.body,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyEncouragementLine {
  const _DailyEncouragementLine({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
