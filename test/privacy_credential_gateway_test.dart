import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/platform/unsupported_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_settings.dart';

void main() {
  group('LegacyAndroidPrivacyCredentialGateway', () {
    late PrivacyLockSettings stored;
    late LegacyAndroidPrivacyCredentialGateway gateway;

    setUp(() {
      stored = const PrivacyLockSettings(
        mode: PrivacyLockMode.fullApp,
        passcode: '123456',
      );

      gateway = LegacyAndroidPrivacyCredentialGateway(
        loadSettings: () async => stored,
        saveSettings: (PrivacyLockSettings settings) async {
          stored = settings;
        },
      );
    });

    test('reports the existing six-character credential as configured', () async {
      expect(await gateway.isCredentialConfigured(), isTrue);
    });

    test('verifies the existing Android PIN without changing storage', () async {
      expect(
        await gateway.verifyPin('123456'),
        PrivacyAuthResult.success,
      );
      expect(stored.passcode, '123456');

      expect(
        await gateway.verifyPin('654321'),
        PrivacyAuthResult.failed,
      );
      expect(stored.passcode, '123456');
    });

    test('invalid PIN input fails without changing storage', () async {
      expect(
        await gateway.verifyPin('12ab56'),
        PrivacyAuthResult.failed,
      );
      expect(stored.passcode, '123456');
    });

    test('missing legacy credential returns unavailable', () async {
      stored = stored.copyWith(passcode: '');

      expect(await gateway.isCredentialConfigured(), isFalse);
      expect(
        await gateway.verifyPin('123456'),
        PrivacyAuthResult.unavailable,
      );
    });

    test('configurePin preserves the existing lock mode', () async {
      await gateway.configurePin('654321');

      expect(stored.mode, PrivacyLockMode.fullApp);
      expect(stored.passcode, '654321');
    });

    test('configurePin rejects invalid input without echoing the PIN', () async {
      const String invalidPin = '12ab56';

      try {
        await gateway.configurePin(invalidPin);
        fail('configurePin should reject malformed PIN input.');
      } on ArgumentError catch (error) {
        expect(error.toString(), isNot(contains(invalidPin)));
      }

      expect(stored.passcode, '123456');
    });

    test('clearCredential preserves mode but removes legacy PIN', () async {
      await gateway.clearCredential();

      expect(stored.mode, PrivacyLockMode.fullApp);
      expect(stored.passcode, isEmpty);
      expect(await gateway.isCredentialConfigured(), isFalse);
    });

    test('legacy Android adapter does not claim biometric support', () async {
      expect(
        await gateway.biometricStatus(),
        PrivacyBiometricStatus.notAvailable,
      );
      expect(
        await gateway.authenticateBiometric(),
        PrivacyAuthResult.unavailable,
      );
    });
  });

  group('UnsupportedPrivacyCredentialGateway', () {
    const UnsupportedPrivacyCredentialGateway gateway =
        UnsupportedPrivacyCredentialGateway(
      reason: 'test unsupported',
    );

    test('fails closed without inventing a credential', () async {
      expect(await gateway.isCredentialConfigured(), isFalse);
      expect(
        await gateway.verifyPin('123456'),
        PrivacyAuthResult.unavailable,
      );
      expect(
        await gateway.biometricStatus(),
        PrivacyBiometricStatus.notAvailable,
      );
      expect(
        await gateway.authenticateBiometric(),
        PrivacyAuthResult.unavailable,
      );
    });

    test('refuses credential mutation', () async {
      await expectLater(
        gateway.configurePin('123456'),
        throwsA(isA<UnsupportedError>()),
      );
      await expectLater(
        gateway.clearCredential(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
