// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: remember_why_card.dart
// Purpose: BW-39 remember why reminder card.
// Notes: BW-71B keeps Remember Why visible in Rescue even before setup.
// Notes: BW-82A lets the user add or edit their why directly in Rescue.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/why/custom_why_entry.dart';
import '../../../../core/why/custom_why_fullscreen_image_viewer.dart';
import '../../../../core/why/custom_why_image_service.dart';
import '../../../../core/why/custom_why_store.dart';

class RememberWhyCard extends StatefulWidget {
  const RememberWhyCard({
    super.key,
    this.onOpenSupport,
  });

  final VoidCallback? onOpenSupport;

  @override
  State<RememberWhyCard> createState() => _RememberWhyCardState();
}

class _RememberWhyCardState extends State<RememberWhyCard> {
  late final TextEditingController _whyController;

  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  CustomWhyEntry _entry = CustomWhyEntry.empty;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _whyController = TextEditingController();
    CustomWhyStore.changes.addListener(_handleChange);
    _load();
  }

  @override
  void dispose() {
    CustomWhyStore.changes.removeListener(_handleChange);
    _whyController.dispose();
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
      if (!_editing) {
        _imagePath = entry.imagePath;
      }
    });
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _whyController.text = _entry.whyText;
      _imagePath = _entry.imagePath;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _whyController.text = _entry.whyText;
      _imagePath = _entry.imagePath;
    });
  }

  Future<void> _saveWhy() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    final CustomWhyEntry nextEntry = CustomWhyEntry(
      whyText: _whyController.text.trim(),
      imagePath: _imagePath,
    );

    try {
      await CustomWhyStore.save(nextEntry);

      if (!mounted) return;

      setState(() {
        _entry = nextEntry;
        _editing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your why is saved for Rescue.'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Why image saved for Rescue.'),
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
    if (_loading) {
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
      child: _editing
          ? _WhyEditor(
              whyController: _whyController,
              imagePath: _imagePath,
              saving: _saving,
              onChooseImage: _chooseImage,
              onRemoveImage: _removeImage,
              onSave: _saveWhy,
              onCancel: _cancelEditing,
            )
          : _entry.hasAnyContent
              ? _SavedWhyView(
                  entry: _entry,
                  onEdit: _startEditing,
                )
              : _EmptyWhyView(
                  onAddWhy: _startEditing,
                ),
    );
  }
}

class _EmptyWhyView extends StatelessWidget {
  const _EmptyWhyView({
    required this.onAddWhy,
  });

  final VoidCallback onAddWhy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Remember why',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your saved why will appear here during Rescue. Add one now so your reason is ready when the wave rises.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onAddWhy,
          icon: const Icon(Icons.favorite_border),
          label: const Text('Add your why here'),
        ),
      ],
    );
  }
}

class _SavedWhyView extends StatelessWidget {
  const _SavedWhyView({
    required this.entry,
    required this.onEdit,
  });

  final CustomWhyEntry entry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Remember why',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (entry.hasImage) ...<Widget>[
          const SizedBox(height: 12),
          _WhyImagePreview(
            imagePath: entry.imagePath,
          ),
        ],
        if (entry.hasText) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            entry.whyText,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit why'),
        ),
      ],
    );
  }
}

class _WhyEditor extends StatelessWidget {
  const _WhyEditor({
    required this.whyController,
    required this.imagePath,
    required this.saving,
    required this.onChooseImage,
    required this.onRemoveImage,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController whyController;
  final String imagePath;
  final bool saving;
  final VoidCallback onChooseImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasImage = imagePath.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Add your why',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Save a short reason, person, goal, or promise you want in front of you during Rescue.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: whyController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Why statement',
            hintText: 'Example: I want to be present, honest, and in control.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        if (hasImage) ...<Widget>[
          _EditableWhyImagePreview(imagePath: imagePath),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: saving ? null : onChooseImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose why image'),
            ),
            if (hasImage)
              OutlinedButton.icon(
                onPressed: saving ? null : onRemoveImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove image'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            FilledButton(
              onPressed: saving ? null : onSave,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(saving ? 'Saving...' : 'Save why for Rescue'),
              ),
            ),
            OutlinedButton(
              onPressed: saving ? null : onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditableWhyImagePreview extends StatelessWidget {
  const _EditableWhyImagePreview({
    required this.imagePath,
  });

  final String imagePath;
  static const String _heroTag = 'custom-why-rescue-edit-image';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Open selected why image full screen',
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
