// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_screen_characterization_test.dart
// Purpose: BW-MOD-01A locks current Personal Recovery Plan screen behavior.
// ------------------------------------------------------------

import 'package:breakwave/core/storage/storage_keys.dart';
import 'package:breakwave/features/personal_plan/data/personal_recovery_plan_store.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/personal_recovery_plan_test_harness.dart';

void main() {
  setUp(resetPersonalPlanTestStorage);

  testWidgets(
    'empty secular plan settles into the local editor',
    (WidgetTester tester) async {
      await pumpPersonalPlan(tester);

      expect(find.text('My recovery plan'), findsOneWidget);
      expect(
        find.text('Build a plan you can actually use'),
        findsOneWidget,
      );
      expect(
        find.text('New BreakWave choices are available'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Your plan stays on this device.'),
        findsOneWidget,
      );
      expect(find.text('Faith support'), findsNothing);
      expect(find.text('Pray for one minute'), findsNothing);
    },
  );

  testWidgets(
    'malformed log storage shows unavailable state and retry recovers',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          BreakWaveStorageKeys.logEntries: <String>[
            'not valid JSON',
          ],
        },
      );

      await pumpPersonalPlan(tester);

      expect(find.text('Plan unavailable'), findsOneWidget);
      expect(
        find.textContaining(
          'BreakWave could not load your saved plan.',
        ),
        findsOneWidget,
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();
      await prefs.remove(BreakWaveStorageKeys.logEntries);

      await tapPlanText(tester, 'Try again');

      expect(
        find.text('Build a plan you can actually use'),
        findsOneWidget,
      );
      expect(find.text('Plan unavailable'), findsNothing);
    },
  );

  testWidgets(
    'saved plan loads into fields and save remains disabled',
    (WidgetTester tester) async {
      const PersonalRecoveryPlan saved =
          PersonalRecoveryPlan(
        reasons: <String>['Relationships'],
        primaryReason: 'I want my life back.',
        triggers: <String>['Stress'],
        dangerWindows: <String>['Late night'],
        redirectActions: <String>['Open Rescue'],
        trustedSupportName: 'Alex',
        phoneBoundary: 'Phone outside the bedroom.',
        bedtimeStrategy: 'Read for ten minutes.',
        afterSlipReset: 'Tell the truth and restart.',
        faithSupport: '',
        createdAtIso: '2026-07-20T10:00:00.000',
        updatedAtIso: '2026-07-20T11:00:00.000',
      );
      await PersonalRecoveryPlanStore.save(saved);

      await pumpPersonalPlan(tester);

      final TextField reasonField = tester.widget<TextField>(
        personalPlanTextField('My main reason'),
      );
      expect(
        reasonField.controller?.text,
        'I want my life back.',
      );

      await scrollToPlanText(tester, 'Plan saved');
      final FilledButton button = tester.widget<FilledButton>(
        filledButtonWithText('Plan saved'),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'empty save is rejected without writing a plan',
    (WidgetTester tester) async {
      await pumpPersonalPlan(tester);
      await tapPlanText(tester, 'Save recovery plan');

      expect(
        find.textContaining(
          'Add at least one useful part of your plan',
        ),
        findsOneWidget,
      );
      expect(
        await PersonalRecoveryPlanStore.load(),
        isNull,
      );
    },
  );

  testWidgets(
    'editing marks the draft dirty and save persists it locally',
    (WidgetTester tester) async {
      await pumpPersonalPlan(tester);

      await tester.enterText(
        personalPlanTextField('My main reason'),
        'I choose honesty and freedom.',
      );
      await tester.pump();

      expect(find.text('Unsaved changes'), findsOneWidget);

      await tapPlanText(tester, 'Save recovery plan');

      expect(
        find.text('Personal recovery plan saved on this device.'),
        findsOneWidget,
      );
      expect(find.text('Plan saved'), findsOneWidget);

      final PersonalRecoveryPlan? stored =
          await PersonalRecoveryPlanStore.load();
      expect(stored, isNotNull);
      expect(
        stored!.primaryReason,
        'I choose honesty and freedom.',
      );
      expect(
        DateTime.tryParse(stored.createdAtIso),
        isNotNull,
      );
      expect(
        DateTime.tryParse(stored.updatedAtIso),
        isNotNull,
      );
    },
  );

  testWidgets(
    'back navigation warns before discarding a dirty draft',
    (WidgetTester tester) async {
      await pumpPersonalPlanOnPushedRoute(tester);

      await tester.enterText(
        personalPlanTextField('My main reason'),
        'Keep this unsaved thought.',
      );
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.text('Discard unsaved changes?'),
        findsOneWidget,
      );
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard changes'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(
              personalPlanTextField('My main reason'),
            )
            .controller
            ?.text,
        'Keep this unsaved thought.',
      );
    },
  );
}
