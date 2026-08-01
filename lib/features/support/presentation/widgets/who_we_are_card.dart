// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: who_we_are_card.dart
// Purpose: Founder welcome and lived-experience trust statement.
// Notes: BW-ONBOARD-01A introduces the people and purpose behind BreakWave.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class WhoWeAreCard extends StatelessWidget {
  const WhoWeAreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Who We Are',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'If we could meet you in person, we would shake your hand and congratulate you for taking this first step.',
            ),
            const SizedBox(height: 12),
            const Text(
              "Opening BreakWave is a step toward reducing pornography's hold on your life. That step may feel small, but it matters.",
            ),
            const SizedBox(height: 12),
            const Text(
              'BreakWave was created by people who understand this struggle because we have fought similar battles ourselves. We know how powerful an urge can feel, and we know the frustration of repeating a pattern you genuinely want to change.',
            ),
            const SizedBox(height: 12),
            const Text(
              'We did not build BreakWave to judge or shame you. We built it to offer practical support when the pressure is strongest: pause, open Rescue, remember why change matters, and choose the next healthier step.',
            ),
            const SizedBox(height: 12),
            const Text(
              'One difficult moment does not define your future. You are here now, and that matters.',
            ),
            const SizedBox(height: 14),
            Text(
              'BreakWave is not therapy, medical treatment, a diagnosis, a cure, or an emergency service.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to BreakWave.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Let's break the wave, one choice at a time.",
            ),
          ],
        ),
      ),
    );
  }
}
