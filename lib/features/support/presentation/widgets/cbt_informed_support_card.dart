// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: cbt_informed_support_card.dart
// Purpose: BW-62 CBT-informed support explanation.
// Notes: Explains BreakWave's behavior-change model without claiming therapy.
// Notes: BW-86C clarifies CBT as cognitive behavioral tools, not CBD or therapy.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/clinical/cbt_recovery_foundation.dart';

class CbtInformedSupportCard extends StatelessWidget {
  const CbtInformedSupportCard({super.key});

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
            'Cognitive behavioral tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'CBT means cognitive behavioral tools. In BreakWave, that means noticing triggers, thoughts, urges, actions, and consequences so you can choose a better next step.',
          ),
          const SizedBox(height: 10),
          const Text(
            'It is not CBD, medication, therapy, a diagnosis, or medical treatment.',
          ),
          const SizedBox(height: 14),
          const Text(CbtRecoveryFoundation.safeDescription),
          const SizedBox(height: 14),
          Text(
            CbtRecoveryFoundation.coreLoop,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(CbtRecoveryFoundation.replacementHabitWarning),
          const SizedBox(height: 14),
          Text(
            'Important safety note',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(CbtRecoveryFoundation.notTherapyDisclaimer),
        ],
      ),
    );
  }
}
