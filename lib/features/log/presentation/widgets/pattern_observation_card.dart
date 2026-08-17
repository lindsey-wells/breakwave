// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pattern_observation_card.dart
// Purpose: User-facing Learn your pattern card for the Log screen.
// Notes: BW-89A3 presents A2 observations without changing their logic.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../patterns/domain/pattern_observation.dart';

class PatternObservationCard extends StatelessWidget {
  const PatternObservationCard({
    super.key,
    required this.result,
    required this.minimumBehavioralEntries,
  });

  final PatternObservationResult result;
  final int minimumBehavioralEntries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('learn-your-pattern-card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recognize',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Learn your pattern',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (!result.hasEnoughData)
              _InsufficientPatternData(
                behavioralEntryCount: result.behavioralEntryCount,
                minimumBehavioralEntries: minimumBehavioralEntries,
              )
            else if (!result.hasObservations)
              const Text(
                'You have enough recent logs to look for repetition, but '
                'nothing is repeating strongly enough to call out yet. '
                'Keep logging what you notice.',
              )
            else ...<Widget>[
              Text(
                'Based only on what you recorded in the last '
                '${result.windowDays} days.',
              ),
              const SizedBox(height: 12),
              for (final PatternObservation observation
                  in result.observations) ...<Widget>[
                _ObservationRow(observation: observation),
                if (observation != result.observations.last)
                  const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 14),
            Text(
              'These are observations from your Log—not causes, predictions, '
              'or diagnoses.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsufficientPatternData extends StatelessWidget {
  const _InsufficientPatternData({
    required this.behavioralEntryCount,
    required this.minimumBehavioralEntries,
  });

  final int behavioralEntryCount;
  final int minimumBehavioralEntries;

  @override
  Widget build(BuildContext context) {
    final int remaining =
        minimumBehavioralEntries > behavioralEntryCount
            ? minimumBehavioralEntries - behavioralEntryCount
            : 0;
    final String noun = remaining == 1 ? 'log' : 'logs';

    return Text(
      'Keep logging what you notice. BreakWave needs $remaining more recent '
      'urge, slip, or victory $noun before it starts looking for repeating '
      'signals.',
    );
  }
}

class _ObservationRow extends StatelessWidget {
  const _ObservationRow({
    required this.observation,
  });

  final PatternObservation observation;

  IconData get _icon {
    switch (observation.kind) {
      case PatternObservationKind.recurringTrigger:
        return Icons.flag_outlined;
      case PatternObservationKind.timeWindow:
        return Icons.schedule_outlined;
      case PatternObservationKind.repeatedVictoryAction:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(_icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(observation.message),
          ),
        ],
      ),
    );
  }
}
