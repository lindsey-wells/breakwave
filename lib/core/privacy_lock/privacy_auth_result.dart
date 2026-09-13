// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_auth_result.dart
// Purpose: IOS-G2C bounded privacy authentication result contract.
// ------------------------------------------------------------

enum PrivacyAuthResult {
  success,
  cancelled,
  failed,
  cooldown,
  unavailable,
  error,
}
