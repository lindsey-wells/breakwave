// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: education_resources_card.dart
// Purpose: Education resources card for BreakWave.
// Notes: BW-37 replaces stub CTA with real learning/navigation actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';
import '../../../learn/presentation/educate_me_screen.dart';

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
            'Education and resources',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Use short practical learning to understand the pattern earlier and respond faster when the wave starts rising.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EducateMeScreen(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Open Educate Me'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
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
        ],
      ),
    );
  }
}
