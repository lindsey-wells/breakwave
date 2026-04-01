// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_preview_card.dart
// Purpose: Recovery cycle preview card for the BW-02 home screen.
// Notes: Shell-first deterministic scaffold for BW-02.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class RecoveryCyclePreviewCard extends StatelessWidget {
  const RecoveryCyclePreviewCard({super.key});

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
              'Recovery Cycle Preview',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The full recovery cycle wheel will come in a later pass. '
              'For now, this card anchors the pattern BreakWave will help users interrupt.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            const _CycleStepRow(
              icon: Icons.flash_on_outlined,
              title: 'Trigger',
              body: 'Stress, boredom, loneliness, habit, or environment.',
            ),
            const SizedBox(height: 12),
            const _CycleStepRow(
              icon: Icons.waves_outlined,
              title: 'Urge',
              body: 'The wave rises and asks for an immediate response.',
            ),
            const SizedBox(height: 12),
            const _CycleStepRow(
              icon: Icons.shield_outlined,
              title: 'Response',
              body: 'Pause, redirect, rescue, and log what happened.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleStepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _CycleStepRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(body),
            ],
          ),
        ),
      ],
    );
  }
}
