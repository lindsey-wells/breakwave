// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_unlock_screen.dart
// Purpose: IOS-G2I privacy unlock presentation with optional biometric convenience.
// Notes:
// - PIN remains available as the authoritative fallback.
// - Biometrics are shown only when enabled and reported available.
// - Never reads or compares stored credential material directly.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/privacy_lock/privacy_auth_result.dart';
import '../../../core/privacy_lock/privacy_biometric_status.dart';
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
  PrivacyBiometricStatus _biometricStatus = PrivacyBiometricStatus.unknown;
  bool _biometricStatusLoaded = false;

  bool get _showBiometricUnlock =>
      widget.controller.configuration.biometricEnabled &&
      widget.controller.configuration.credentialConfigured &&
      _biometricStatus == PrivacyBiometricStatus.available;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _syncCooldownTicker();
    unawaited(_loadBiometricStatus());
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricStatus() async {
    final PrivacyBiometricStatus status =
        await widget.controller.biometricStatus();
    if (!mounted) return;
    setState(() {
      _biometricStatus = status;
      _biometricStatusLoaded = true;
    });
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
    if (!RegExp(r'^\\d{6}$').hasMatch(pin)) {
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

  Future<void> _unlockWithBiometrics() async {
    if (_unlocking || !_showBiometricUnlock) return;

    setState(() {
      _unlocking = true;
      _error = null;
    });

    final PrivacyAuthResult result =
        await widget.controller.unlockWithBiometrics();
    if (!mounted) return;

    switch (result) {
      case PrivacyAuthResult.success:
        setState(() {
          _unlocking = false;
          _error = null;
        });
        widget.onUnlocked();
        return;
      case PrivacyAuthResult.cancelled:
        setState(() {
          _unlocking = false;
          _error = 'Biometric unlock cancelled. You can still use your PIN.';
        });
        return;
      case PrivacyAuthResult.failed:
        setState(() {
          _unlocking = false;
          _error = 'Biometric unlock did not match. Try again or use your PIN.';
        });
        return;
      case PrivacyAuthResult.unavailable:
        setState(() {
          _unlocking = false;
          _biometricStatus = PrivacyBiometricStatus.notAvailable;
          _error = 'Biometric unlock is unavailable. Use your PIN.';
        });
        return;
      case PrivacyAuthResult.cooldown:
      case PrivacyAuthResult.error:
        setState(() {
          _unlocking = false;
          _error = 'Unable to use biometric unlock. Use your PIN.';
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
                  if (_showBiometricUnlock) ...<Widget>[
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: _unlocking ? null : _unlockWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          _unlocking ? 'Checking...' : 'Use Face ID / Touch ID',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Or use your BreakWave PIN.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (!_biometricStatusLoaded &&
                      widget.controller.configuration.biometricEnabled) ...<Widget>[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
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
                    decoration: const InputDecoration(labelText: '6-digit PIN'),
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
