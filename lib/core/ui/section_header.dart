// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: section_header.dart
// Purpose: BW-40 reusable section header.
// Notes: Helps reduce visual density by grouping screen content.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
