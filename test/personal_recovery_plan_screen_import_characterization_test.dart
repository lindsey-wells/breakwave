// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_screen_import_characterization_test.dart
// Purpose: BW-MOD-01A locks import, suggestions, and recovery-mode behavior.
// ------------------------------------------------------------

import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/reasons/reasons_store.dart';
import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/core/recovery/recovery_mode_store.dart';
import 'package:breakwave/core/support/support_contact.dart';
import 'package:breakwave/core/support/support_contact_store.dart';
import 'package:breakwave/core/triggers/triggers_selection.dart';
import 'package:breakwave/core/triggers/triggers_store.dart';
import 'package:breakwave/core/why/custom_why_entry.dart';
import 'package:breakwave/core/why/custom_why_store.dart';
import 'package:breakwave/features/log/data/log_repository.dart';
import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/personal_plan/data/personal_recovery_plan_store.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/personal_recovery_plan_test_harness.dart';

void main() {
  setUp(resetPersonalPlanTestStorage);

  testWidgets(
    'refresh imports current choices and preserves manual plan work',
    (WidgetTester tester) async {
      await PersonalRecoveryPlanStore.save(
        const PersonalRecoveryPlan(
          reasons: <String>[],
          primaryReason: '',
          triggers: <String>[],
          dangerWindows: <String>[],
          redirectActions: <String>[],
          trustedSupportName: '',
          phoneBoundary: 'Keep my phone outside the bedroom.',
          bedtimeStrategy: '',
          afterSlipReset: '',
          faithSupport: '',
          createdAtIso: '2026-07-20T10:00:00.000',
          updatedAtIso: '2026-07-20T10:00:00.000',
        ),
      );
      await ReasonsStore.saveSelection(
        const ReasonsSelection(
          selectedReasons: <String>['Relationships'],
          currentFocus: 'Relationships',
        ),
      );
      await TriggersStore.saveSelection(
        const TriggersSelection(
          selectedTriggers: <String>['Stress'],
          selectedRiskyTimes: <String>['Late night'],
        ),
      );
      await SupportContactStore.saveContact(
        const SupportContact(
          name: 'Alex',
          phoneNumber: '555-0100',
          emailAddress: '',
        ),
      );
      await CustomWhyStore.save(
        const CustomWhyEntry(
          whyText: 'I want my life back.',
          imagePath: '',
        ),
      );
      await const LogRepository().saveEntry(
        LogEntry(
          id: 'characterization-log',
          entryType: 'Urge',
          intensity: 4,
          triggers: const <String>[
            'Environment',
            'Rescue completion',
          ],
          notes: '',
          createdAtIso: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        ),
      );

      await pumpPersonalPlan(tester);

      expect(
        find.text('New BreakWave choices are available'),
        findsOneWidget,
      );

      await tapPlanText(
        tester,
        'Refresh from current BreakWave choices',
      );

      const String refreshMessage =
          'Current BreakWave choices and recent log patterns '
          'were added or refreshed. Custom plan work was preserved. '
          'Review the plan, then save.';
      await scrollToPlanText(tester, refreshMessage);
      expect(find.text(refreshMessage), findsOneWidget);

      await tapPlanText(tester, 'Save recovery plan');

      final PersonalRecoveryPlan? stored =
          await PersonalRecoveryPlanStore.load();
      expect(stored, isNotNull);
      expect(stored!.reasons, contains('Relationships'));
      expect(stored.primaryReason, 'I want my life back.');
      expect(stored.triggers, containsAll(<String>[
        'Stress',
        'Environment',
      ]));
      expect(
        stored.triggers,
        isNot(contains('Rescue completion')),
      );
      expect(stored.dangerWindows, contains('Late night'));
      expect(stored.trustedSupportName, 'Alex');
      expect(
        stored.phoneBoundary,
        'Keep my phone outside the bedroom.',
      );
      expect(stored.importSchemaVersion, 2);
    },
  );

  testWidgets(
    'suggestion chips populate deduplicated saved lists',
    (WidgetTester tester) async {
      await pumpPersonalPlan(tester);

      await scrollToPlanText(tester, 'Relationships');
      await tester.tap(
        find.widgetWithText(FilterChip, 'Relationships'),
      );
      await tester.pump();

      await scrollToPlanText(tester, 'Stress');
      await tester.tap(find.widgetWithText(FilterChip, 'Stress'));
      await tester.pump();

      await tapPlanText(tester, 'Save recovery plan');

      final PersonalRecoveryPlan? stored =
          await PersonalRecoveryPlanStore.load();
      expect(stored, isNotNull);
      expect(stored!.reasons, <String>['Relationships']);
      expect(stored.triggers, <String>['Stress']);
    },
  );

  testWidgets(
    'Christian mode exposes faith support and prayer action',
    (WidgetTester tester) async {
      await RecoveryModeStore.saveMode(
        RecoveryMode.christian,
      );

      await pumpPersonalPlan(tester);

      await scrollToPlanText(tester, 'Pray for one minute');
      expect(
        find.widgetWithText(
          FilterChip,
          'Pray for one minute',
        ),
        findsOneWidget,
      );

      await scrollToPlanText(tester, 'Faith support');
      expect(find.text('Faith support'), findsOneWidget);
    },
  );
}
