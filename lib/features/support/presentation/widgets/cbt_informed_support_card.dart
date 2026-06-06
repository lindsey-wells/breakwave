// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: cbt_informed_support_card.dart
// Purpose: BW-62 CBT-informed support explanation.
// Notes: Explains BreakWave's behavior-change model without claiming therapy.
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
            'CBT-informed recovery',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
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
            'Important',
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
