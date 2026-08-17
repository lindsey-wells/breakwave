import 'package:breakwave/features/log/presentation/widgets/pattern_observation_card.dart';
import 'package:breakwave/features/patterns/domain/pattern_observation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(PatternObservationResult result) {
    return MaterialApp(
      home: Scaffold(
        body: PatternObservationCard(
          result: result,
          minimumBehavioralEntries: 3,
        ),
      ),
    );
  }

  testWidgets('shows calm insufficient-data guidance', (
    WidgetTester tester,
  ) async {
    const PatternObservationResult result = PatternObservationResult(
      observations: <PatternObservation>[],
      behavioralEntryCount: 1,
      hasEnoughData: false,
      windowDays: 30,
    );

    await tester.pumpWidget(host(result));

    expect(find.text('Learn your pattern'), findsOneWidget);
    expect(
      find.textContaining(
        'needs 2 more recent urge, slip, or victory logs',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'not causes, predictions, or diagnoses',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows A2 observations without rewriting them', (
    WidgetTester tester,
  ) async {
    const PatternObservationResult result = PatternObservationResult(
      observations: <PatternObservation>[
        PatternObservation(
          kind: PatternObservationKind.recurringTrigger,
          message:
              'Stress appeared in 4 logged recovery moments in the last 30 days.',
          evidenceCount: 4,
        ),
        PatternObservation(
          kind: PatternObservationKind.timeWindow,
          message:
              'Evening was the most common recorded time window among your logged recovery moments in the last 30 days.',
          evidenceCount: 5,
        ),
        PatternObservation(
          kind: PatternObservationKind.repeatedVictoryAction,
          message:
              'Take a walk was recorded as what worked in 2 victories in the last 30 days.',
          evidenceCount: 2,
        ),
      ],
      behavioralEntryCount: 5,
      hasEnoughData: true,
      windowDays: 30,
    );

    await tester.pumpWidget(host(result));

    expect(
      find.text(
        'Based only on what you recorded in the last 30 days.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Stress appeared in 4 logged recovery moments in the last 30 days.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Evening was the most common recorded time window'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Take a walk was recorded as what worked'),
      findsOneWidget,
    );
  });

  testWidgets('shows neutral no-repetition state when data is sufficient', (
    WidgetTester tester,
  ) async {
    const PatternObservationResult result = PatternObservationResult(
      observations: <PatternObservation>[],
      behavioralEntryCount: 3,
      hasEnoughData: true,
      windowDays: 30,
    );

    await tester.pumpWidget(host(result));

    expect(
      find.textContaining(
        'nothing is repeating strongly enough to call out yet',
      ),
      findsOneWidget,
    );
  });
}
