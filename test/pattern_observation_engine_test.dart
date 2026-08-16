import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/patterns/domain/pattern_observation.dart';
import 'package:breakwave/features/patterns/domain/pattern_observation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PatternObservationEngine engine =
      PatternObservationEngine();

  LogEntry entry({
    required String id,
    required DateTime occurredAt,
    String entryType = 'Urge',
    int? intensity = 3,
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

  test('requires three recent behavioral logs before observing patterns', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        entry(
          id: '1',
          occurredAt: now.subtract(const Duration(days: 1)),
          triggers: const <String>['Stress'],
        ),
        entry(
          id: '2',
          occurredAt: now.subtract(const Duration(days: 2)),
          triggers: const <String>['Stress'],
        ),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isFalse);
    expect(result.behavioralEntryCount, 2);
    expect(result.observations, isEmpty);
  });

  test('describes a recurring user trigger without counting operational metadata', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        for (int i = 0; i < 4; i++)
          entry(
            id: 'urge-$i',
            occurredAt: now.subtract(Duration(days: i + 1)),
            triggers: const <String>[
              'Stress',
              'stress',
              'Rescue Completion',
              'Wave Timer',
              'Lower Now',
              'Still Strong',
              'Slipped',
            ],
          ),
        LogEntry.reflection(
          id: 'reflection',
          triggers: const <String>['Stress'],
          notes: '',
          createdAtIso:
              now.subtract(const Duration(days: 1)).toIso8601String(),
        ),
      ],
      now: now,
    );

    final PatternObservation trigger = result.observations.firstWhere(
      (PatternObservation item) =>
          item.kind == PatternObservationKind.recurringTrigger,
    );

    expect(trigger.evidenceCount, 4);
    expect(
      trigger.message,
      'Stress appeared in 4 logged recovery moments in the last 30 days.',
    );
  });

  test('reports repeated replacement actions from victories only', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        entry(
          id: 'victory-1',
          occurredAt: now.subtract(const Duration(days: 1)),
          entryType: 'Victory',
          replacementAction: 'Take a walk',
        ),
        entry(
          id: 'victory-2',
          occurredAt: now.subtract(const Duration(days: 2)),
          entryType: 'Victory',
          replacementAction: 'Take a walk',
        ),
        entry(
          id: 'urge',
          occurredAt: now.subtract(const Duration(days: 3)),
          replacementAction: 'Take a walk',
        ),
      ],
      now: now,
    );

    final PatternObservation action = result.observations.firstWhere(
      (PatternObservation item) =>
          item.kind ==
          PatternObservationKind.repeatedVictoryAction,
    );

    expect(action.evidenceCount, 2);
    expect(
      action.message,
      'Take a walk was recorded as what worked in 2 victories '
      'in the last 30 days.',
    );
  });

  test('reuses conservative timing threshold and tie suppression', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        entry(
          id: '1',
          occurredAt: DateTime(2026, 8, 14, 18),
        ),
        entry(
          id: '2',
          occurredAt: DateTime(2026, 8, 13, 19),
        ),
        entry(
          id: '3',
          occurredAt: DateTime(2026, 8, 12, 20),
        ),
        entry(
          id: '4',
          occurredAt: DateTime(2026, 8, 11, 18),
        ),
        entry(
          id: '5',
          occurredAt: DateTime(2026, 8, 10, 10),
        ),
      ],
      now: now,
    );

    final PatternObservation timing = result.observations.firstWhere(
      (PatternObservation item) =>
          item.kind == PatternObservationKind.timeWindow,
    );

    expect(
      timing.message,
      'Evening was the most common recorded time window among your '
      'logged recovery moments in the last 30 days.',
    );
  });

  test('uses deterministic alphabetical tie-break without dominance wording', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        entry(
          id: '1',
          occurredAt: now.subtract(const Duration(days: 1)),
          triggers: const <String>['Stress', 'Boredom'],
        ),
        entry(
          id: '2',
          occurredAt: now.subtract(const Duration(days: 2)),
          triggers: const <String>['Stress', 'Boredom'],
        ),
        entry(
          id: '3',
          occurredAt: now.subtract(const Duration(days: 3)),
        ),
      ],
      now: now,
    );

    expect(
      result.observations.first.message,
      'Boredom appeared in 2 logged recovery moments in the last 30 days.',
    );
  });

  test('ignores future, old, unsupported, and reflection entries', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        entry(
          id: 'recent-1',
          occurredAt: now.subtract(const Duration(days: 1)),
        ),
        entry(
          id: 'recent-2',
          occurredAt: now.subtract(const Duration(days: 2)),
        ),
        entry(
          id: 'recent-3',
          occurredAt: now.subtract(const Duration(days: 3)),
        ),
        entry(
          id: 'future',
          occurredAt: now.add(const Duration(days: 1)),
          triggers: const <String>['Future'],
        ),
        entry(
          id: 'old',
          occurredAt: now.subtract(const Duration(days: 31)),
          triggers: const <String>['Old'],
        ),
        entry(
          id: 'unsupported',
          occurredAt: now.subtract(const Duration(days: 1)),
          entryType: 'Mood',
          triggers: const <String>['Mood'],
        ),
        LogEntry.reflection(
          id: 'reflection',
          triggers: const <String>['Reflection'],
          notes: '',
          createdAtIso:
              now.subtract(const Duration(days: 1)).toIso8601String(),
        ),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isTrue);
    expect(result.behavioralEntryCount, 3);
    expect(
      result.observations.where(
        (PatternObservation item) =>
            item.kind == PatternObservationKind.recurringTrigger,
      ),
      isEmpty,
    );
  });

  test('generated wording remains observational rather than causal or predictive', () {
    final DateTime now = DateTime(2026, 8, 15, 20);

    final PatternObservationResult result = engine.evaluate(
      entries: <LogEntry>[
        for (int i = 0; i < 5; i++)
          entry(
            id: 'victory-$i',
            occurredAt: DateTime(2026, 8, 10 + i, 18),
            entryType: 'Victory',
            triggers: const <String>['Stress'],
            replacementAction: 'Take a walk',
          ),
      ],
      now: now,
    );

    const List<String> forbidden = <String>[
      'because',
      'causes',
      'caused',
      'leads to',
      'likely',
      'predict',
      'diagnos',
      'always',
      'never relapse',
    ];

    for (final PatternObservation observation in result.observations) {
      final String lower = observation.message.toLowerCase();
      for (final String word in forbidden) {
        expect(lower.contains(word), isFalse);
      }
    }
  });
}
