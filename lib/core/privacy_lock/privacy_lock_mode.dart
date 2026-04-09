// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_mode.dart
// Purpose: BW-41 privacy lock mode enum.
// Notes: Supports no lock, full-app lock, or sensitive-sections lock.
// ------------------------------------------------------------

enum PrivacyLockMode {
  none,
  fullApp,
  sensitiveSections;

  String get storageValue => name;

  String get label {
    switch (this) {
      case PrivacyLockMode.none:
        return 'No lock';
      case PrivacyLockMode.fullApp:
        return 'Lock full app';
      case PrivacyLockMode.sensitiveSections:
        return 'Lock sensitive sections';
    }
  }

  String get description {
    switch (this) {
      case PrivacyLockMode.none:
        return 'BreakWave opens normally with no passcode screen.';
      case PrivacyLockMode.fullApp:
        return 'Require a passcode before anything in BreakWave can be viewed.';
      case PrivacyLockMode.sensitiveSections:
        return 'Keep Rescue reachable, but require a passcode for Log and Support.';
    }
  }

  static PrivacyLockMode fromStorage(String? value) {
    switch (value) {
      case 'fullApp':
        return PrivacyLockMode.fullApp;
      case 'sensitiveSections':
        return PrivacyLockMode.sensitiveSections;
      case 'none':
      default:
        return PrivacyLockMode.none;
    }
  }
}
