// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_body_test.dart
// Purpose: BW-MOD-01E presentation-body characterization.
// ------------------------------------------------------------

import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/personal_plan/presentation/personal_recovery_plan_draft_controllers.dart';
import 'package:breakwave/features/personal_plan/presentation/widgets/personal_recovery_plan_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PersonalRecoveryPlanDraftControllers controllers;

  setUp(() {
    controllers = PersonalRecoveryPlanDraftControllers(
      onChanged: () {},
    );
  });

  tearDown(() {
    controllers.dispose();
  });

  Widget buildBody({
    bool loading = false,
    String? loadError,
    bool dirty = false,
    bool sourceUpdateAvailable = false,
    bool importing = false,
    bool saving = false,
    bool hasSavedPlan = false,
    RecoveryMode mode = RecoveryMode.secular,
    List<String> confirmedHelpfulActions = const <String>[],
    String? statusMessage,
    VoidCallback? onRetry,
    Future<void> Function()? onRefresh,
    Future<void> Function()? onSave,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PersonalRecoveryPlanBody(
          loading: loading,
          loadError: loadError,
          dirty: dirty,
          sourceUpdateAvailable: sourceUpdateAvailable,
          updatedLabel: 'Not saved yet',
          importing: importing,
          saving: saving,
          hasSavedPlan: hasSavedPlan,
          mode: mode,
          draftControllers: controllers,
          reasonSuggestions: const <String>['Relationships'],
          triggerSuggestions: const <String>['Stress'],
          dangerWindowSuggestions: const <String>['Late night'],
          redirectSuggestions: const <String>['Open Rescue'],
          confirmedHelpfulActions: confirmedHelpfulActions,
          statusMessage: statusMessage,
          onRetry: onRetry ?? () {},
          onRefresh: onRefresh ?? () async {},
          onSave: onSave ?? () async {},
        ),
      ),
    );
  }

  testWidgets(
    'loading state remains a centered progress indicator',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildBody(loading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Build a plan you can actually use'), findsNothing);
    },
  );

  testWidgets(
    'error state preserves retry wording and callback',
    (WidgetTester tester) async {
      int retries = 0;
      await tester.pumpWidget(
        buildBody(
          loadError: 'BreakWave could not load your saved plan.',
          onRetry: () => retries += 1,
        ),
      );

      expect(find.text('Plan unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    },
  );

  testWidgets(
    'secular body preserves refresh and primary plan sections',
    (WidgetTester tester) async {
      int refreshes = 0;
      await tester.pumpWidget(
        buildBody(
          sourceUpdateAvailable: true,
          onRefresh: () async {
            refreshes += 1;
          },
        ),
      );

      expect(
        find.text('New BreakWave choices are available'),
        findsOneWidget,
      );
      expect(
        find.text('Refresh from current BreakWave choices'),
        findsOneWidget,
      );
      expect(find.text('Why I am changing'), findsOneWidget);
      expect(find.text('Faith support'), findsNothing);

      await tester.tap(
        find.text('Refresh from current BreakWave choices'),
      );
      expect(refreshes, 1);
    },
  );

  testWidgets(
    'confirmed helpful actions stay user owned through the body integration',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBody(
          confirmedHelpfulActions: const <String>['Leave the room'],
        ),
      );

      expect(
        controllers.preferredPreparationAction.text,
        isEmpty,
      );

      await tester.scrollUntilVisible(
        find.text('Helpful actions you confirmed'),
        450,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text('Use Leave the room in my plan'),
        findsOneWidget,
      );
      expect(
        controllers.preferredPreparationAction.text,
        isEmpty,
      );

      final Finder useAction = find.text(
        'Use Leave the room in my plan',
      );
      await tester.ensureVisible(useAction);
      await tester.pumpAndSettle();
      await tester.tap(useAction);
      await tester.pump();

      expect(
        controllers.preferredPreparationAction.text,
        'Leave the room',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Christian body exposes faith support and saves through callback',
    (WidgetTester tester) async {
      int saves = 0;
      await tester.pumpWidget(
        buildBody(
          dirty: true,
          mode: RecoveryMode.christian,
          onSave: () async {
            saves += 1;
          },
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Faith support'),
        450,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Faith support'), findsOneWidget);

      final Finder saveButton = find.ancestor(
        of: find.text('Save recovery plan'),
        matching: find.byType(FilledButton),
      );
      expect(saveButton, findsOneWidget);
      await tester.scrollUntilVisible(
        saveButton,
        450,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump();
      expect(saves, 1);
    },
  );

  testWidgets(
    'saved body keeps the save button disabled',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBody(
          hasSavedPlan: true,
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Plan saved'),
        450,
        scrollable: find.byType(Scrollable).first,
      );

      final FilledButton button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Plan saved'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    },
  );
}
