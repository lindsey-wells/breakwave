// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_session_controller.dart
// Purpose: IOS-G2E privacy session state machine and persistent cooldown owner.
// Notes:
// - Not wired into BreakWaveShell during IOS-G2E.
// - Owns authentication/session state only, never recovery data.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';

import 'privacy_attempt_state.dart';
import 'privacy_attempt_store.dart';
import 'privacy_auth_result.dart';
import 'privacy_biometric_status.dart';
import 'privacy_credential_gateway.dart';
import 'privacy_destination.dart';
import 'privacy_lock_configuration.dart';
import 'privacy_lock_configuration_store.dart';
import 'privacy_session_state.dart';

typedef PrivacyClock = DateTime Function();

class PrivacySessionController extends ChangeNotifier {
  PrivacySessionController({
    required PrivacyCredentialGateway credentialGateway,
    PrivacyLockConfigurationStoreApi? configurationStore,
    PrivacyAttemptStoreApi? attemptStore,
    PrivacyClock? now,
    this.relockGracePeriod = const Duration(minutes: 2),
    this.failedAttemptCooldownThreshold = 10,
    this.failedAttemptCooldownDuration = const Duration(minutes: 5),
  })  : _credentialGateway = credentialGateway,
        _configurationStore =
            configurationStore ?? PrivacyLockConfigurationStore(),
        _attemptStore = attemptStore ?? PrivacyAttemptStore(),
        _now = now ?? DateTime.now;

  final PrivacyCredentialGateway _credentialGateway;
  final PrivacyLockConfigurationStoreApi _configurationStore;
  final PrivacyAttemptStoreApi _attemptStore;
  final PrivacyClock _now;

  final Duration relockGracePeriod;
  final int failedAttemptCooldownThreshold;
  final Duration failedAttemptCooldownDuration;

  PrivacySessionState _state = PrivacySessionState.locked;
  PrivacyLockConfiguration _configuration =
      PrivacyLockConfiguration.defaults;
  PrivacyAttemptState _attemptState = PrivacyAttemptState.empty;
  PrivacySessionState _authenticationReturnState =
      PrivacySessionState.locked;
  PrivacyDestination? _requestedProtectedDestination;
  DateTime? _backgroundedAtUtc;
  bool _initialized = false;
  int _authenticationGeneration = 0;

  PrivacySessionState get state => _state;
  PrivacyLockConfiguration get configuration => _configuration;
  PrivacyAttemptState get attemptState => _attemptState;
  PrivacyDestination? get requestedProtectedDestination =>
      _requestedProtectedDestination;
  DateTime? get backgroundedAtUtc => _backgroundedAtUtc;
  bool get isInitialized => _initialized;

  bool get isPinCoolingDown {
    return _attemptState.isCoolingDownAt(_now());
  }

  Duration get remainingPinCooldown {
    final DateTime? until = _attemptState.cooldownUntilUtc;
    if (until == null) return Duration.zero;

    final Duration remaining = until.difference(_now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> initialize() async {
    PrivacyLockConfiguration configuration;
    PrivacyAttemptState attemptState;

    try {
      configuration = await _configurationStore.load();
    } catch (_) {
      configuration =
          PrivacyLockConfigurationStore.failClosedConfiguration;
    }

    try {
      attemptState = await _attemptStore.load();
    } catch (_) {
      attemptState = PrivacyAttemptStore.defensiveFailureState;
    }

    _authenticationGeneration += 1;
    _configuration = configuration;
    _attemptState = attemptState;
    _backgroundedAtUtc = null;
    _requestedProtectedDestination = null;
    _initialized = true;

    final DateTime nowUtc = _now().toUtc();
    final bool normalizationFailed =
        !await _normalizeAttemptStateAt(nowUtc);

    if (normalizationFailed) {
      _attemptState = PrivacyAttemptStore.defensiveFailureState.copyWith(
        cooldownUntilUtc: nowUtc.add(failedAttemptCooldownDuration),
      );
    }

    _state = _configuration.isEnabled
        ? PrivacySessionState.locked
        : PrivacySessionState.unlocked;
    notifyListeners();
  }

  Future<void> enterRescueSafe() async {
    if (_state == PrivacySessionState.authenticating) {
      _authenticationGeneration += 1;
    }
    _requestedProtectedDestination = null;

    if (!_configuration.isEnabled) {
      _setState(PrivacySessionState.unlocked);
      return;
    }

    _setState(PrivacySessionState.rescueSafe);
  }

  Future<PrivacyAuthResult> unlockWithPin(String pin) async {
    if (!_configuration.isEnabled) {
      _setState(PrivacySessionState.unlocked);
      return PrivacyAuthResult.success;
    }

    if (_state == PrivacySessionState.authenticating) {
      return PrivacyAuthResult.error;
    }

    final DateTime nowUtc = _now().toUtc();
    if (!await _normalizeAttemptStateAt(nowUtc)) {
      return PrivacyAuthResult.error;
    }

    if (_attemptState.isCoolingDownAt(nowUtc)) {
      return PrivacyAuthResult.cooldown;
    }

    final int authenticationGeneration = _beginAuthentication();

    PrivacyAuthResult result;
    try {
      result = await _credentialGateway.verifyPin(pin);
    } catch (_) {
      result = PrivacyAuthResult.error;
    }

    if (authenticationGeneration != _authenticationGeneration) {
      if (result == PrivacyAuthResult.failed) {
        await _recordFailedPinAttempt(nowUtc);
      }
      return PrivacyAuthResult.cancelled;
    }

    switch (result) {
      case PrivacyAuthResult.success:
        if (!await _clearAttemptState()) {
          _restoreAfterAuthentication();
          return PrivacyAuthResult.error;
        }
        _backgroundedAtUtc = null;
        _setState(PrivacySessionState.unlocked);
        return PrivacyAuthResult.success;

      case PrivacyAuthResult.failed:
        final PrivacyAuthResult recorded =
            await _recordFailedPinAttempt(nowUtc);
        _restoreAfterAuthentication();
        return recorded;

      case PrivacyAuthResult.cooldown:
        _restoreAfterAuthentication();
        return PrivacyAuthResult.cooldown;

      case PrivacyAuthResult.cancelled:
      case PrivacyAuthResult.unavailable:
      case PrivacyAuthResult.error:
        _restoreAfterAuthentication();
        return result;
    }
  }

  Future<PrivacyBiometricStatus> biometricStatus() async {
    if (!_configuration.biometricEnabled ||
        !_configuration.credentialConfigured) {
      return PrivacyBiometricStatus.notAvailable;
    }

    try {
      return await _credentialGateway.biometricStatus();
    } catch (_) {
      return PrivacyBiometricStatus.unknown;
    }
  }

  Future<PrivacyAuthResult> unlockWithBiometrics() async {
    if (!_configuration.isEnabled) {
      _setState(PrivacySessionState.unlocked);
      return PrivacyAuthResult.success;
    }

    if (!_configuration.biometricEnabled ||
        !_configuration.credentialConfigured) {
      return PrivacyAuthResult.unavailable;
    }

    if (_state == PrivacySessionState.authenticating) {
      return PrivacyAuthResult.error;
    }

    final int authenticationGeneration = _beginAuthentication();

    PrivacyAuthResult result;
    try {
      result = await _credentialGateway.authenticateBiometric();
    } catch (_) {
      result = PrivacyAuthResult.error;
    }

    if (authenticationGeneration != _authenticationGeneration) {
      return PrivacyAuthResult.cancelled;
    }

    if (result == PrivacyAuthResult.success) {
      _backgroundedAtUtc = null;
      _setState(PrivacySessionState.unlocked);
      return result;
    }

    _restoreAfterAuthentication();
    return result;
  }

  void authenticationCancelled() {
    if (_state != PrivacySessionState.authenticating) return;
    _authenticationGeneration += 1;
    _restoreAfterAuthentication();
  }

  void onBackgrounded(DateTime at) {
    if (_state == PrivacySessionState.authenticating) {
      _authenticationGeneration += 1;
      _backgroundedAtUtc = null;
      _setState(_configuration.isEnabled
          ? PrivacySessionState.locked
          : PrivacySessionState.unlocked);
      return;
    }

    if (!_configuration.isEnabled ||
        _state != PrivacySessionState.unlocked) {
      return;
    }

    _backgroundedAtUtc ??= at.toUtc();
    notifyListeners();
  }

  void onResumed(DateTime at) {
    final DateTime? backgroundedAtUtc = _backgroundedAtUtc;
    _backgroundedAtUtc = null;

    if (!_configuration.isEnabled) {
      _setState(PrivacySessionState.unlocked);
      return;
    }

    if (backgroundedAtUtc == null ||
        _state != PrivacySessionState.unlocked) {
      notifyListeners();
      return;
    }

    final DateTime resumedAtUtc = at.toUtc();
    final bool clockMovedBackwards =
        resumedAtUtc.isBefore(backgroundedAtUtc);
    final Duration awayFor = resumedAtUtc.difference(backgroundedAtUtc);

    if (clockMovedBackwards || awayFor >= relockGracePeriod) {
      _setState(PrivacySessionState.locked);
      return;
    }

    notifyListeners();
  }

  void lockNow() {
    _authenticationGeneration += 1;
    _backgroundedAtUtc = null;
    _authenticationReturnState = PrivacySessionState.locked;

    if (_configuration.isEnabled) {
      _setState(PrivacySessionState.locked);
    } else {
      _setState(PrivacySessionState.unlocked);
    }
  }

  Future<void> applyConfiguration(
    PrivacyLockConfiguration configuration,
  ) async {
    await _configurationStore.save(configuration);
    _authenticationGeneration += 1;

    final bool wasEnabled = _configuration.isEnabled;
    _configuration = configuration;

    if (!configuration.isEnabled) {
      _backgroundedAtUtc = null;
      _requestedProtectedDestination = null;
      _setState(PrivacySessionState.unlocked);
      return;
    }

    if (!wasEnabled) {
      _backgroundedAtUtc = null;
      _setState(PrivacySessionState.locked);
      return;
    }

    notifyListeners();
  }

  void requestProtectedDestination(PrivacyDestination destination) {
    _requestedProtectedDestination = destination;
    notifyListeners();
  }

  PrivacyDestination? takeRequestedProtectedDestination() {
    final PrivacyDestination? destination = _requestedProtectedDestination;
    _requestedProtectedDestination = null;
    notifyListeners();
    return destination;
  }

  int _beginAuthentication() {
    _authenticationGeneration += 1;
    _authenticationReturnState = _state;
    _setState(PrivacySessionState.authenticating);
    return _authenticationGeneration;
  }

  void _restoreAfterAuthentication() {
    final PrivacySessionState returnState = _authenticationReturnState;
    _setState(returnState == PrivacySessionState.authenticating
        ? PrivacySessionState.locked
        : returnState);
  }

  Future<PrivacyAuthResult> _recordFailedPinAttempt(
    DateTime nowUtc,
  ) async {
    final int nextCount = _attemptState.failedAttemptCount + 1;
    final bool entersCooldown =
        nextCount >= failedAttemptCooldownThreshold;

    final PrivacyAttemptState nextState = PrivacyAttemptState(
      failedAttemptCount: nextCount,
      cooldownUntilUtc: entersCooldown
          ? nowUtc.add(failedAttemptCooldownDuration)
          : null,
    );

    _attemptState = nextState;

    try {
      await _attemptStore.save(nextState);
    } catch (_) {
      notifyListeners();
      return PrivacyAuthResult.error;
    }

    notifyListeners();
    return entersCooldown
        ? PrivacyAuthResult.cooldown
        : PrivacyAuthResult.failed;
  }

  Future<bool> _clearAttemptState() async {
    _attemptState = PrivacyAttemptState.empty;

    try {
      await _attemptStore.clear();
    } catch (_) {
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> _normalizeAttemptStateAt(DateTime nowUtc) async {
    final DateTime? cooldownUntilUtc = _attemptState.cooldownUntilUtc;

    if (cooldownUntilUtc != null) {
      if (nowUtc.isBefore(cooldownUntilUtc.toUtc())) {
        return true;
      }
      return _clearAttemptState();
    }

    if (_attemptState.failedAttemptCount >= failedAttemptCooldownThreshold) {
      final PrivacyAttemptState defensiveCooldown =
          _attemptState.copyWith(
        cooldownUntilUtc: nowUtc.add(failedAttemptCooldownDuration),
      );
      _attemptState = defensiveCooldown;
      try {
        await _attemptStore.save(defensiveCooldown);
      } catch (_) {
        notifyListeners();
        return false;
      }
      notifyListeners();
    }

    return true;
  }

  void _setState(PrivacySessionState next) {
    if (_state == next) {
      notifyListeners();
      return;
    }
    _state = next;
    notifyListeners();
  }
}
