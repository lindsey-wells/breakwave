// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_store.dart
// Purpose: BW-21 support contact persistence.
// Notes: Saves one trusted support contact and notifies listeners on change.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support_contact.dart';

class SupportContactStore {
  static const String storageKey = 'bw_support_contact_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<SupportContact?> loadContact() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final SupportContact contact = SupportContact.fromMap(decoded);
      return contact.isComplete ? contact : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveContact(SupportContact contact) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(contact.toMap()));
    changes.value += 1;
  }

  static Future<void> clearContact() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
