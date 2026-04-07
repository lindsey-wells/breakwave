// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_mode_settings_card.dart
// Purpose: BW-38 recovery mode settings card.
// Notes: Lets the user reopen and change Christian/Secular mode anytime.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/recovery/recovery_mode.dart';
import '../../../../core/recovery/recovery_mode_store.dart';
import '../../../recovery_mode/recovery_mode_screen.dart';

class RecoveryModeSettingsCard extends StatefulWidget {
  const RecoveryModeSettingsCard({super.key});

  @override
  State<RecoveryModeSettingsCard> createState() => _RecoveryModeSettingsCardState();
}

class _RecoveryModeSettingsCardState extends State<RecoveryModeSettingsCard> {
  bool _loading = true;
  RecoveryMode? _mode;

  @override
  void initState() {
    super.initState();
    RecoveryModeStore.changes.addListener(_handleModeStoreChange);
    _load();
  }

  @override
  void dispose() {
    RecoveryModeStore.changes.removeListener(_handleModeStoreChange);
    super.dispose();
  }

  void _handleModeStoreChange() {
    _load();
  }

  Future<void> _load() async {
    final RecoveryMode? mode = await RecoveryModeStore.loadMode();
    if (!mounted) return;

    setState(() {
      _mode = mode;
      _loading = false;
    });
  }

  Future<void> _openModeChooser() async {
    final RecoveryMode? currentMode = _mode;

    final RecoveryMode? nextMode = await Navigator.of(context).push<RecoveryMode>(
      MaterialPageRoute(
        builder: (_) => RecoveryModeScreen(
          initialMode: currentMode,
          onSaved: (RecoveryMode savedMode) {
            Navigator.of(context).pop(savedMode);
          },
        ),
      ),
    );

    if (nextMode == null || !mounted) return;

    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recovery mode updated to ${nextMode.label}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final RecoveryMode? mode = _mode;
    final String modeLabel = mode?.label ?? 'Not selected yet';
    final String modeDescription = mode?.description ??
        'Choose how BreakWave should speak to you when the wave rises.';

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
                  'Recovery mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current mode: $modeLabel',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  modeDescription,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _openModeChooser,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Change recovery mode'),
                  ),
                ),
              ],
            ),
    );
  }
}
