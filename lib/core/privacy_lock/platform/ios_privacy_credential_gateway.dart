// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: ios_privacy_credential_gateway.dart
// Purpose: IOS-G2D iOS implementation of PrivacyCredentialGateway.
// ------------------------------------------------------------

import '../privacy_auth_result.dart';
import '../privacy_biometric_status.dart';
import '../privacy_credential_gateway.dart';
import 'privacy_native_bridge.dart';

class IosPrivacyCredentialGateway implements PrivacyCredentialGateway {
  IosPrivacyCredentialGateway({PrivacyNativeBridgeApi? bridge})
      : _bridge = bridge ?? PrivacyNativeBridge();

  final PrivacyNativeBridgeApi _bridge;

  static final RegExp _sixDigitPin = RegExp(r'^\d{6}$');

  @override
  Future<bool> isCredentialConfigured() {
    return _bridge.isCredentialConfigured();
  }

  @override
  Future<void> configurePin(String pin) {
    if (!_sixDigitPin.hasMatch(pin)) {
      throw ArgumentError(
        'BreakWave privacy PIN must contain exactly six digits.',
      );
    }
    return _bridge.configurePin(pin);
  }

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) {
    if (!_sixDigitPin.hasMatch(pin)) {
      return Future<PrivacyAuthResult>.value(
        PrivacyAuthResult.failed,
      );
    }
    return _bridge.verifyPin(pin);
  }

  @override
  Future<void> clearCredential() {
    return _bridge.clearCredential();
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() {
    return _bridge.biometricStatus();
  }

  @override
  Future<PrivacyAuthResult> authenticateBiometric() {
    return _bridge.authenticateBiometric();
  }
}
