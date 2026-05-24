// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_fullscreen_image_viewer.dart
// Purpose: BW-46 fullscreen custom why image viewer.
// Notes: Lets users enlarge their saved why image from Rescue and Support.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

class CustomWhyFullscreenImageViewer {
  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    required String heroTag,
  }) {
    final String safePath = imagePath.trim();
    if (safePath.isEmpty) return Future<void>.value();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _CustomWhyFullscreenImageScreen(
          imagePath: safePath,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _CustomWhyFullscreenImageScreen extends StatelessWidget {
  const _CustomWhyFullscreenImageScreen({
    required this.imagePath,
    required this.heroTag,
  });

  final String imagePath;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Saved why image could not be loaded.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                tooltip: 'Close image',
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Text(
                'Pinch to zoom. Drag to move.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
