import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/privacy_attempt_state.dart';

void main() {
  group('PrivacyAttemptState', () {
    test('empty contains only non-secret default attempt state', () {
      expect(PrivacyAttemptState.empty.failedAttemptCount, 0);
      expect(PrivacyAttemptState.empty.cooldownUntilUtc, isNull);
      expect(
        PrivacyAttemptState.empty.schemaVersion,
        PrivacyAttemptState.currentSchemaVersion,
      );
    });

    test('serializes only count cooldown and schema metadata', () {
      final DateTime until = DateTime.utc(2026, 9, 13, 12, 5);
      final PrivacyAttemptState state = PrivacyAttemptState(
        failedAttemptCount: 7,
        cooldownUntilUtc: until,
      );

      final Map<String, dynamic> encoded = state.toMap();

      expect(
        encoded.keys.toSet(),
        <String>{
          'failedAttemptCount',
          'cooldownUntilUtc',
          'schemaVersion',
        },
      );
      expect(encoded['failedAttemptCount'], 7);
      expect(encoded['cooldownUntilUtc'], until.toIso8601String());
    });

    test('round trip normalizes cooldown to UTC', () {
      final PrivacyAttemptState decoded = PrivacyAttemptState.fromMap(
        <String, dynamic>{
          'failedAttemptCount': 3,
          'cooldownUntilUtc': '2026-09-13T08:05:00-04:00',
          'schemaVersion': 1,
        },
      );

      expect(decoded.failedAttemptCount, 3);
      expect(decoded.cooldownUntilUtc, DateTime.utc(2026, 9, 13, 12, 5));
      expect(decoded.cooldownUntilUtc?.isUtc, isTrue);
    });

    test('cooldown check is based on absolute UTC time', () {
      final PrivacyAttemptState state = PrivacyAttemptState(
        failedAttemptCount: 10,
        cooldownUntilUtc: DateTime.utc(2026, 9, 13, 12, 5),
      );

      expect(
        state.isCoolingDownAt(DateTime.utc(2026, 9, 13, 12, 4, 59)),
        isTrue,
      );
      expect(
        state.isCoolingDownAt(DateTime.utc(2026, 9, 13, 12, 5)),
        isFalse,
      );
    });
  });
}
