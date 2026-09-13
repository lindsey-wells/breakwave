// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: unsupported_privacy_credential_gateway.dart
// Purpose: IOS-G2C explicit fail-closed credential fallback.
// ------------------------------------------------------------

import '../privacy_auth_result.dart';
import '../privacy_biometric_status.dart';
import '../privacy_credential_gateway.dart';

class UnsupportedPrivacyCredentialGateway
    implements PrivacyCredentialGateway {
  const UnsupportedPrivacyCredentialGateway({
    required this.reason,
  });

  final String reason;

  @override
  Future<bool> isCredentialConfigured() async => false;

  @override
  Future<void> configurePin(String pin) async {
    throw UnsupportedError(reason);
  }

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    return PrivacyAuthResult.unavailable;
  }

  @override
  Future<void> clearCredential() async {
    throw UnsupportedError(reason);
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async {
    return PrivacyBiometricStatus.notAvailable;
  }

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    return PrivacyAuthResult.unavailable;
  }
}
