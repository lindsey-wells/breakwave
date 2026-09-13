// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_credential_gateway.dart
// Purpose: IOS-G2C platform-neutral credential boundary.
// Notes: Never exposes stored PIN, verifier, salt, or biometric secret.
// ------------------------------------------------------------

import 'privacy_auth_result.dart';
import 'privacy_biometric_status.dart';

abstract interface class PrivacyCredentialGateway {
  Future<bool> isCredentialConfigured();

  Future<void> configurePin(String pin);

  Future<PrivacyAuthResult> verifyPin(String pin);

  Future<void> clearCredential();

  Future<PrivacyBiometricStatus> biometricStatus();

  Future<PrivacyAuthResult> authenticateBiometric();
}
