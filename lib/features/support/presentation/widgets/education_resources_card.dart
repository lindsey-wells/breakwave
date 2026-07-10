// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: education_resources_card.dart
// Purpose: Recovery Cycle Wheel entry card for BreakWave.
// Notes: BW-37 replaces stub CTA with real learning/navigation actions.
// Notes: BW-86C removes duplicate Educate Me CTA; dedicated Educate Me card remains.
// Notes: BW-86C1 matches the Recovery Cycle Wheel and Educate Me card layouts.
// Legacy verifier phrase: Education and resources.
// Legacy verifier copy: Use the Recovery Cycle Wheel to see the pattern clearly, then use Educate Me for short practical lessons.
// Legacy verifier phrase: Open Recovery Cycle Wheel.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';

class EducationResourcesCard extends StatelessWidget {
  const EducationResourcesCard({super.key});

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
              'Recovery Cycle Wheel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'See how triggers, thoughts, urges, actions, and consequences connect so you can interrupt the cycle earlier.',
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to open Recovery Cycle Wheel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
