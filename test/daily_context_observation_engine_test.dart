import 'package:breakwave/core/checkin/daily_check_in_entry.dart';
import 'package:breakwave/features/patterns/domain/daily_context_observation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const DailyContextObservationEngine engine =
      DailyContextObservationEngine();
  final DateTime now = DateTime(2026, 8, 17, 12);

  DailyCheckInEntry entry(
    String dateKey,
    String status, {
    String savedAtIso = '2026-08-17T12:00:00.000',
  }) {
    return DailyCheckInEntry(
      dateKey: dateKey,
      status: status,
      savedAtIso: savedAtIso,
    );
  }

  test('requires three recent Daily Check-Ins', () {
    final result = engine.evaluate(
      entries: <DailyCheckInEntry>[
        entry('2026-08-17', 'Vulnerable'),
        entry('2026-08-16', 'Steady'),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isFalse);
    expect(result.hasObservation, isFalse);
    expect(result.checkInCount, 2);
    expect(result.message, contains('1 more recent Daily Check-In'));
  });

  test('reports one dominant repeated status observationally', () {
    final result = engine.evaluate(
      entries: <DailyCheckInEntry>[
        entry('2026-08-17', 'Vulnerable'),
        entry('2026-08-16', 'Steady'),
        entry('2026-08-15', 'vulnerable'),
        entry('2026-08-14', 'Fought through'),
        entry('2026-08-13', 'Vulnerable'),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isTrue);
    expect(result.hasObservation, isTrue);
    expect(result.dominantStatus, 'Vulnerable');
    expect(result.evidenceCount, 3);
    expect(
      result.message,
      'You marked 3 of 5 Daily Check-Ins as Vulnerable in the last 7 days.',
    );
  });

  test('suppresses tied context instead of declaring a pattern', () {
    final result = engine.evaluate(
      entries: <DailyCheckInEntry>[
        entry('2026-08-17', 'Steady'),
        entry('2026-08-16', 'Steady'),
        entry('2026-08-15', 'Vulnerable'),
        entry('2026-08-14', 'Vulnerable'),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isTrue);
    expect(result.hasObservation, isFalse);
    expect(result.dominantStatus, isNull);
    expect(result.message, contains('No single Daily Check-In status'));
  });

  test('uses one latest valid status per date and ignores old or unsupported entries', () {
    final result = engine.evaluate(
      entries: <DailyCheckInEntry>[
        entry(
          '2026-08-17',
          'Steady',
          savedAtIso: '2026-08-17T08:00:00.000',
        ),
        entry(
          '2026-08-17',
          'Vulnerable',
          savedAtIso: '2026-08-17T10:00:00.000',
        ),
        entry('2026-08-16', 'Vulnerable'),
        entry('2026-08-15', 'Vulnerable'),
        entry('2026-08-10', 'Vulnerable'),
        entry('2026-08-14', 'Unknown'),
      ],
      now: now,
    );

    expect(result.checkInCount, 3);
    expect(result.dominantStatus, 'Vulnerable');
    expect(result.evidenceCount, 3);
  });

  test('context wording remains non-causal and non-predictive', () {
    final result = engine.evaluate(
      entries: <DailyCheckInEntry>[
        entry('2026-08-17', 'Slipped'),
        entry('2026-08-16', 'Slipped'),
        entry('2026-08-15', 'Steady'),
      ],
      now: now,
    );

    final String lower = result.message.toLowerCase();
    expect(lower, isNot(contains('because')));
    expect(lower, isNot(contains('causes')));
    expect(lower, isNot(contains('predict')));
    expect(lower, isNot(contains('diagnos')));
  });
}
