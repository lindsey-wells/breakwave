// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_prefill.dart
// Purpose: Safely prefill empty personal-plan sections.
// Notes: BW-87B3A never overwrites existing plan work.
// ------------------------------------------------------------

import '../../../core/reasons/reasons_selection.dart';
import '../../../core/support/support_contact.dart';
import '../../../core/triggers/triggers_selection.dart';
import '../../../core/why/custom_why_entry.dart';
import 'personal_recovery_plan.dart';

class PersonalRecoveryPlanPrefill {
  const PersonalRecoveryPlanPrefill();

  PersonalRecoveryPlan fillEmptySections({
    required PersonalRecoveryPlan current,
    required ReasonsSelection reasonsSelection,
    required TriggersSelection triggersSelection,
    required SupportContact? supportContact,
    required CustomWhyEntry customWhy,
  }) {
    final String savedFocus =
        reasonsSelection.currentFocus?.trim() ?? '';
    final String savedWhy = customWhy.whyText.trim();

    final String importedPrimaryReason =
        savedFocus.isNotEmpty ? savedFocus : savedWhy;

    return current.copyWith(
      reasons: current.reasons.isEmpty
          ? reasonsSelection.selectedReasons
          : current.reasons,
      primaryReason: current.primaryReason.trim().isEmpty
          ? importedPrimaryReason
          : current.primaryReason,
      triggers: current.triggers.isEmpty
          ? triggersSelection.selectedTriggers
          : current.triggers,
      dangerWindows: current.dangerWindows.isEmpty
          ? triggersSelection.selectedRiskyTimes
          : current.dangerWindows,
      trustedSupportName:
          current.trustedSupportName.trim().isEmpty
              ? (supportContact?.name.trim() ?? '')
              : current.trustedSupportName,
    );
  }
}
