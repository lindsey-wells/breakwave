import 'package:shared_preferences/shared_preferences.dart';

import 'triggers_selection.dart';

class TriggersStore {
  static const String storageKey = 'bw_triggers_selection_v1';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<TriggersSelection> loadSelection() async {
    final prefs = await _prefs();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return TriggersSelection.empty;
    }

    try {
      return TriggersSelection.fromJsonString(raw);
    } catch (_) {
      return TriggersSelection.empty;
    }
  }

  static Future<void> saveSelection(TriggersSelection selection) async {
    final prefs = await _prefs();
    await prefs.setString(storageKey, selection.toJsonString());
  }

  static Future<void> clearSelection() async {
    final prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
