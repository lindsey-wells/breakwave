// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_unlock_screen.dart
// Purpose: BW-41 privacy unlock screen.
// Notes: Simple 4-digit unlock surface for full-app or sensitive-section locks.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../core/privacy_lock/privacy_lock_settings.dart';

class PrivacyUnlockScreen extends StatefulWidget {
  const PrivacyUnlockScreen({
    super.key,
    required this.settings,
    required this.onUnlocked,
  });

  final PrivacyLockSettings settings;
  final VoidCallback onUnlocked;

  @override
  State<PrivacyUnlockScreen> createState() => _PrivacyUnlockScreenState();
}

class _PrivacyUnlockScreenState extends State<PrivacyUnlockScreen> {
  late final TextEditingController _controller;
  String? _error;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _modeCopy() {
    switch (widget.settings.mode) {
      case PrivacyLockMode.fullApp:
        return 'BreakWave is locked. Enter your 4-digit passcode to continue.';
      case PrivacyLockMode.sensitiveSections:
        return 'This section is locked. Enter your 4-digit passcode to continue.';
      case PrivacyLockMode.none:
        return 'Enter your 4-digit passcode.';
    }
  }

  void _unlock() {
    if (_unlocking) return;

    final String entered = _controller.text.trim();

    setState(() {
      _unlocking = true;
      _error = null;
    });

    if (entered == widget.settings.passcode) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _unlocking = false;
      _error = 'That passcode does not match.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Privacy lock',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _modeCopy(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: '4-digit passcode',
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _unlocking ? null : _unlock,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Unlock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
