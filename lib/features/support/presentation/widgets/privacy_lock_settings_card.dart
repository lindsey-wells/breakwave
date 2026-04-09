// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_settings_card.dart
// Purpose: BW-41 privacy lock settings card.
// Notes: Lets the user choose lock mode and save a 4-digit passcode.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../../core/privacy_lock/privacy_lock_settings.dart';
import '../../../../core/privacy_lock/privacy_lock_store.dart';

class PrivacyLockSettingsCard extends StatefulWidget {
  const PrivacyLockSettingsCard({super.key});

  @override
  State<PrivacyLockSettingsCard> createState() => _PrivacyLockSettingsCardState();
}

class _PrivacyLockSettingsCardState extends State<PrivacyLockSettingsCard> {
  late final TextEditingController _passcodeController;
  late final TextEditingController _confirmController;

  bool _loading = true;
  bool _saving = false;
  PrivacyLockMode _mode = PrivacyLockMode.none;
  String _savedPasscode = '';

  @override
  void initState() {
    super.initState();
    _passcodeController = TextEditingController();
    _confirmController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final PrivacyLockSettings settings = await PrivacyLockStore.load();
    if (!mounted) return;

    setState(() {
      _mode = settings.mode;
      _savedPasscode = settings.passcode;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    final String passcode = _passcodeController.text.trim();
    final String confirm = _confirmController.text.trim();

    if (_mode == PrivacyLockMode.none) {
      setState(() {
        _saving = true;
      });

      try {
        await PrivacyLockStore.save(
          const PrivacyLockSettings(
            mode: PrivacyLockMode.none,
            passcode: '',
          ),
        );

        _savedPasscode = '';
        _passcodeController.clear();
        _confirmController.clear();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy lock disabled.'),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save privacy lock right now.'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
      return;
    }

    final String effectivePasscode =
        passcode.isEmpty && confirm.isEmpty ? _savedPasscode : passcode;
    final String effectiveConfirm =
        passcode.isEmpty && confirm.isEmpty ? _savedPasscode : confirm;

    if (effectivePasscode.length != 4 || effectiveConfirm.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter and confirm a 4-digit passcode.'),
        ),
      );
      return;
    }

    if (effectivePasscode != effectiveConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passcodes do not match.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await PrivacyLockStore.save(
        PrivacyLockSettings(
          mode: _mode,
          passcode: effectivePasscode,
        ),
      );

      _savedPasscode = effectivePasscode;
      _passcodeController.clear();
      _confirmController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Privacy lock saved: ${_mode.label}.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save privacy lock right now.'),
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

  Future<void> _clearLock() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await PrivacyLockStore.clear();
      _savedPasscode = '';
      _passcodeController.clear();
      _confirmController.clear();

      if (!mounted) return;
      setState(() {
        _mode = PrivacyLockMode.none;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy lock cleared.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear privacy lock right now.'),
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
                  'Privacy lock',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add a passcode so sensitive parts of BreakWave feel safer to use honestly.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: PrivacyLockMode.values.map((PrivacyLockMode mode) {
                    return ChoiceChip(
                      label: Text(mode.label),
                      selected: _mode == mode,
                      onSelected: (_) {
                        setState(() {
                          _mode = mode;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  _mode.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passcodeController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Set 4-digit passcode',
                    hintText: 'Example: 1234',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Confirm 4-digit passcode',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save privacy lock'),
                  ),
                ),
                if (_savedPasscode.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saving ? null : _clearLock,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Clear privacy lock'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
