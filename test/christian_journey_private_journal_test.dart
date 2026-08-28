// BreakWave
// BW-89A12F private Christian journey journal widget tests.

import 'package:breakwave/features/faith/data/christian_journey_progress_store.dart';
import 'package:breakwave/features/faith/domain/christian_journey_progress.dart';
import 'package:breakwave/features/faith/domain/christian_recovery_journey.dart';
import 'package:breakwave/features/faith/presentation/christian_journey_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  const ChristianRecoveryJourney reflectionJourney =
      ChristianRecoveryJourney(
    id: 'journal-widget-test',
    title: 'Journal widget test',
    summary: 'Test journey.',
    whenToUse: 'During tests.',
    estimatedMinutes: 1,
    steps: <ChristianJourneyStep>[
      ChristianJourneyStep(
        id: 'reflection',
        kind: ChristianJourneyStepKind.reflection,
        title: 'Reflect',
        body: 'Notice what matters.',
      ),
    ],
  );

  testWidgets(
    'private journal appears only on Reflection and saves locally',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChristianJourneyPlayerScreen(
            journey: reflectionJourney,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start journey'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('christian-journey-private-journal'),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'not included in Recovery Reports or exports',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(
          const Key('christian-journey-journal-note'),
        ),
        'Remember to listen first.',
      );
      await tester.tap(
        find.byKey(const Key('christian-journal-save')),
      );
      await tester.pumpAndSettle();

      final ChristianJourneyProgress? saved =
          await ChristianJourneyProgressStore.loadFor(
        reflectionJourney.id,
      );

      expect(saved, isNotNull);
      expect(saved!.journalNote, 'Remember to listen first.');
    },
  );

  testWidgets(
    'non-reflection step does not show private journal',
    (WidgetTester tester) async {
      const ChristianRecoveryJourney scriptureJourney =
          ChristianRecoveryJourney(
        id: 'journal-hidden-test',
        title: 'Hidden journal test',
        summary: 'Test journey.',
        whenToUse: 'During tests.',
        estimatedMinutes: 1,
        steps: <ChristianJourneyStep>[
          ChristianJourneyStep(
            id: 'scripture',
            kind: ChristianJourneyStepKind.scripture,
            title: 'Scripture',
            body: 'Read.',
            scriptureReference: 'James 1:19',
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ChristianJourneyPlayerScreen(
            journey: scriptureJourney,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start journey'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('christian-journey-private-journal'),
        ),
        findsNothing,
      );
    },
  );
}
