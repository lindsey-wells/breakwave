import 'package:flutter/material.dart';

import '../../core/recovery/recovery_mode.dart';
import '../../core/recovery/recovery_mode_store.dart';

class RecoveryModeScreen extends StatefulWidget {
  const RecoveryModeScreen({
    super.key,
    this.initialMode,
    required this.onSaved,
  });

  final RecoveryMode? initialMode;
  final ValueChanged<RecoveryMode> onSaved;

  @override
  State<RecoveryModeScreen> createState() => _RecoveryModeScreenState();
}

class _RecoveryModeScreenState extends State<RecoveryModeScreen> {
  RecoveryMode? _selectedMode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  Future<void> _handleContinue() async {
    final selectedMode = _selectedMode;
    if (selectedMode == null || _saving) return;

    setState(() {
      _saving = true;
    });

    await RecoveryModeStore.saveMode(selectedMode);

    if (!mounted) return;

    widget.onSaved(selectedMode);

    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your recovery mode'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text(
              'Choose how BreakWave should speak to you when the wave rises.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This sets the tone for rescue, learning, and reflection. Pick the path that fits how you want support to show up in hard moments.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _ModeCard(
              mode: RecoveryMode.secular,
              isSelected: _selectedMode == RecoveryMode.secular,
              onTap: () {
                setState(() {
                  _selectedMode = RecoveryMode.secular;
                });
              },
            ),
            const SizedBox(height: 16),
            _ModeCard(
              mode: RecoveryMode.christian,
              isSelected: _selectedMode == RecoveryMode.christian,
              onTap: () {
                setState(() {
                  _selectedMode = RecoveryMode.christian;
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                'Christian mode is intentionally Christian. It should sound like grace, truth, prayer, and Scripture — not generic wellness language with a Bible verse attached.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (_selectedMode == null || _saving) ? null : _handleContinue,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_saving ? 'Saving...' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final RecoveryMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    final iconColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                      color: colorScheme.primary.withOpacity(0.18),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: iconColor,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mode.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
