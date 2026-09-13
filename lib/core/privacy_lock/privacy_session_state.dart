// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_session_state.dart
// Purpose: IOS-G2B pure-Dart privacy session state contract.
// Notes: Rescue-safe access is distinct from an unlocked session.
// ------------------------------------------------------------

enum PrivacySessionState {
  locked,
  rescueSafe,
  authenticating,
  unlocked,
}
