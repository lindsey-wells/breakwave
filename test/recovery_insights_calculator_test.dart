// BreakWave
// BW-87B2A recovery insights calculation tests.

import 'package:breakwave/features/insights/domain/recovery_insights_calculator.dart';
import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:flutter_test/flutter_test.dart';

LogEntry buildEntry({
  required String id,
  required DateTime occurredAt,
  String entryType = 'Urge',
  int intensity = 3,
  List<String> triggers = const <String>[],
}) {
  return LogEntry(
    id: id,
    entryType: entryType,
    intensity: intensity,
    triggers: triggers,
    notes: '',
    createdAtIso: occurredAt.toIso8601String(),
  );
}

void main() {
  const RecoveryInsightsCalculator calculator =
      RecoveryInsightsCalculator();

  group('RecoveryInsightsCalculator', () {
    test('calculates truthful 7, 30, and 90 day summaries', () {
      final DateTime now = DateTime(2026, 7, 11, 12);

      final List<LogEntry> entries = <LogEntry>[
        buildEntry(
          id: 'one-day',
          occurredAt: now.subtract(const Duration(days: 1)),
          entryType: 'Urge',
          intensity: 4,
          triggers: const <String>['Stress', 'stress'],
        ),
        buildEntry(
          id: 'three-days',
          occurredAt: now.subtract(const Duration(days: 3)),
          entryType: 'Victory',
          intensity: 2,
          triggers: const <String>['Stress'],
        ),
        buildEntry(
          id: 'ten-days',
          occurredAt: now.subtract(const Duration(days: 10)),
          entryType: 'Slip',
          intensity: 5,
          triggers: const <String>['Boredom'],
        ),
        buildEntry(
          id: 'forty-days',
          occurredAt: now.subtract(const Duration(days: 40)),
          entryType: 'Urge',
          intensity: 3,
          triggers: const <String>['Tired'],
        ),
        buildEntry(
          id: 'one-hundred-days',
          occurredAt: now.subtract(const Duration(days: 100)),
          entryType: 'Urge',
          intensity: 1,
          triggers: const <String>['Environment'],
        ),
        LogEntry(
          id: 'invalid-date',
          entryType: 'Urge',
          intensity: 3,
          triggers: const <String>['Stress'],
          notes: '',
          createdAtIso: 'not-a-date',
        ),
        buildEntry(
          id: 'future',
          occurredAt: now.add(const Duration(hours: 1)),
          entryType: 'Urge',
        ),
        buildEntry(
          id: 'unsupported',
          occurredAt: now.subtract(const Duration(days: 2)),
          entryType: 'Mood',
        ),
      ];

      final snapshot = calculator.calculate(
        entries: entries,
        now: now,
      );

      expect(snapshot.validEntryCount, 5);
      expect(snapshot.ignoredEntryCount, 3);

      expect(snapshot.last7Days.total, 2);
      expect(snapshot.last7Days.urges, 1);
      expect(snapshot.last7Days.victories, 1);
      expect(snapshot.last7Days.slips, 0);
      expect(snapshot.last7Days.averageIntensity, 3);

      expect(snapshot.last30Days.total, 3);
      expect(snapshot.last30Days.urges, 1);
      expect(snapshot.last30Days.victories, 1);
      expect(snapshot.last30Days.slips, 1);
      expect(
        snapshot.last30Days.averageIntensity,
        closeTo(11 / 3, 0.001),
      );

      expect(snapshot.last90Days.total, 4);
      expect(snapshot.last90Days.urges, 2);
      expect(snapshot.last90Days.victories, 1);
      expect(snapshot.last90Days.slips, 1);

      expect(snapshot.topTriggers30Days.first.trigger, 'Stress');
      expect(snapshot.topTriggers30Days.first.count, 2);
      expect(snapshot.topTriggers30Days[1].trigger, 'Boredom');
      expect(snapshot.topTriggers30Days[1].count, 1);
    });

    test('withholds time patterns when fewer than five entries exist', () {
      final DateTime now = DateTime(2026, 7, 11, 20);

      final List<LogEntry> entries = List<LogEntry>.generate(
        4,
        (int index) => buildEntry(
          id: 'entry-$index',
          occurredAt: now.subtract(Duration(days: index)),
        ),
      );

      final snapshot = calculator.calculate(
        entries: entries,
        now: now,
      );

      expect(snapshot.hasEnoughForTimePatterns, isFalse);
      expect(snapshot.busiestWeekday30Days, isNull);
      expect(snapshot.busiestTimeWindow30Days, isNull);
    });

    test('reports a dominant weekday and time window with enough data', () {
      final DateTime now = DateTime(2026, 7, 15, 20);

      final List<LogEntry> entries = <LogEntry>[
        buildEntry(
          id: 'monday-1',
          occurredAt: DateTime(2026, 7, 13, 18),
        ),
        buildEntry(
          id: 'monday-2',
          occurredAt: DateTime(2026, 7, 13, 19),
        ),
        buildEntry(
          id: 'monday-3',
          occurredAt: DateTime(2026, 7, 6, 18),
        ),
        buildEntry(
          id: 'monday-4',
          occurredAt: DateTime(2026, 6, 29, 18),
        ),
        buildEntry(
          id: 'monday-5',
          occurredAt: DateTime(2026, 6, 22, 18),
        ),
      ];

      final snapshot = calculator.calculate(
        entries: entries,
        now: now,
      );

      expect(snapshot.hasEnoughForTimePatterns, isTrue);
      expect(snapshot.busiestWeekday30Days, 'Monday');
      expect(snapshot.busiestTimeWindow30Days, 'Evening');
    });

    test('returns an honest empty snapshot when no valid logs exist', () {
      final snapshot = calculator.calculate(
        entries: const <LogEntry>[],
        now: DateTime(2026, 7, 11),
      );

      expect(snapshot.hasAnyData, isFalse);
      expect(snapshot.validEntryCount, 0);
      expect(snapshot.last7Days.total, 0);
      expect(snapshot.last30Days.total, 0);
      expect(snapshot.last90Days.total, 0);
      expect(snapshot.topTriggers30Days, isEmpty);
    });
  });
}
