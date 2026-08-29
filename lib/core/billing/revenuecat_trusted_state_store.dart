// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_trusted_state_store.dart
// Purpose: Persist only minimal trusted Plus authorization state.
// Notes: No recovery data, raw purchase token, or user profile data.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'revenuecat_entitlement_policy.dart';

abstract class RevenueCatTrustedStateStore {
  const RevenueCatTrustedStateStore();

  Future<RevenueCatTrustedState> read();

  Future<void> write(RevenueCatTrustedState state);
}

class SharedPreferencesRevenueCatTrustedStateStore
    extends RevenueCatTrustedStateStore {
  const SharedPreferencesRevenueCatTrustedStateStore();

  static const String _stateKey =
      'breakwave.billing.revenuecat.trusted_state.v1';

  @override
  Future<RevenueCatTrustedState> read() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? raw = preferences.getString(_stateKey);

    if (raw == null || raw.isEmpty) {
      return const RevenueCatTrustedState.empty();
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'RevenueCat trusted state is not an object.',
      );
    }

    return RevenueCatTrustedState(
      acceptedRequestDateUtc:
          _readUtc(decoded['acceptedRequestMs']),
      authoritativePlus:
          decoded['authoritativePlus'] == true,
      validUntilUtc: _readUtc(decoded['validUntilMs']),
      lastObservedDeviceTimeUtc:
          _readUtc(decoded['lastObservedDeviceMs']),
    );
  }

  @override
  Future<void> write(
    RevenueCatTrustedState state,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final Map<String, Object?> encoded =
        <String, Object?>{
      'acceptedRequestMs':
          state.acceptedRequestDateUtc
              ?.millisecondsSinceEpoch,
      'authoritativePlus': state.authoritativePlus,
      'validUntilMs':
          state.validUntilUtc?.millisecondsSinceEpoch,
      'lastObservedDeviceMs':
          state.lastObservedDeviceTimeUtc
              ?.millisecondsSinceEpoch,
    };

    final bool stored = await preferences.setString(
      _stateKey,
      jsonEncode(encoded),
    );

    if (!stored) {
      throw StateError(
        'RevenueCat trusted state was not persisted.',
      );
    }
  }

  static DateTime? _readUtc(Object? value) {
    if (value is! int) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      value,
      isUtc: true,
    );
  }
}
