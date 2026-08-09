// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_recovery_model_card.dart
// Purpose: BW-HOME-01A compact recovery-model orientation for Home.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class HomeRecoveryModelCard extends StatelessWidget {
  const HomeRecoveryModelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      key: const ValueKey<String>('home-recovery-model-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.primary.withOpacity(0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Your recovery',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Recognize → Interrupt → Redirect → Reinforce',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Notice it → Break it → Choose differently → Strengthen what works',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Home helps you notice and prepare. Rescue helps you interrupt '
            'the wave and choose one next right action. Your Log helps you '
            'remember what worked and learn the pattern.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
