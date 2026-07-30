// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry_reflection_data_foundation_test.dart
// Purpose: BW-LOG-01B1 nullable Reflection intensity coverage.
// ------------------------------------------------------------

import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogEntry Reflection data foundation', () {
    test(
      'legacy non-Reflection map without intensity defaults to 3',
      () {
        final LogEntry entry = LogEntry.fromMap(
          <String, dynamic>{
            'id': 'legacy-urge',
            'entryType': 'Urge',
            'triggers': <String>['Stress'],
            'notes': '',
            'createdAtIso': '2026-07-29T22:00:00.000',
          },
        );

        expect(entry.entryType, 'Urge');
        expect(entry.intensity, 3);
        expect(entry.hasIntensity, isTrue);
        expect(entry.isReflection, isFalse);
      },
    );

    test(
      'legacy numeric string intensity remains readable',
      () {
        final LogEntry entry = LogEntry.fromMap(
          <String, dynamic>{
            'id': 'legacy-slip',
            'entryType': 'Slip',
            'intensity': '5',
            'triggers': <String>[],
            'notes': '',
            'createdAtIso': '2026-07-29T22:01:00.000',
          },
        );

        expect(entry.intensity, 5);
      },
    );

    test(
      'Reflection map without intensity stays intensity-free',
      () {
        final LogEntry entry = LogEntry.fromMap(
          <String, dynamic>{
            'id': 'reflection-map',
            'entryType': 'Reflection',
            'triggers': <String>[],
            'notes': 'Noticed a calmer choice.',
            'createdAtIso': '2026-07-29T22:02:00.000',
          },
        );

        expect(entry.isReflection, isTrue);
        expect(entry.hasIntensity, isFalse);
        expect(entry.intensity, isNull);
        expect(entry.toMap()['intensity'], isNull);
      },
    );

    test(
      'Reflection constructor round-trips without fake intensity',
      () {
        const LogEntry original = LogEntry.reflection(
          id: 'reflection-constructor',
          triggers: <String>['Boredom'],
          thought: 'I wanted to escape.',
          notes: 'Paused and noticed the pattern.',
          createdAtIso: '2026-07-29T22:03:00.000',
        );

        final LogEntry restored =
            LogEntry.fromMap(original.toMap());

        expect(restored.entryType, 'Reflection');
        expect(restored.intensity, isNull);
        expect(restored.thought, original.thought);
        expect(restored.notes, original.notes);
      },
    );

    test(
      'non-Reflection null intensity still receives legacy fallback',
      () {
        final LogEntry entry = LogEntry.fromMap(
          <String, dynamic>{
            'id': 'malformed-victory',
            'entryType': 'Victory',
            'intensity': null,
            'triggers': <String>[],
            'notes': '',
            'createdAtIso': '2026-07-29T22:04:00.000',
          },
        );

        expect(entry.intensity, 3);
      },
    );
  });
}
