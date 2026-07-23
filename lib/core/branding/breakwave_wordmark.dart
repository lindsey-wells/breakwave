// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_wordmark.dart
// Purpose: Reusable approved BreakWave in-app wordmark.
// Notes: Keeps asset, fallback, sizing, and accessibility together.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWaveWordmark extends StatelessWidget {
  const BreakWaveWordmark({
    super.key,
    this.width = 240,
    this.height = 52,
  });

  static const String assetPath =
      'assets/branding/breakwave_in_app_header.png';

  static const String semanticLabel =
      'BreakWave brand wordmark';

  static const Key widgetKey =
      Key('breakwave_wordmark');

  static const Key semanticsKey =
      Key('breakwave_wordmark_semantics');

  static const Key imageKey =
      Key('breakwave_wordmark_image');

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      key: widgetKey,
      width: width,
      height: height,
      child: Semantics(
        key: semanticsKey,
        label: semanticLabel,
        image: true,
        container: true,
        excludeSemantics: true,
        child: Image.asset(
          assetPath,
          key: imageKey,
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
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
