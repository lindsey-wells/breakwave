// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_settings_card.dart
// Purpose: BW-39 custom why settings card.
// Notes: Lets the user save one why statement and one optional image.
// Notes: BW-86B1 adds inline saved-state clarity for Custom Why.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/why/custom_why_entry.dart';
import '../../../../core/why/custom_why_fullscreen_image_viewer.dart';
import '../../../../core/why/custom_why_image_service.dart';
import '../../../../core/why/custom_why_store.dart';

class CustomWhySettingsCard extends StatefulWidget {
  const CustomWhySettingsCard({super.key});

  @override
  State<CustomWhySettingsCard> createState() => _CustomWhySettingsCardState();
}

class _CustomWhySettingsCardState extends State<CustomWhySettingsCard> {
  late final TextEditingController _whyController;

  bool _loading = true;
  bool _saving = false;
  String? _savedStatusMessage;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _whyController = TextEditingController();
    _whyController.addListener(_handleDraftChanged);
    _load();
  }

  @override
  void dispose() {
    _whyController.removeListener(_handleDraftChanged);
    _whyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final CustomWhyEntry entry = await CustomWhyStore.load();
    if (!mounted) return;

    _whyController.text = entry.whyText;
    setState(() {
      _imagePath = entry.imagePath;
      _loading = false;
    });
  }


  void _handleDraftChanged() {
    if (!mounted || _loading || _saving || _savedStatusMessage == null) return;

    setState(() {
      _savedStatusMessage = null;
    });
  }
  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await CustomWhyStore.save(
        CustomWhyEntry(
          whyText: _whyController.text.trim(),
          imagePath: _imagePath,
        ),
      );

      if (!mounted) return;
        setState(() {
          _savedStatusMessage = 'Custom why saved for Rescue.';
        });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom why saved.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your why right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _chooseImage() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final String? nextPath =
          await CustomWhyImageService.pickAndPersistWhyImage();
      if (nextPath == null || !mounted) {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
        return;
      }

      setState(() {
        _imagePath = nextPath;
      });

      await CustomWhyStore.save(
        CustomWhyEntry(
          whyText: _whyController.text.trim(),
          imagePath: nextPath,
        ),
      );

      if (!mounted) return;
        setState(() {
          _savedStatusMessage = 'Why image saved for Rescue.';
        });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Why image saved.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to pick an image right now: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _removeImage() async {
    if (_saving || _imagePath.trim().isEmpty) return;

    final String oldPath = _imagePath;
    setState(() {
      _saving = true;
      _imagePath = '';
    });

    try {
      await CustomWhyStore.save(
        CustomWhyEntry(
          whyText: _whyController.text.trim(),
          imagePath: '',
        ),
      );
      await CustomWhyImageService.deleteImageIfPresent(oldPath);
      if (!mounted) return;
        setState(() {
          _savedStatusMessage = 'Why image removed from Rescue.';
        });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Why image removed.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imagePath = oldPath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove the image right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

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
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Custom why',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Save one short reason, person, goal, or promise you want to remember when the wave starts rising.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _whyController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Why statement',
                    hintText: 'Example: I want to be present, honest, and in control.',
                  ),
                ),
                const SizedBox(height: 16),
                if (_imagePath.trim().isNotEmpty) ...<Widget>[
                  _EditableWhyImagePreview(
                    imagePath: _imagePath,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: _saving ? null : _chooseImage,
                      child: const Text('Choose why image'),
                    ),
                    if (_imagePath.trim().isNotEmpty)
                      OutlinedButton(
                        onPressed: _saving ? null : _removeImage,
                        child: const Text('Remove image'),
                      ),
                  ],
                ),
                  if (_savedStatusMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$_savedStatusMessage This will appear in Rescue when the wave rises.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _saving
                            ? 'Saving...'
                            : _savedStatusMessage == null
                                ? 'Save custom why'
                                : 'Saved custom why',
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}


class _EditableWhyImagePreview extends StatelessWidget {
  const _EditableWhyImagePreview({
    required this.imagePath,
    required this.colorScheme,
  });

  final String imagePath;
  final ColorScheme colorScheme;
  static const String _heroTag = 'custom-why-settings-image';

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
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    alignment: Alignment.center,
                    color: colorScheme.surfaceContainer,
                    child: const Text('Saved why image could not be loaded.'),
                  ),
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
