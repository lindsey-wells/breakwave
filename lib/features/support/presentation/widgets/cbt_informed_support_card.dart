// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: cbt_informed_support_card.dart
// Purpose: BW-62 CBT-informed support explanation.
// Notes: Explains BreakWave's behavior-change model without claiming therapy.
// Notes: BW-86C clarifies CBT as cognitive behavioral tools, not CBD or therapy.
// Notes: BW-SUPPORT-01B progressively discloses the detailed explanation.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/clinical/cbt_recovery_foundation.dart';

class CbtInformedSupportCard extends StatelessWidget {
  const CbtInformedSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Text(
          'Cognitive behavioral tools',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Notice the pattern, then choose a better next step. This is not therapy or medical treatment.',
          ),
        ),
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'CBT means cognitive behavioral tools. In BreakWave, that means noticing triggers, thoughts, urges, actions, and consequences so you can choose a better next step.',
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'It is not CBD, medication, therapy, a diagnosis, or medical treatment.',
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(CbtRecoveryFoundation.safeDescription),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              CbtRecoveryFoundation.coreLoop,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(CbtRecoveryFoundation.replacementHabitWarning),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Important safety note',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(CbtRecoveryFoundation.notTherapyDisclaimer),
          ),
        ],
      ),
    );
  }
}
