import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/privacy_attempt_state.dart';
import 'package:breakwave/core/privacy_lock/privacy_attempt_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';
import 'package:breakwave/core/privacy_lock/privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_destination.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_controller.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_state.dart';

class _FakeCredentialGateway implements PrivacyCredentialGateway {
  PrivacyAuthResult pinResult = PrivacyAuthResult.failed;
  PrivacyAuthResult biometricResult = PrivacyAuthResult.failed;
  int verifyPinCalls = 0;
  int biometricCalls = 0;
  Completer<PrivacyAuthResult>? pinCompleter;
  Completer<PrivacyAuthResult>? biometricCompleter;

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    biometricCalls += 1;
    final Completer<PrivacyAuthResult>? pending = biometricCompleter;
    if (pending != null) return pending.future;
    return biometricResult;
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async {
    return PrivacyBiometricStatus.available;
  }

  @override
  Future<void> clearCredential() async {}

  @override
  Future<void> configurePin(String pin) async {}

  @override
  Future<bool> isCredentialConfigured() async => true;

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    verifyPinCalls += 1;
    final Completer<PrivacyAuthResult>? pending = pinCompleter;
    if (pending != null) return pending.future;
    return pinResult;
  }
}

class _FakeAttemptStore implements PrivacyAttemptStoreApi {
  _FakeAttemptStore([this.state = PrivacyAttemptState.empty]);

  PrivacyAttemptState state;
  int saveCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    state = PrivacyAttemptState.empty;
  }

  @override
  Future<PrivacyAttemptState> load() async => state;

  @override
  Future<void> save(PrivacyAttemptState next) async {
    saveCalls += 1;
    state = next;
  }
}

class _FakeConfigurationStore implements PrivacyLockConfigurationStoreApi {
  _FakeConfigurationStore(this.configuration);

  PrivacyLockConfiguration configuration;
  int saveCalls = 0;

  @override
  Future<void> clear() async {
    configuration = PrivacyLockConfiguration.defaults;
  }

  @override
  Future<PrivacyLockConfiguration> load() async => configuration;

  @override
  Future<void> save(PrivacyLockConfiguration next) async {
    saveCalls += 1;
    configuration = next;
  }
}

const PrivacyLockConfiguration _fullAppConfiguration =
    PrivacyLockConfiguration(
  mode: PrivacyLockMode.fullApp,
  biometricEnabled: false,
  credentialConfigured: true,
);

const PrivacyLockConfiguration _fullAppBiometricConfiguration =
    PrivacyLockConfiguration(
  mode: PrivacyLockMode.fullApp,
  biometricEnabled: true,
  credentialConfigured: true,
);

void main() {
  group('PrivacySessionController', () {
    late DateTime now;
    late _FakeCredentialGateway gateway;
    late _FakeAttemptStore attempts;
    late _FakeConfigurationStore configurations;

    PrivacySessionController buildController() {
      return PrivacySessionController(
        credentialGateway: gateway,
        configurationStore: configurations,
        attemptStore: attempts,
        now: () => now,
      );
    }

    setUp(() {
      now = DateTime.utc(2026, 9, 13, 12);
      gateway = _FakeCredentialGateway();
      attempts = _FakeAttemptStore();
      configurations = _FakeConfigurationStore(_fullAppConfiguration);
    });

    test('cold enabled start is locked', () async {
      final PrivacySessionController controller = buildController();

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.state, PrivacySessionState.locked);
      expect(controller.configuration.isEnabled, isTrue);
    });

    test('cold no-lock start is unlocked', () async {
      configurations = _FakeConfigurationStore(
        PrivacyLockConfiguration.defaults,
      );
      final PrivacySessionController controller = buildController();

      await controller.initialize();

      expect(controller.state, PrivacySessionState.unlocked);
    });

    test('enter Rescue-safe never grants an unlocked session', () async {
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      await controller.enterRescueSafe();

      expect(controller.state, PrivacySessionState.rescueSafe);
      expect(controller.state, isNot(PrivacySessionState.unlocked));
    });

    test('successful PIN auth unlocks and clears persistent attempts', () async {
      attempts = _FakeAttemptStore(
        const PrivacyAttemptState(
          failedAttemptCount: 4,
          cooldownUntilUtc: null,
        ),
      );
      gateway.pinResult = PrivacyAuthResult.success;
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      final PrivacyAuthResult result =
          await controller.unlockWithPin('123456');

      expect(result, PrivacyAuthResult.success);
      expect(controller.state, PrivacySessionState.unlocked);
      expect(controller.attemptState.failedAttemptCount, 0);
      expect(attempts.clearCalls, 1);
    });

    test('auth cancellation returns to Rescue-safe', () async {
      gateway.pinResult = PrivacyAuthResult.cancelled;
      final PrivacySessionController controller = buildController();
      await controller.initialize();
      await controller.enterRescueSafe();

      final PrivacyAuthResult result =
          await controller.unlockWithPin('123456');

      expect(result, PrivacyAuthResult.cancelled);
      expect(controller.state, PrivacySessionState.rescueSafe);
      expect(controller.attemptState.failedAttemptCount, 0);
    });

    test('manual authenticationCancelled invalidates stale success', () async {
      gateway.pinCompleter = Completer<PrivacyAuthResult>();
      final PrivacySessionController controller = buildController();
      await controller.initialize();
      await controller.enterRescueSafe();
      controller.requestProtectedDestination(PrivacyDestination.log);

      final Future<PrivacyAuthResult> pending =
          controller.unlockWithPin('123456');
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, PrivacySessionState.authenticating);

      controller.authenticationCancelled();
      expect(controller.state, PrivacySessionState.rescueSafe);

      gateway.pinCompleter!.complete(PrivacyAuthResult.success);
      expect(await pending, PrivacyAuthResult.cancelled);
      expect(controller.state, PrivacySessionState.rescueSafe);
      expect(
        controller.requestedProtectedDestination,
        PrivacyDestination.log,
      );
    });

    test('two-minute grace preserves then relocks an unlocked session', () async {
      gateway.pinResult = PrivacyAuthResult.success;
      final PrivacySessionController controller = buildController();
      await controller.initialize();
      await controller.unlockWithPin('123456');

      final DateTime firstBackground = now;
      controller.onBackgrounded(firstBackground);
      controller.onResumed(firstBackground.add(const Duration(seconds: 119)));
      expect(controller.state, PrivacySessionState.unlocked);

      final DateTime secondBackground =
          firstBackground.add(const Duration(minutes: 10));
      controller.onBackgrounded(secondBackground);
      controller.onResumed(secondBackground.add(const Duration(minutes: 2)));
      expect(controller.state, PrivacySessionState.locked);
    });

    test('clock rollback on resume fails closed to locked', () async {
      gateway.pinResult = PrivacyAuthResult.success;
      final PrivacySessionController controller = buildController();
      await controller.initialize();
      await controller.unlockWithPin('123456');

      controller.onBackgrounded(now);
      controller.onResumed(now.subtract(const Duration(seconds: 1)));

      expect(controller.state, PrivacySessionState.locked);
    });

    test('restart semantics preserve an active cooldown', () async {
      final DateTime cooldownUntil = now.add(const Duration(minutes: 5));
      attempts = _FakeAttemptStore(
        PrivacyAttemptState(
          failedAttemptCount: 10,
          cooldownUntilUtc: cooldownUntil,
        ),
      );

      final PrivacySessionController first = buildController();
      await first.initialize();
      expect(first.isPinCoolingDown, isTrue);

      final PrivacySessionController second = buildController();
      await second.initialize();
      expect(second.isPinCoolingDown, isTrue);

      final PrivacyAuthResult result =
          await second.unlockWithPin('123456');
      expect(result, PrivacyAuthResult.cooldown);
      expect(gateway.verifyPinCalls, 0);
    });

    test('ten failed PIN attempts enter a persisted five-minute cooldown', () async {
      gateway.pinResult = PrivacyAuthResult.failed;
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      for (int attempt = 1; attempt <= 9; attempt += 1) {
        expect(
          await controller.unlockWithPin('000000'),
          PrivacyAuthResult.failed,
        );
      }

      final PrivacyAuthResult tenth =
          await controller.unlockWithPin('000000');

      expect(tenth, PrivacyAuthResult.cooldown);
      expect(controller.attemptState.failedAttemptCount, 10);
      expect(
        controller.attemptState.cooldownUntilUtc,
        now.add(const Duration(minutes: 5)),
      );
      expect(attempts.state.failedAttemptCount, 10);
      expect(attempts.saveCalls, 10);
    });

    test('cooldown never blocks Rescue-safe', () async {
      attempts = _FakeAttemptStore(
        PrivacyAttemptState(
          failedAttemptCount: 10,
          cooldownUntilUtc: now.add(const Duration(minutes: 5)),
        ),
      );
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      expect(controller.isPinCoolingDown, isTrue);

      await controller.enterRescueSafe();

      expect(controller.state, PrivacySessionState.rescueSafe);
    });

    test('expired cooldown clears during initialization', () async {
      attempts = _FakeAttemptStore(
        PrivacyAttemptState(
          failedAttemptCount: 10,
          cooldownUntilUtc: now.subtract(const Duration(seconds: 1)),
        ),
      );
      final PrivacySessionController controller = buildController();

      await controller.initialize();

      expect(controller.attemptState.failedAttemptCount, 0);
      expect(controller.attemptState.cooldownUntilUtc, isNull);
      expect(attempts.clearCalls, 1);
      expect(controller.state, PrivacySessionState.locked);
    });

    test('defensive failure count without timestamp starts cooldown', () async {
      attempts = _FakeAttemptStore(
        PrivacyAttemptStore.defensiveFailureState,
      );
      final PrivacySessionController controller = buildController();

      await controller.initialize();

      expect(controller.isPinCoolingDown, isTrue);
      expect(
        controller.attemptState.cooldownUntilUtc,
        now.add(const Duration(minutes: 5)),
      );
      expect(attempts.saveCalls, 1);
    });

    test('biometric failure never increments the PIN counter', () async {
      configurations = _FakeConfigurationStore(
        _fullAppBiometricConfiguration,
      );
      attempts = _FakeAttemptStore(
        const PrivacyAttemptState(
          failedAttemptCount: 3,
          cooldownUntilUtc: null,
        ),
      );
      gateway.biometricResult = PrivacyAuthResult.failed;
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      final PrivacyAuthResult result =
          await controller.unlockWithBiometrics();

      expect(result, PrivacyAuthResult.failed);
      expect(controller.state, PrivacySessionState.locked);
      expect(controller.attemptState.failedAttemptCount, 3);
      expect(attempts.saveCalls, 0);
    });

    test('successful biometrics unlock without resetting PIN attempts', () async {
      configurations = _FakeConfigurationStore(
        _fullAppBiometricConfiguration,
      );
      attempts = _FakeAttemptStore(
        const PrivacyAttemptState(
          failedAttemptCount: 3,
          cooldownUntilUtc: null,
        ),
      );
      gateway.biometricResult = PrivacyAuthResult.success;
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      final PrivacyAuthResult result =
          await controller.unlockWithBiometrics();

      expect(result, PrivacyAuthResult.success);
      expect(controller.state, PrivacySessionState.unlocked);
      expect(controller.attemptState.failedAttemptCount, 3);
      expect(attempts.clearCalls, 0);
    });

    test('requested destination is controller-owned and consumable', () async {
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      controller.requestProtectedDestination(PrivacyDestination.support);

      expect(
        controller.requestedProtectedDestination,
        PrivacyDestination.support,
      );
      expect(
        controller.takeRequestedProtectedDestination(),
        PrivacyDestination.support,
      );
      expect(controller.requestedProtectedDestination, isNull);
    });

    test('disabling configuration unlocks without touching recovery data', () async {
      final PrivacySessionController controller = buildController();
      await controller.initialize();

      await controller.applyConfiguration(
        PrivacyLockConfiguration.defaults,
      );

      expect(configurations.saveCalls, 1);
      expect(controller.configuration.isEnabled, isFalse);
      expect(controller.state, PrivacySessionState.unlocked);
    });
  });
}
