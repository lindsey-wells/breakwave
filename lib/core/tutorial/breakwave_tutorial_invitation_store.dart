// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_invitation_store.dart
// Purpose: Persist the one-time post-onboarding tutorial choice.
// Notes: BW-ONBOARD-01B2 never grants access or changes recovery data.
// ------------------------------------------------------------

import 'package:shared_preferences/shared_preferences.dart';

enum BreakWaveTutorialInvitationChoice {
  accepted,
  declined;

  String get storageValue => name;

  static BreakWaveTutorialInvitationChoice? fromStorage(String? value) {
    switch (value) {
      case 'accepted':
        return BreakWaveTutorialInvitationChoice.accepted;
      case 'declined':
        return BreakWaveTutorialInvitationChoice.declined;
      default:
        return null;
    }
  }
}

class BreakWaveTutorialInvitationStore {
  const BreakWaveTutorialInvitationStore._();

  static const String storageKey = 'bw_tutorial_invitation_choice_v1';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<BreakWaveTutorialInvitationChoice?> load() async {
    final SharedPreferences prefs = await _prefs();
    return BreakWaveTutorialInvitationChoice.fromStorage(
      prefs.getString(storageKey),
    );
  }

  static Future<bool> shouldOffer() async {
    return await load() == null;
  }

  static Future<void> save(
    BreakWaveTutorialInvitationChoice choice,
  ) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, choice.storageValue);
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
