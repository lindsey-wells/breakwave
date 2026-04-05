// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_preview_card.dart
// Purpose: BW-27 recovery cycle wheel entry card.
// Notes: Opens the teachable recovery cycle wheel screen.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';

class RecoveryCyclePreviewCard extends StatelessWidget {
  const RecoveryCyclePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecoveryCycleWheelScreen(),
          ),
        );
      },
      child: Ink(
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
              'Recovery cycle wheel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Trigger → Urge → Escalation → Action → Regret / Recovery',
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to learn where the wave usually grows and where you can interrupt it earlier.',
            ),
          ],
        ),
      ),
    );
  }
}
