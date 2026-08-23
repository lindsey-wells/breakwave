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
  String replacementAction = '',
}) {
  return LogEntry(
    id: id,
    entryType: entryType,
    intensity: intensity,
    triggers: triggers,
    replacementAction: replacementAction,
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


    test(
      'groups helpful actions case-insensitively across 30 and 90 days',
      () {
        final DateTime now = DateTime(2026, 7, 15, 12);

        final snapshot = calculator.calculate(
          entries: <LogEntry>[
            buildEntry(
              id: 'walk-new',
              occurredAt: now.subtract(const Duration(days: 5)),
              entryType: 'Victory',
              replacementAction: 'Take a Short Walk',
            ),
            buildEntry(
              id: 'walk-recent',
              occurredAt: now.subtract(const Duration(days: 20)),
              entryType: 'Victory',
              replacementAction: 'take a short walk',
            ),
            buildEntry(
              id: 'walk-older',
              occurredAt: now.subtract(const Duration(days: 60)),
              entryType: 'Victory',
              replacementAction: 'TAKE A SHORT WALK',
            ),
            buildEntry(
              id: 'phone-new',
              occurredAt: now.subtract(const Duration(days: 10)),
              entryType: 'Victory',
              replacementAction: 'Put the phone down',
            ),
            buildEntry(
              id: 'phone-older',
              occurredAt: now.subtract(const Duration(days: 40)),
              entryType: 'Victory',
              replacementAction: 'Put the phone down',
            ),
            buildEntry(
              id: 'text',
              occurredAt: now.subtract(const Duration(days: 15)),
              entryType: 'Victory',
              replacementAction: 'Text someone safe',
            ),
            buildEntry(
              id: 'urge-ignored',
              occurredAt: now.subtract(const Duration(days: 2)),
              entryType: 'Urge',
              replacementAction: 'Not a victory action',
            ),
            buildEntry(
              id: 'blank-ignored',
              occurredAt: now.subtract(const Duration(days: 3)),
              entryType: 'Victory',
              replacementAction: '   ',
            ),
            buildEntry(
              id: 'too-old',
              occurredAt: now.subtract(const Duration(days: 91)),
              entryType: 'Victory',
              replacementAction: 'Old action',
            ),
          ],
          now: now,
        );

        expect(snapshot.helpfulActionsOverTime.length, 3);

        final first = snapshot.helpfulActionsOverTime[0];
        expect(first.action, 'Take a Short Walk');
        expect(first.victoryCount30Days, 2);
        expect(first.victoryCount90Days, 3);

        final second = snapshot.helpfulActionsOverTime[1];
        expect(second.action, 'Put the phone down');
        expect(second.victoryCount30Days, 1);
        expect(second.victoryCount90Days, 2);

        final third = snapshot.helpfulActionsOverTime[2];
        expect(third.action, 'Text someone safe');
        expect(third.victoryCount30Days, 1);
        expect(third.victoryCount90Days, 1);
      },
    );

    test('builds adjacent non-overlapping 7-day review windows', () {
      final DateTime now = DateTime(2026, 8, 23, 17, 30);

      final snapshot = calculator.calculate(
        entries: <LogEntry>[
          buildEntry(
            id: 'current-six-days',
            occurredAt: now.subtract(const Duration(days: 6)),
            entryType: 'Victory',
            intensity: 2,
          ),
          buildEntry(
            id: 'current-boundary',
            occurredAt: now.subtract(const Duration(days: 7)),
            entryType: 'Urge',
            intensity: 4,
          ),
          buildEntry(
            id: 'previous-ten-days',
            occurredAt: now.subtract(const Duration(days: 10)),
            entryType: 'Slip',
            intensity: 5,
          ),
          buildEntry(
            id: 'previous-start-boundary',
            occurredAt: now.subtract(const Duration(days: 14)),
            entryType: 'Victory',
            intensity: 1,
          ),
          buildEntry(
            id: 'too-old',
            occurredAt: now.subtract(const Duration(days: 15)),
            entryType: 'Urge',
            intensity: 3,
          ),
        ],
        now: now,
      );

      expect(snapshot.last7Days.total, 2);
      expect(snapshot.last7Days.urges, 1);
      expect(snapshot.last7Days.victories, 1);
      expect(snapshot.last7Days.slips, 0);
      expect(snapshot.last7Days.averageIntensity, 3);

      expect(snapshot.previous7Days.total, 2);
      expect(snapshot.previous7Days.urges, 0);
      expect(snapshot.previous7Days.victories, 1);
      expect(snapshot.previous7Days.slips, 1);
      expect(snapshot.previous7Days.averageIntensity, 3);
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


    test('reflection is supported but excluded from behavioral analytics', () {
      final DateTime now = DateTime(2026, 7, 11, 20);

      final snapshot = calculator.calculate(
        entries: <LogEntry>[
          LogEntry.reflection(
            id: 'reflection',
            triggers: const <String>['Stress'],
            notes: '',
            createdAtIso: now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          ),
          buildEntry(
            id: 'urge',
            occurredAt: now.subtract(const Duration(days: 2)),
            entryType: 'Urge',
            intensity: 4,
            triggers: const <String>['Stress'],
          ),
        ],
        now: now,
      );

      expect(snapshot.reflectionEntryCount, 1);
      expect(snapshot.supportedEntryCount, 2);
      expect(snapshot.validEntryCount, 1);
      expect(snapshot.ignoredEntryCount, 0);
      expect(snapshot.last30Days.total, 1);
      expect(snapshot.last30Days.averageIntensity, 4);
      expect(snapshot.topTriggers30Days.single.trigger, 'Stress');
      expect(snapshot.topTriggers30Days.single.count, 1);
      expect(snapshot.hasEnoughForTimePatterns, isFalse);
    });

    test('operational metadata never becomes a top trigger', () {
      final DateTime now = DateTime(2026, 7, 11, 20);
      const List<String> operational = <String>[
        'Rescue Completion',
        'Wave Timer',
        'Lower Now',
        'Still Strong',
        'Slipped',
      ];

      final snapshot = calculator.calculate(
        entries: List<LogEntry>.generate(
          5,
          (int index) => buildEntry(
            id: 'entry-$index',
            occurredAt: now.subtract(Duration(days: index)),
            triggers: <String>[...operational, 'Stress'],
          ),
        ),
        now: now,
      );

      expect(snapshot.topTriggers30Days.length, 1);
      expect(snapshot.topTriggers30Days.single.trigger, 'Stress');
      expect(snapshot.topTriggers30Days.single.count, 5);
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
      expect(snapshot.helpfulActionsOverTime, isEmpty);
    });
  });
}
