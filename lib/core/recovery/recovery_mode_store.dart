// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_mode_store.dart
// Purpose: BW-11/BW-38 recovery mode persistence.
// Notes: Stores the selected recovery mode and notifies listeners on change.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'recovery_mode.dart';

class RecoveryModeStore {
  static const String storageKey = 'bw_recovery_mode_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<RecoveryMode?> loadMode() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);
    return RecoveryMode.fromStorage(raw);
  }

  static Future<void> saveMode(RecoveryMode mode) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, mode.storageValue);
    changes.value += 1;
  }

  static Future<void> clearMode() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
