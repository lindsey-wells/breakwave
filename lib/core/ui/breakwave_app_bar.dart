// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app_bar.dart
// Purpose: BW-88RC1B approved asset-based BreakWave header.
// Notes: Replaces the BW-64 painted placeholder with the real wordmark.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWaveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BreakWaveAppBar({
    super.key,
    required this.sectionTitle,
  });

  static const String _brandAssetPath =
      'assets/branding/breakwave_in_app_header.png';

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
          Semantics(
            label: 'BreakWave brand wordmark',
            image: true,
            excludeSemantics: true,
            child: SizedBox(
              width: 240,
              height: 52,
              child: Image.asset(
                _brandAssetPath,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'BreakWave',
                      style:
                          theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
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
