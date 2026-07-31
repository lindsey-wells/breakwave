// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: professional_help_card.dart
// Purpose: BW-62 when to seek professional help.
// Notes: Encourages extra help without shame.
// Notes: BW-SUPPORT-01B makes detailed guidance independently collapsible.
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
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Text(
          'When to seek professional help',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Open this when recovery feels unsafe, overwhelming, or stuck.',
          ),
        ),
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'BreakWave can support recovery moments, but some situations deserve human help from a qualified professional, trusted support person, or local emergency resource.',
            ),
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'If you feel like harming yourself or someone else, seek emergency help immediately through local emergency services.',
            ),
          ),
        ],
      ),
    );
  }
}
