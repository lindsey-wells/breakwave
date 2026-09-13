import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/platform/unsupported_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';
import 'package:breakwave/core/privacy_lock/privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_composition.dart';

class _FakeIosGateway implements PrivacyCredentialGateway {
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
      final PrivacyCredentialGateway injected = _FakeIosGateway();

      final PrivacyCredentialGateway resolved =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.android,
        androidGateway: injected,
      );

      expect(identical(resolved, injected), isTrue);
    });

    test('iOS fails closed until IOS-G2D injects the native gateway', () {
      final PrivacyCredentialGateway gateway =
          PrivacyLockComposition.credentialGatewayFor(
        platform: PrivacyCredentialPlatform.ios,
      );

      expect(
        gateway,
        isA<UnsupportedPrivacyCredentialGateway>(),
      );
    });

    test('iOS returns the injected native-bound gateway unchanged', () {
      final PrivacyCredentialGateway injected = _FakeIosGateway();

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
  });
}
