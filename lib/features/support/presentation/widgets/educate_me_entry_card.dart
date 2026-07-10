// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: educate_me_entry_card.dart
// Purpose: BW-28 Educate Me entry card.
// Notes: Support-screen entry point into the learning surface.
// Notes: BW-86C makes this the single Educate Me entry point on Support.
// Notes: BW-86C2 uses the standard BreakWave filled action button.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../learn/presentation/educate_me_screen.dart';

class EducateMeEntryCard extends StatelessWidget {
  const EducateMeEntryCard({super.key});

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
            'Educate Me',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Short practical lessons to help you understand the wave sooner, interrupt it earlier, and practice a cleaner next step.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
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
          ),
        ],
      ),
    );
  }
}
