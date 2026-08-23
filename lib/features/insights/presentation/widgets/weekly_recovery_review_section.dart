import 'package:flutter/material.dart';

import '../../domain/recovery_insights_snapshot.dart';

class WeeklyRecoveryReviewSection extends StatelessWidget {
  const WeeklyRecoveryReviewSection({
    super.key,
    required this.current,
    required this.previous,
  });

  final RecoveryPeriodSummary current;
  final RecoveryPeriodSummary previous;

  String _intensity(RecoveryPeriodSummary summary) {
    if (!summary.hasEntries) return '—';
    return '${summary.averageIntensity.toStringAsFixed(1)} / 5';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '7-day recovery review',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compare two adjacent 7-day windows from what you recorded.',
          ),
          const SizedBox(height: 16),
          _WindowSummary(
            title: 'Last 7 days',
            summary: current,
            intensity: _intensity(current),
          ),
          const SizedBox(height: 14),
          _WindowSummary(
            title: 'Previous 7 days',
            summary: previous,
            intensity: _intensity(previous),
          ),
          const SizedBox(height: 14),
          const Text(
            'These are two adjacent 7-day windows. More or fewer logged '
            'moments do not by themselves mean recovery is improving or worsening.',
          ),
        ],
      ),
    );
  }
}

class _WindowSummary extends StatelessWidget {
  const _WindowSummary({
    required this.title,
    required this.summary,
    required this.intensity,
  });

  final String title;
  final RecoveryPeriodSummary summary;
  final String intensity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text('Logged moments: ${summary.total}'),
        Text('Urges: ${summary.urges}'),
        Text('Victories: ${summary.victories}'),
        Text('Slips: ${summary.slips}'),
        Text('Average recorded intensity: $intensity'),
      ],
    );
  }
}
