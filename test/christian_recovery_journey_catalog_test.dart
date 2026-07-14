// BreakWave
// BW-87B5A2 Christian recovery journey catalog tests.

import 'package:breakwave/features/faith/domain/christian_recovery_journey.dart';
import 'package:breakwave/features/faith/domain/christian_recovery_journey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog contains six complete Christian journeys', () {
    final List<ChristianRecoveryJourney> journeys =
        ChristianRecoveryJourneyCatalog.journeys;

    expect(journeys.length, 6);

    for (final ChristianRecoveryJourney journey
        in journeys) {
      expect(journey.isUsable, isTrue);
      expect(journey.hasRequiredFlow, isTrue);
      expect(journey.steps.length, 5);

      expect(
        journey.steps
            .map(
              (ChristianJourneyStep step) =>
                  step.kind,
            )
            .toList(),
        <ChristianJourneyStepKind>[
          ChristianJourneyStepKind.scripture,
          ChristianJourneyStepKind.context,
          ChristianJourneyStepKind.reflection,
          ChristianJourneyStepKind.action,
          ChristianJourneyStepKind.prayer,
        ],
      );

      expect(
        journey.steps.first.hasScriptureReference,
        isTrue,
      );

      expect(
        journey.steps[3].hasAction,
        isTrue,
      );
    }
  });

  test('journey and step identifiers are unique', () {
    final Set<String> journeyIds = <String>{};

    for (final ChristianRecoveryJourney journey
        in ChristianRecoveryJourneyCatalog.journeys) {
      expect(journeyIds.add(journey.id), isTrue);

      final Set<String> stepIds = <String>{};

      for (final ChristianJourneyStep step
          in journey.steps) {
        expect(stepIds.add(step.id), isTrue);
      }
    }
  });

  test('catalog prepares Rescue and personal plan actions', () {
    final Set<ChristianJourneyActionTarget> targets =
        <ChristianJourneyActionTarget>{};

    for (final ChristianRecoveryJourney journey
        in ChristianRecoveryJourneyCatalog.journeys) {
      for (final ChristianJourneyStep step
          in journey.steps) {
        if (step.actionTarget != null) {
          targets.add(step.actionTarget!);
        }
      }
    }

    expect(
      targets,
      <ChristianJourneyActionTarget>{
        ChristianJourneyActionTarget.rescue,
        ChristianJourneyActionTarget.personalPlan,
      },
    );
  });

  test('catalog lookup returns the requested journey', () {
    final ChristianRecoveryJourney? journey =
        ChristianRecoveryJourneyCatalog.findById(
      'guard-the-night',
    );

    expect(journey, isNotNull);
    expect(journey!.title, 'Guard the night');

    expect(
      ChristianRecoveryJourneyCatalog.findById(
        'missing-journey',
      ),
      isNull,
    );
  });
}
