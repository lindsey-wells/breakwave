// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app_bar.dart
// Purpose: BW-88RC1B approved asset-based BreakWave header.
// Notes: Uses the isolated approved BreakWaveWordmark helper.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../branding/breakwave_wordmark.dart';

class BreakWaveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BreakWaveAppBar({
    super.key,
    required this.sectionTitle,
  });

  final String sectionTitle;

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 18,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BreakWaveWordmark(
            width: 240,
            height: 52,
          ),
          const SizedBox(height: 2),
          Text(
            sectionTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
