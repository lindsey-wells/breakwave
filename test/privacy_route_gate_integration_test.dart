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
import 'package:breakwave/core/privacy_lock/privacy_route_policy.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_controller.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_state.dart';

class _Gateway implements PrivacyCredentialGateway {
  final List<PrivacyAuthResult> pinResults = <PrivacyAuthResult>[];

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async =>
      PrivacyAuthResult.unavailable;

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async =>
      PrivacyBiometricStatus.notAvailable;

  @override
  Future<void> clearCredential() async {}

  @override
  Future<void> configurePin(String pin) async {}

  @override
  Future<bool> isCredentialConfigured() async => true;

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    return pinResults.removeAt(0);
  }
}

class _ConfigStore implements PrivacyLockConfigurationStoreApi {
  _ConfigStore(this.configuration);

  PrivacyLockConfiguration configuration;

  @override
  Future<void> clear() async {}

  @override
  Future<PrivacyLockConfiguration> load() async => configuration;

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {
    this.configuration = configuration;
  }
}

class _AttemptStore implements PrivacyAttemptStoreApi {
  PrivacyAttemptState state = PrivacyAttemptState.empty;

  @override
  Future<void> clear() async {
    state = PrivacyAttemptState.empty;
  }

  @override
  Future<PrivacyAttemptState> load() async => state;

  @override
  Future<void> save(PrivacyAttemptState state) async {
    this.state = state;
  }
}

void main() {
  test('Full App locked route gate exposes only locked landing and Rescue-safe',
      () async {
    final _Gateway gateway = _Gateway();
    final PrivacySessionController controller = PrivacySessionController(
      credentialGateway: gateway,
      configurationStore: _ConfigStore(
        const PrivacyLockConfiguration(
          mode: PrivacyLockMode.fullApp,
          biometricEnabled: false,
          credentialConfigured: true,
        ),
      ),
      attemptStore: _AttemptStore(),
      now: () => DateTime.utc(2026, 9, 13, 16),
    );
    await controller.initialize();

    expect(controller.state, PrivacySessionState.locked);
    expect(
      PrivacyRoutePolicy.canAccess(
        destination: PrivacyDestination.lockedLanding,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isTrue,
    );
    expect(
      PrivacyRoutePolicy.canAccess(
        destination: PrivacyDestination.home,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isFalse,
    );

    await controller.enterRescueSafe();
    expect(controller.state, PrivacySessionState.rescueSafe);
    expect(
      PrivacyRoutePolicy.canAccess(
        destination: PrivacyDestination.rescueSafe,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isTrue,
    );
    expect(
      PrivacyRoutePolicy.canAccess(
        destination: PrivacyDestination.rescuePersonalized,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isFalse,
    );
  });

  test('requested protected destination survives failure and opens after success',
      () async {
    final _Gateway gateway = _Gateway()
      ..pinResults.addAll(<PrivacyAuthResult>[
        PrivacyAuthResult.failed,
        PrivacyAuthResult.success,
      ]);
    final PrivacySessionController controller = PrivacySessionController(
      credentialGateway: gateway,
      configurationStore: _ConfigStore(
        const PrivacyLockConfiguration(
          mode: PrivacyLockMode.fullApp,
          biometricEnabled: false,
          credentialConfigured: true,
        ),
      ),
      attemptStore: _AttemptStore(),
      now: () => DateTime.utc(2026, 9, 13, 16),
    );
    await controller.initialize();
    await controller.enterRescueSafe();

    controller.requestProtectedDestination(PrivacyDestination.log);
    expect(await controller.unlockWithPin('111111'), PrivacyAuthResult.failed);
    expect(controller.state, PrivacySessionState.rescueSafe);
    expect(controller.requestedProtectedDestination, PrivacyDestination.log);

    expect(await controller.unlockWithPin('222222'), PrivacyAuthResult.success);
    expect(controller.state, PrivacySessionState.unlocked);
    expect(
      PrivacyRoutePolicy.canAccess(
        destination: PrivacyDestination.log,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isTrue,
    );
    expect(controller.takeRequestedProtectedDestination(), PrivacyDestination.log);
  });

  test('Sensitive Sections keeps Home and personalized Rescue open but gates Log',
      () async {
    final PrivacySessionController controller = PrivacySessionController(
      credentialGateway: _Gateway(),
      configurationStore: _ConfigStore(
        const PrivacyLockConfiguration(
          mode: PrivacyLockMode.sensitiveSections,
          biometricEnabled: false,
          credentialConfigured: true,
        ),
      ),
      attemptStore: _AttemptStore(),
      now: () => DateTime.utc(2026, 9, 13, 16),
    );
    await controller.initialize();

    expect(
      PrivacyRoutePolicy.requiresAuthentication(
        destination: PrivacyDestination.home,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isFalse,
    );
    expect(
      PrivacyRoutePolicy.requiresAuthentication(
        destination: PrivacyDestination.rescuePersonalized,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isFalse,
    );
    expect(
      PrivacyRoutePolicy.requiresAuthentication(
        destination: PrivacyDestination.log,
        lockMode: controller.configuration.mode,
        sessionState: controller.state,
      ),
      isTrue,
    );
  });
}
