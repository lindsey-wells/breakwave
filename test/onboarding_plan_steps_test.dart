import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/onboarding/onboarding_launch_gate.dart';
import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/core/triggers/triggers_store.dart';
import 'package:breakwave/features/onboarding/presentation/onboarding_flow_screen.dart';
import 'package:breakwave/features/premium/presentation/breakwave_plus_screen.dart';

void main() {
  Widget buildFlow({
    required int initialStep,
    ValueChanged<OnboardingStatus>? onFinished,
    VoidCallback? onReviewPlusRequested,
  }) {
    return MaterialApp(
      home: OnboardingFlowScreen(
        initialStep: initialStep,
        onFinished: onFinished ?? (_) {},
        onReviewPlusRequested: onReviewPlusRequested,
      ),
    );
  }

  Future<void> bringIntoTapZone(
    WidgetTester tester,
    Finder finder,
  ) async {
    final BuildContext targetContext =
        tester.element(finder);

    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.15,
      duration: Duration.zero,
    );

    await tester.pump();
  }

  Future<void> flushDraftWrites(
    WidgetTester tester,
  ) async {
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 300),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  testWidgets(
    'Steps 6 and 7 accept rapid optional selections and write only draft data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildFlow(initialStep: 5),
      );
      await tester.pumpAndSettle();

      final Finder stress = find.byKey(
        const ValueKey<String>('onboarding-trigger-Stress'),
      );
      final Finder scrolling = find.byKey(
        const ValueKey<String>('onboarding-trigger-Scrolling'),
      );

      await bringIntoTapZone(
        tester,
        scrolling,
      );

      await tester.tap(stress);
      await tester.tap(scrolling);
      await flushDraftWrites(tester);

      OnboardingDraft draft =
          await OnboardingDraftStore.load();

      expect(
        draft.triggers,
        containsAll(<String>['Stress', 'Scrolling']),
      );

      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      expect(
        prefs.containsKey(TriggersStore.storageKey),
        isFalse,
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Continue'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 7 of 10'), findsOneWidget);

      final Finder lateNight = find.byKey(
        const ValueKey<String>(
          'onboarding-risky-time-Late night',
        ),
      );

      await bringIntoTapZone(
        tester,
        lateNight,
      );

      await tester.tap(lateNight);
      await flushDraftWrites(tester);

      draft = await OnboardingDraftStore.load();
      expect(draft.riskyTimes, <String>['Late night']);

      prefs = await SharedPreferences.getInstance();
      expect(
        prefs.containsKey(TriggersStore.storageKey),
        isFalse,
      );
    },
  );

  testWidgets(
    'Step 8 keeps actions practical private optional and mode aware',
    (WidgetTester tester) async {
      await OnboardingDraftStore.save(
        OnboardingDraft.empty.copyWith(
          recoveryMode: RecoveryMode.christian,
        ),
      );

      await tester.pumpWidget(
        buildFlow(initialStep: 7),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'onboarding-action-Pray for one minute',
          ),
        ),
        findsOneWidget,
      );

      final Finder openRescue = find.byKey(
        const ValueKey<String>(
          'onboarding-action-Open Rescue',
        ),
      );
      final Finder textSafe = find.byKey(
        const ValueKey<String>(
          'onboarding-action-Text someone safe',
        ),
      );

      await bringIntoTapZone(
        tester,
        textSafe,
      );

      await tester.tap(openRescue);
      await tester.tap(textSafe);
      await flushDraftWrites(tester);

      final OnboardingDraft draft =
          await OnboardingDraftStore.load();

      expect(
        draft.interruptionActions,
        containsAll(<String>[
          'Open Rescue',
          'Text someone safe',
        ]),
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      expect(prefs.containsKey('bw_support_contact_v1'), isFalse);
      expect(prefs.containsKey('bw_premium_state_v1'), isFalse);
    },
  );

  testWidgets(
    'Step 9 separates Current Focus and Personal Why without fabricating data',
    (WidgetTester tester) async {
      await OnboardingDraftStore.save(
        OnboardingDraft.empty.copyWith(
          recoveryMode: RecoveryMode.secular,
          supportNeeds: const <String>[
            'Interrupt urges quickly',
          ],
          reasons: const <String>[
            'I want mental clarity.',
          ],
          currentFocus: 'I want mental clarity.',
          whyText: 'I want to live free of shame.',
          triggers: const <String>['Stress'],
          riskyTimes: const <String>['Late night'],
          interruptionActions: const <String>[
            'Open Rescue',
          ],
        ),
      );

      await tester.pumpWidget(
        buildFlow(initialStep: 8),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your starting plan'), findsOneWidget);
      expect(find.text('Current Focus'), findsOneWidget);
      expect(find.text('Personal Why'), findsOneWidget);
      expect(
        find.text('I want mental clarity.'),
        findsWidgets,
      );
      expect(
        find.text('I want to live free of shame.'),
        findsOneWidget,
      );
      expect(find.textContaining('diagnosis'), findsOneWidget);
      expect(find.textContaining('guarantee'), findsOneWidget);
    },
  );

  testWidgets(
    'Step 10 requires an honest choice and Review Plus routes after completion',
    (WidgetTester tester) async {
      final DateTime now = DateTime.utc(2026, 7, 16, 23, 15);

      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingStateStore.storageKey: jsonEncode(
            <String, dynamic>{
              'schemaVersion': 1,
              'status': 'inProgress',
              'currentStep': 9,
              'migratedLegacyUser': false,
              'updatedAtIso': now.toIso8601String(),
            },
          ),
          OnboardingDraftStore.storageKey: jsonEncode(
            <String, dynamic>{
              'schemaVersion': 1,
              'recoveryMode': 'secular',
              'supportNeeds': <String>[
                'Interrupt urges quickly',
              ],
              'reasons': <String>[
                'I want mental clarity.',
              ],
              'currentFocus': 'I want mental clarity.',
              'whyText': '',
              'triggers': <String>[],
              'riskyTimes': <String>[],
              'interruptionActions': <String>[],
              'accessChoice': 'undecided',
              'updatedAtIso': now.toIso8601String(),
            },
          ),
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingLaunchGate(
            child: Scaffold(
              body: Center(child: Text('APP CHILD')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder finish = find.widgetWithText(
        FilledButton,
        'Finish setup',
      );

      expect(finish, findsOneWidget);
      expect(
        tester.widget<FilledButton>(finish).onPressed,
        isNull,
      );

      final Finder reviewPlus = find.byKey(
        const Key('onboarding-access-review-plus'),
      );

      await bringIntoTapZone(
        tester,
        reviewPlus,
      );

      await tester.tap(reviewPlus);
      await flushDraftWrites(tester);

      expect(
        tester.widget<FilledButton>(finish).onPressed,
        isNotNull,
      );

      await tester.tap(finish);
      await tester.pumpAndSettle();

      expect(find.byType(BreakWavePlusScreen), findsOneWidget);
      expect(
        find.text('BreakWave Plus is in development.'),
        findsOneWidget,
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      expect(prefs.containsKey('bw_premium_state_v1'), isFalse);
      expect(
        (await OnboardingStateStore.load())?.status,
        OnboardingStatus.completed,
      );
      expect(
        prefs.containsKey(OnboardingDraftStore.storageKey),
        isFalse,
      );
    },
  );
}
