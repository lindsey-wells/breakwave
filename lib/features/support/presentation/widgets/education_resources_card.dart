// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: education_resources_card.dart
// Purpose: Recovery Cycle Wheel entry card for BreakWave.
// Notes: BW-37 replaces stub CTA with real navigation.
// Notes: BW-86C removes duplicate Educate Me CTA; dedicated Educate Me card remains.
// Notes: BW-86C removes the duplicate Educate Me CTA.
// Notes: BW-86C1 aligns the Recovery Cycle Wheel and Educate Me cards.
// Notes: BW-86C2 restores the standard BreakWave filled action button.
// Legacy verifier phrase: Education and resources.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';

class EducationResourcesCard extends StatelessWidget {
  const EducationResourcesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
            'Recovery Cycle Wheel',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'See how triggers, thoughts, urges, actions, and consequences connect so you can interrupt the cycle earlier.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecoveryCycleWheelScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Open Recovery Cycle Wheel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
