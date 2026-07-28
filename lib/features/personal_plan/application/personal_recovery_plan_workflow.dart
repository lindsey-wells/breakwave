// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_workflow.dart
// Purpose: Refresh and compare Personal Recovery Plan source data.
// Notes: BW-MOD-01D extracts non-UI refresh workflow without behavior changes.
// ------------------------------------------------------------

import '../../../core/reasons/reasons_store.dart';
import '../../../core/support/support_contact_store.dart';
import '../../../core/triggers/triggers_store.dart';
import '../../../core/why/custom_why_store.dart';
import '../../insights/domain/recovery_insights_calculator.dart';
import '../../log/data/log_repository.dart';
import '../domain/personal_recovery_plan.dart';
import '../domain/personal_recovery_plan_prefill.dart';

class PersonalRecoveryPlanWorkflow {
  const PersonalRecoveryPlanWorkflow({
    required PersonalRecoveryPlanPrefill prefill,
    required LogRepository logRepository,
    required RecoveryInsightsCalculator insightsCalculator,
  })  : _prefill = prefill,
        _logRepository = logRepository,
        _insightsCalculator = insightsCalculator;

  final PersonalRecoveryPlanPrefill _prefill;
  final LogRepository _logRepository;
  final RecoveryInsightsCalculator _insightsCalculator;

  String editableSignature(PersonalRecoveryPlan plan) {
    return <String>[
      plan.reasons.join('|').toLowerCase(),
      plan.primaryReason.trim().toLowerCase(),
      plan.triggers.join('|').toLowerCase(),
      plan.dangerWindows.join('|').toLowerCase(),
      plan.redirectActions.join('|').toLowerCase(),
      plan.trustedSupportName.trim().toLowerCase(),
      plan.phoneBoundary.trim(),
      plan.bedtimeStrategy.trim(),
      plan.afterSlipReset.trim(),
      plan.faithSupport.trim(),
    ].join('§');
  }

  String importSourceSignature(PersonalRecoveryPlan plan) {
    return <String>[
      plan.importSchemaVersion.toString(),
      plan.importedReasons.join('|').toLowerCase(),
      plan.importedPrimaryReason.trim().toLowerCase(),
      plan.importedTriggers.join('|').toLowerCase(),
      plan.importedDangerWindows.join('|').toLowerCase(),
      plan.importedTrustedSupportName.trim().toLowerCase(),
    ].join('§');
  }

  bool hasChanges({
    required PersonalRecoveryPlan current,
    required PersonalRecoveryPlan refreshed,
  }) {
    return editableSignature(refreshed) != editableSignature(current) ||
        importSourceSignature(refreshed) != importSourceSignature(current);
  }

  Future<PersonalRecoveryPlan> refreshFromBreakWave(
    PersonalRecoveryPlan current,
  ) async {
    final reasons = await ReasonsStore.loadSelection();
    final triggers = await TriggersStore.loadSelection();
    final contact = await SupportContactStore.loadContact();
    final customWhy = await CustomWhyStore.load();
    final entries = await _logRepository.loadEntries();

    final snapshot = _insightsCalculator.calculate(
      entries: entries,
      now: DateTime.now(),
    );

    final List<String> observedTriggers = snapshot.topTriggers30Days
        .map((item) => item.trigger)
        .where((String value) {
      final String key = value.trim().toLowerCase();

      return key != 'rescue completion' && key != 'wave timer';
    }).toList();

    final List<String> observedDangerWindows = <String>[
      if (snapshot.busiestWeekday30Days != null)
        snapshot.busiestWeekday30Days!,
      if (snapshot.busiestTimeWindow30Days != null)
        snapshot.busiestTimeWindow30Days!,
    ];

    return _prefill.refreshFromCurrentChoices(
      current: current,
      reasonsSelection: reasons,
      triggersSelection: triggers,
      supportContact: contact,
      customWhy: customWhy,
      observedTriggers: observedTriggers,
      observedDangerWindows: observedDangerWindows,
    );
  }
}
