import 'package:shared_preferences/shared_preferences.dart';

import 'recovery_mode.dart';

class RecoveryModeStore {
  static const String storageKey = 'bw_recovery_mode';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<RecoveryMode?> loadMode() async {
    final prefs = await _prefs();
    final value = prefs.getString(storageKey);
    return RecoveryMode.fromStorage(value);
  }

  static Future<void> saveMode(RecoveryMode mode) async {
    final prefs = await _prefs();
    await prefs.setString(storageKey, mode.storageValue);
  }

  static Future<void> clearMode() async {
    final prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
