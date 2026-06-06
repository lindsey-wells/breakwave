// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: professional_help_card.dart
// Purpose: BW-62 when to seek professional help.
// Notes: Encourages extra help without shame.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/clinical/cbt_recovery_foundation.dart';

class ProfessionalHelpCard extends StatelessWidget {
  const ProfessionalHelpCard({super.key});

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
            'When to seek professional help',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'BreakWave can support recovery moments, but some situations deserve human help from a qualified professional, trusted support person, or local emergency resource.',
          ),
          const SizedBox(height: 12),
          ...CbtRecoveryFoundation.seekProfessionalHelpSignals.map(
            (String signal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(signal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you may harm yourself or someone else, seek emergency help immediately through local emergency services.',
          ),
        ],
      ),
    );
  }
}
