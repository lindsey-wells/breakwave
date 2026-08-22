import 'package:breakwave/core/bedtime/bedtime_mode_entry.dart';
import 'package:breakwave/features/patterns/domain/bedtime_context_observation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BedtimeContextObservationEngine engine =
      BedtimeContextObservationEngine();
  final DateTime now = DateTime(2026, 8, 20, 22);

  BedtimeModeEntry entry(
    String dateKey,
    bool isRisky, {
    String savedAtIso = '2026-08-20T22:00:00.000',
  }) {
    return BedtimeModeEntry(
      dateKey: dateKey,
      isRisky: isRisky,
      savedAtIso: savedAtIso,
    );
  }

  test('requires three recent bedtime check-ins', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry('2026-08-20', true),
        entry('2026-08-19', false),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isFalse);
    expect(result.hasObservation, isFalse);
    expect(result.bedtimeCount, 2);
    expect(
      result.message,
      contains('1 more recent bedtime check-in'),
    );
  });

  test('reports risky bedtime context observationally', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry('2026-08-20', true),
        entry('2026-08-19', false),
        entry('2026-08-18', true),
        entry('2026-08-17', true),
        entry('2026-08-16', false),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isTrue);
    expect(result.hasObservation, isTrue);
    expect(result.riskyCount, 3);
    expect(result.steadyCount, 2);
    expect(
      result.message,
      'You marked 3 of 5 bedtime check-ins as risky in the last 7 days.',
    );
  });

  test('reports steady bedtime context observationally', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry('2026-08-20', false),
        entry('2026-08-19', false),
        entry('2026-08-18', true),
      ],
      now: now,
    );

    expect(result.hasObservation, isTrue);
    expect(
      result.message,
      'You marked 2 of 3 bedtime check-ins as steady in the last 7 days.',
    );
  });

  test('suppresses a tied bedtime observation', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry('2026-08-20', true),
        entry('2026-08-19', true),
        entry('2026-08-18', false),
        entry('2026-08-17', false),
      ],
      now: now,
    );

    expect(result.hasEnoughData, isTrue);
    expect(result.hasObservation, isFalse);
    expect(
      result.message,
      contains('evenly represented'),
    );
  });

  test('uses one latest entry per date and ignores old nights', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry(
          '2026-08-20',
          false,
          savedAtIso: '2026-08-20T20:00:00.000',
        ),
        entry(
          '2026-08-20',
          true,
          savedAtIso: '2026-08-20T22:00:00.000',
        ),
        entry('2026-08-19', true),
        entry('2026-08-18', true),
        entry('2026-08-12', true),
      ],
      now: now,
    );

    expect(result.bedtimeCount, 3);
    expect(result.riskyCount, 3);
    expect(result.hasObservation, isTrue);
  });

  test('wording remains non-causal and non-predictive', () {
    final result = engine.evaluate(
      entries: <BedtimeModeEntry>[
        entry('2026-08-20', true),
        entry('2026-08-19', true),
        entry('2026-08-18', false),
      ],
      now: now,
    );

    final String lower = result.message.toLowerCase();
    expect(lower, isNot(contains('because')));
    expect(lower, isNot(contains('causes')));
    expect(lower, isNot(contains('predict')));
    expect(lower, isNot(contains('diagnos')));
    expect(lower, isNot(contains('likely')));
  });
}
