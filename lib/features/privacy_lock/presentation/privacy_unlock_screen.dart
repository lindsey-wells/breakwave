// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_unlock_screen.dart
// Purpose: IOS-G2F controller-driven 6-digit privacy unlock presentation.
// Notes:
// - Never reads or compares a stored PIN directly.
// - Persistent failed-attempt/cooldown state is owned by PrivacySessionController.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/privacy_lock/privacy_auth_result.dart';
import '../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../core/privacy_lock/privacy_session_controller.dart';

class PrivacyUnlockScreen extends StatefulWidget {
  const PrivacyUnlockScreen({
    super.key,
    required this.controller,
    required this.onUnlocked,
    required this.onCancelled,
  });

  final PrivacySessionController controller;
  final VoidCallback onUnlocked;
  final VoidCallback onCancelled;

  @override
  State<PrivacyUnlockScreen> createState() => _PrivacyUnlockScreenState();
}

class _PrivacyUnlockScreenState extends State<PrivacyUnlockScreen> {
  late final TextEditingController _pinController;
  Timer? _cooldownTicker;
  String? _error;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _syncCooldownTicker();
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  String _modeCopy() {
    switch (widget.controller.configuration.mode) {
      case PrivacyLockMode.fullApp:
        return 'BreakWave is locked. Enter your 6-digit PIN to continue.';
      case PrivacyLockMode.sensitiveSections:
        return 'This section is locked. Enter your 6-digit PIN to continue.';
      case PrivacyLockMode.none:
        return 'Enter your 6-digit PIN.';
    }
  }

  String _cooldownCopy() {
    final int totalSeconds =
        (widget.controller.remainingPinCooldown.inMilliseconds / 1000).ceil();
    if (totalSeconds <= 0) {
      return 'You can try your PIN again.';
    }

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String paddedSeconds = seconds.toString().padLeft(2, '0');
    return 'Too many failed attempts. Try again in $minutes:$paddedSeconds.';
  }

  void _syncCooldownTicker() {
    _cooldownTicker?.cancel();
    _cooldownTicker = null;

    if (!widget.controller.isPinCoolingDown) return;

    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!widget.controller.isPinCoolingDown) {
        _cooldownTicker?.cancel();
        _cooldownTicker = null;
        setState(() {
          _error = null;
        });
        return;
      }
      setState(() {});
    });
  }

  Future<void> _unlock() async {
    if (_unlocking) return;

    if (widget.controller.isPinCoolingDown) {
      setState(() {
        _error = _cooldownCopy();
      });
      _syncCooldownTicker();
      return;
    }

    final String pin = _pinController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() {
        _error = 'Enter your 6-digit PIN.';
      });
      return;
    }

    setState(() {
      _unlocking = true;
      _error = null;
    });

    final PrivacyAuthResult result = await widget.controller.unlockWithPin(pin);
    if (!mounted) return;

    switch (result) {
      case PrivacyAuthResult.success:
        _pinController.clear();
        setState(() {
          _unlocking = false;
          _error = null;
        });
        widget.onUnlocked();
        return;

      case PrivacyAuthResult.failed:
        final int attemptsRemaining =
            widget.controller.failedAttemptCooldownThreshold -
                widget.controller.attemptState.failedAttemptCount;
        _pinController.clear();
        setState(() {
          _unlocking = false;
          _error = 'Wrong PIN. $attemptsRemaining tries left before cooldown.';
        });
        return;

      case PrivacyAuthResult.cooldown:
        _pinController.clear();
        setState(() {
          _unlocking = false;
          _error = _cooldownCopy();
        });
        _syncCooldownTicker();
        return;

      case PrivacyAuthResult.cancelled:
        setState(() {
          _unlocking = false;
          _error = 'Unlock cancelled.';
        });
        return;

      case PrivacyAuthResult.unavailable:
        setState(() {
          _unlocking = false;
          _error = 'Privacy unlock is unavailable right now.';
        });
        return;

      case PrivacyAuthResult.error:
        setState(() {
          _unlocking = false;
          _error = 'Unable to unlock BreakWave right now.';
        });
        return;
    }
  }

  void _cancel() {
    if (_unlocking) return;
    widget.controller.authenticationCancelled();
    widget.onCancelled();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool coolingDown = widget.controller.isPinCoolingDown;

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Privacy lock',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_modeCopy(), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    enabled: !_unlocking && !coolingDown,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: '6-digit PIN',
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  if (coolingDown) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      _cooldownCopy(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ] else if (_error != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: (_unlocking || coolingDown) ? null : _unlock,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_unlocking ? 'Unlocking...' : 'Unlock'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _unlocking ? null : _cancel,
                    child: const Text('Cancel'),
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
