// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_unlock_screen.dart
// Purpose: BW-49C 6-digit privacy unlock screen.
// Notes: Simple 6-digit PIN unlock surface with failed-attempt cooldown.
// ------------------------------------------------------------

import 'dart:async';

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
  static const int _failedAttemptCooldownThreshold = 10;
  static const Duration _failedAttemptCooldownDuration = Duration(minutes: 5);

  late final TextEditingController _controller;
  String? _error;
  bool _unlocking = false;
  int _failedAttempts = 0;
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _isCoolingDown {
    final DateTime? until = _cooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  String _modeCopy() {
    switch (widget.settings.mode) {
      case PrivacyLockMode.fullApp:
        return 'BreakWave is locked. Enter your 6-digit PIN to continue.';
      case PrivacyLockMode.sensitiveSections:
        return 'This section is locked. Enter your 6-digit PIN to continue.';
      case PrivacyLockMode.none:
        return 'Enter your 6-digit PIN.';
    }
  }

  void _startCooldownWindow() {
    _cooldownTimer?.cancel();
    _cooldownUntil = DateTime.now().add(_failedAttemptCooldownDuration);

    _cooldownTimer = Timer(_failedAttemptCooldownDuration, () {
      if (!mounted) return;

      setState(() {
        _cooldownUntil = null;
        _failedAttempts = 0;
        _error = null;
      });
    });
  }

  void _unlock() {
    if (_unlocking) return;

    if (_isCoolingDown) {
      setState(() {
        _error = 'Too many failed attempts. Try again in 5 minutes.';
      });
      return;
    }

    final String entered = _controller.text.trim();

    setState(() {
      _unlocking = true;
      _error = null;
    });

    if (entered == widget.settings.passcode) {
      _cooldownTimer?.cancel();
      _failedAttempts = 0;
      _cooldownUntil = null;
      widget.onUnlocked();
      return;
    }

    final int nextFailedAttempts = _failedAttempts + 1;
    final int attemptsRemaining =
        _failedAttemptCooldownThreshold - nextFailedAttempts;

    setState(() {
      _unlocking = false;
      _failedAttempts = nextFailedAttempts;

      if (nextFailedAttempts >= _failedAttemptCooldownThreshold) {
        _startCooldownWindow();
        _error = 'Too many failed attempts. Try again in 5 minutes.';
      } else {
        _error = 'Wrong PIN. $attemptsRemaining tries left before cooldown.';
      }
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
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: '6-digit PIN',
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 8),
                  if (_error != null) ...<Widget>[
                    Text(
                      _error!,
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: (_unlocking || _isCoolingDown) ? null : _unlock,
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
