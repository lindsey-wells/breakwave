import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/platform/ios_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/platform/unsupported_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_attempt_state.dart';
import 'package:breakwave/core/privacy_lock/privacy_attempt_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';
import 'package:breakwave/core/privacy_lock/privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_composition.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_controller.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_state.dart';

class _FakeGateway implements PrivacyCredentialGateway {
  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    return PrivacyAuthResult.success;
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
    return PrivacyAuthResult.success;
  }
}

class _FakeAttemptStore implements PrivacyAttemptStoreApi {
  @override
  Future<void> clear() async {}

  @override
  Future<PrivacyAttemptState> load() async => PrivacyAttemptState.empty;

  @override
  Future<void> save(PrivacyAttemptState state) async {}
}

class _FakeConfigurationStore implements PrivacyLockConfigurationStoreApi {
  @override
  Future<void> clear() async {}

  @override
  Future<PrivacyLockConfiguration> load() async {
    return const PrivacyLockConfiguration(
      mode: PrivacyLockMode.fullApp,
      biometricEnabled: false,
      credentialConfigured: true,
    );
  }

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {}
}

void main() {
  group('PrivacyLockComposition', () {
    test('Android defaults to the legacy compatibility adapter', () {
      final PrivacyCredentialGateway gateway =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.android,
      );

      expect(
        gateway,
        isA<LegacyAndroidPrivacyCredentialGateway>(),
      );
    });

    test('Android accepts an injected compatibility gateway', () {
      final PrivacyCredentialGateway injected = _FakeGateway();

      final PrivacyCredentialGateway resolved =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.android,
        androidGateway: injected,
      );

      expect(identical(resolved, injected), isTrue);
    });

    test('iOS defaults to the native-bound credential gateway', () {
      final PrivacyCredentialGateway gateway =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.ios,
      );

      expect(gateway, isA<IosPrivacyCredentialGateway>());
    });

    test('iOS returns an injected credential gateway unchanged', () {
      final PrivacyCredentialGateway injected = _FakeGateway();

      final PrivacyCredentialGateway resolved =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.ios,
        iosGateway: injected,
      );

      expect(identical(resolved, injected), isTrue);
    });

    test('unsupported platforms always fail closed', () {
      final PrivacyCredentialGateway gateway =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.unsupported,
      );

      expect(
        gateway,
        isA<UnsupportedPrivacyCredentialGateway>(),
      );
    });

    test('session controller composition stays unhooked and injectable', () async {
      final PrivacySessionController controller =
          PrivacyLockComposition.sessionControllerFor(
        platform: PrivacyCredentialPlatform.ios,
        credentialGateway: _FakeGateway(),
        configurationStore: _FakeConfigurationStore(),
        attemptStore: _FakeAttemptStore(),
        now: () => DateTime.utc(2026, 9, 13, 12),
      );

      await controller.initialize();

      expect(controller.state, PrivacySessionState.locked);
      expect(controller.configuration.mode, PrivacyLockMode.fullApp);
    });
  });
}
