import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/platform/ios_privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/platform/privacy_native_bridge.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';

class _FakeNativeBridge implements PrivacyNativeBridgeApi {
  String? configuredPin;
  String? verifiedPin;

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    return PrivacyAuthResult.success;
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async {
    return PrivacyBiometricStatus.available;
  }

  @override
  Future<void> clearCredential() async {
    configuredPin = null;
  }

  @override
  Future<void> configurePin(String pin) async {
    configuredPin = pin;
  }

  @override
  Future<bool> isCredentialConfigured() async {
    return configuredPin != null;
  }

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    verifiedPin = pin;
    return pin == configuredPin
        ? PrivacyAuthResult.success
        : PrivacyAuthResult.failed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrivacyNativeBridge protocol', () {
    const MethodChannel channel = MethodChannel('breakwave/privacy_auth-test');
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() async {
      messenger.setMockMethodCallHandler(channel, null);
    });

    test('uses only the approved channel methods and bounded values', () async {
      final List<MethodCall> calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call);
        switch (call.method) {
          case 'credentialStatus':
            return 'configured';
          case 'configurePin':
          case 'clearCredential':
            return 'success';
          case 'verifyPin':
            return 'failed';
          case 'biometricStatus':
            return 'notEnrolled';
          case 'authenticateBiometric':
            return 'cancelled';
          default:
            return 'error';
        }
      });

      final PrivacyNativeBridge bridge = PrivacyNativeBridge(channel: channel);

      expect(await bridge.isCredentialConfigured(), isTrue);
      await bridge.configurePin('123456');
      expect(await bridge.verifyPin('654321'), PrivacyAuthResult.failed);
      await bridge.clearCredential();
      expect(
        await bridge.biometricStatus(),
        PrivacyBiometricStatus.notEnrolled,
      );
      expect(
        await bridge.authenticateBiometric(),
        PrivacyAuthResult.cancelled,
      );

      expect(
        calls.map((MethodCall call) => call.method).toList(),
        <String>[
          'credentialStatus',
          'configurePin',
          'verifyPin',
          'clearCredential',
          'biometricStatus',
          'authenticateBiometric',
        ],
      );
      expect(calls[1].arguments, <String, Object?>{'pin': '123456'});
      expect(calls[2].arguments, <String, Object?>{'pin': '654321'});
    });

    test('unexpected native results fail closed to error/unknown', () async {
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'credentialStatus') {
          return 'error';
        }
        return 'unexpected';
      });

      final PrivacyNativeBridge bridge = PrivacyNativeBridge(channel: channel);

      await expectLater(
        bridge.isCredentialConfigured(),
        throwsStateError,
      );
      expect(
        await bridge.verifyPin('123456'),
        PrivacyAuthResult.error,
      );
      expect(
        await bridge.biometricStatus(),
        PrivacyBiometricStatus.unknown,
      );
    });
  });

  group('IosPrivacyCredentialGateway', () {
    test('validates PIN shape before crossing the native boundary', () async {
      final _FakeNativeBridge bridge = _FakeNativeBridge();
      final IosPrivacyCredentialGateway gateway =
          IosPrivacyCredentialGateway(bridge: bridge);

      await expectLater(
        gateway.configurePin('12345'),
        throwsArgumentError,
      );
      expect(bridge.configuredPin, isNull);

      expect(
        await gateway.verifyPin('12ab56'),
        PrivacyAuthResult.failed,
      );
      expect(bridge.verifiedPin, isNull);
    });

    test('delegates valid credential and biometric operations', () async {
      final _FakeNativeBridge bridge = _FakeNativeBridge();
      final IosPrivacyCredentialGateway gateway =
          IosPrivacyCredentialGateway(bridge: bridge);

      await gateway.configurePin('123456');
      expect(await gateway.isCredentialConfigured(), isTrue);
      expect(
        await gateway.verifyPin('123456'),
        PrivacyAuthResult.success,
      );
      expect(
        await gateway.biometricStatus(),
        PrivacyBiometricStatus.available,
      );
      expect(
        await gateway.authenticateBiometric(),
        PrivacyAuthResult.success,
      );
      await gateway.clearCredential();
      expect(await gateway.isCredentialConfigured(), isFalse);
    });
  });
}
