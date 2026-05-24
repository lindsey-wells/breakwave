// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: remember_why_card.dart
// Purpose: BW-39 remember why reminder card.
// Notes: Shows the user's saved why inside Rescue when available.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/why/custom_why_entry.dart';
import '../../../../core/why/custom_why_fullscreen_image_viewer.dart';
import '../../../../core/why/custom_why_store.dart';

class RememberWhyCard extends StatefulWidget {
  const RememberWhyCard({super.key});

  @override
  State<RememberWhyCard> createState() => _RememberWhyCardState();
}

class _RememberWhyCardState extends State<RememberWhyCard> {
  bool _loading = true;
  CustomWhyEntry _entry = CustomWhyEntry.empty;

  @override
  void initState() {
    super.initState();
    CustomWhyStore.changes.addListener(_handleChange);
    _load();
  }

  @override
  void dispose() {
    CustomWhyStore.changes.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    _load();
  }

  Future<void> _load() async {
    final CustomWhyEntry entry = await CustomWhyStore.load();
    if (!mounted) return;

    setState(() {
      _entry = entry;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_entry.hasAnyContent) {
      return const SizedBox.shrink();
    }

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
            'Remember why',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_entry.hasImage) ...<Widget>[
            const SizedBox(height: 12),
            _WhyImagePreview(
              imagePath: _entry.imagePath,
            ),
          ],
          if (_entry.hasText) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _entry.whyText,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}


class _WhyImagePreview extends StatelessWidget {
  const _WhyImagePreview({
    required this.imagePath,
  });

  final String imagePath;
  static const String _heroTag = 'custom-why-rescue-image';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Open saved why image full screen',
      child: GestureDetector(
        onTap: () => CustomWhyFullscreenImageViewer.show(
          context,
          imagePath: imagePath,
          heroTag: _heroTag,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Hero(
                tag: _heroTag,
                child: Image.file(
                  File(imagePath),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tap to enlarge',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
