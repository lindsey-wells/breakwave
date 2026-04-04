import 'package:shared_preferences/shared_preferences.dart';

import 'reasons_selection.dart';

class ReasonsStore {
  static const String storageKey = 'bw_reasons_selection_v1';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<ReasonsSelection> loadSelection() async {
    final prefs = await _prefs();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return ReasonsSelection.empty;
    }

    try {
      return ReasonsSelection.fromJsonString(raw);
    } catch (_) {
      return ReasonsSelection.empty;
    }
  }

  static Future<void> saveSelection(ReasonsSelection selection) async {
    final prefs = await _prefs();
    await prefs.setString(storageKey, selection.toJsonString());
  }

  static Future<void> clearSelection() async {
    final prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
