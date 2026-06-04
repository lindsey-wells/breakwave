// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_hero_card.dart
// Purpose: BW-60B Home action card polish.
// Notes: Keeps Home action copy clean, finished, and launch-ready.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.onOpenRescue,
    required this.onOpenLog,
  });

  final VoidCallback onOpenRescue;
  final VoidCallback onOpenLog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Use the next right step.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'When an urge hits, open Rescue. When something happens, log it fast. Keep the next move simple.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onOpenRescue,
                icon: const Icon(Icons.waves_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Open Rescue'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLog,
                icon: const Icon(Icons.edit_note_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Quick Log'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
