import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/privacy_lock/privacy_attempt_state.dart';
import 'package:breakwave/core/privacy_lock/privacy_attempt_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrivacyAttemptStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('missing state loads empty', () async {
      final PrivacyAttemptStore store = PrivacyAttemptStore();

      final PrivacyAttemptState loaded = await store.load();

      expect(loaded.failedAttemptCount, 0);
      expect(loaded.cooldownUntilUtc, isNull);
    });

    test('state survives a new store instance', () async {
      final PrivacyAttemptStore first = PrivacyAttemptStore();
      final DateTime until = DateTime.utc(2026, 9, 13, 12, 5);

      await first.save(
        PrivacyAttemptState(
          failedAttemptCount: 10,
          cooldownUntilUtc: until,
        ),
      );

      final PrivacyAttemptStore second = PrivacyAttemptStore();
      final PrivacyAttemptState loaded = await second.load();

      expect(loaded.failedAttemptCount, 10);
      expect(loaded.cooldownUntilUtc, until);
    });

    test('clear removes persisted attempt state', () async {
      final PrivacyAttemptStore store = PrivacyAttemptStore();
      await store.save(
        PrivacyAttemptState(
          failedAttemptCount: 4,
          cooldownUntilUtc: null,
        ),
      );

      await store.clear();

      final PrivacyAttemptState loaded = await store.load();
      expect(loaded.failedAttemptCount, 0);
      expect(loaded.cooldownUntilUtc, isNull);
    });


    test('incomplete persisted security state fails closed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrivacyAttemptStore.storageKey:
            '{"failedAttemptCount":2,"cooldownUntilUtc":null}',
      });

      final PrivacyAttemptState loaded =
          await PrivacyAttemptStore().load();

      expect(
        loaded.failedAttemptCount,
        PrivacyAttemptStore.defensiveFailureState.failedAttemptCount,
      );
    });
    test('malformed persisted security state fails closed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrivacyAttemptStore.storageKey: '{not-json',
      });

      final PrivacyAttemptState loaded =
          await PrivacyAttemptStore().load();

      expect(
        loaded.failedAttemptCount,
        PrivacyAttemptStore.defensiveFailureState.failedAttemptCount,
      );
    });

    test('persisted payload contains no credential material', () async {
      final PrivacyAttemptStore store = PrivacyAttemptStore();
      await store.save(
        PrivacyAttemptState(
          failedAttemptCount: 2,
          cooldownUntilUtc: DateTime.utc(2026, 9, 13, 12, 5),
        ),
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String raw = prefs.getString(PrivacyAttemptStore.storageKey)!;
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;

      expect(
        decoded.keys.toSet(),
        <String>{
          'failedAttemptCount',
          'cooldownUntilUtc',
          'schemaVersion',
        },
      );
      expect(raw.toLowerCase(), isNot(contains('passcode')));
      expect(raw.toLowerCase(), isNot(contains('verifier')));
      expect(raw.toLowerCase(), isNot(contains('salt')));
    });
  });
}
