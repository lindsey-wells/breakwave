// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_settings_card.dart
// Purpose: BW-39 custom why settings card.
// Notes: Lets the user save one why statement and one optional image.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/why/custom_why_entry.dart';
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
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _whyController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
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

    try {
      final String? nextPath =
          await CustomWhyImageService.pickAndPersistWhyImage();
      if (nextPath == null || !mounted) return;

      setState(() {
        _imagePath = nextPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Why image selected. Save to keep it.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to pick an image right now.'),
        ),
      );
    }
  }

  Future<void> _removeImage() async {
    if (_saving || _imagePath.trim().isEmpty) return;

    final String oldPath = _imagePath;
    setState(() {
      _imagePath = '';
    });

    try {
      await CustomWhyImageService.deleteImageIfPresent(oldPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Why image removed. Save to keep that change.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove the image right now.'),
        ),
      );
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_imagePath),
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save custom why'),
                  ),
                ),
              ],
            ),
    );
  }
}
