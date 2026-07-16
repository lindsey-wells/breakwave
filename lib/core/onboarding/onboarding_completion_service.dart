// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_completion_service.dart
// Purpose: Merge completed onboarding answers into real stores.
// Notes: BW-87B6P3A2 is retry-safe and never grants Plus.
// ------------------------------------------------------------

import '../reasons/reasons_selection.dart';
import '../reasons/reasons_store.dart';
import '../recovery/recovery_mode_store.dart';
import '../support/support_contact_store.dart';
import '../triggers/triggers_selection.dart';
import '../triggers/triggers_store.dart';
import '../why/custom_why_entry.dart';
import '../why/custom_why_store.dart';
import '../../features/personal_plan/data/personal_recovery_plan_store.dart';
import '../../features/personal_plan/domain/personal_recovery_plan.dart';
import '../../features/personal_plan/domain/personal_recovery_plan_prefill.dart';
import 'onboarding_draft.dart';
import 'onboarding_draft_store.dart';
import 'onboarding_state_store.dart';

class OnboardingCompletionResult {
  const OnboardingCompletionResult({
    required this.shouldReviewPlus,
    required this.savedRecoveryMode,
    required this.savedReasons,
    required this.savedTriggers,
    required this.savedWhy,
    required this.savedPersonalPlan,
  });

  final bool shouldReviewPlus;
  final bool savedRecoveryMode;
  final bool savedReasons;
  final bool savedTriggers;
  final bool savedWhy;
  final bool savedPersonalPlan;
}

class OnboardingCompletionService {
  const OnboardingCompletionService();

  Future<OnboardingCompletionResult> complete({
    OnboardingDraft? draft,
    DateTime? now,
  }) async {
    final DateTime effectiveNow =
        now ?? DateTime.now();

    final OnboardingDraft activeDraft =
        draft ??
        await OnboardingDraftStore.load(
          now: effectiveNow,
        );

    bool savedRecoveryMode = false;
    bool savedReasons = false;
    bool savedTriggers = false;
    bool savedWhy = false;
    bool savedPersonalPlan = false;

    if (activeDraft.recoveryMode != null) {
      await RecoveryModeStore.saveMode(
        activeDraft.recoveryMode!,
      );

      savedRecoveryMode = true;
    }

    ReasonsSelection reasonsSelection =
        await ReasonsStore.loadSelection();

    if (activeDraft.reasons.isNotEmpty ||
        activeDraft.currentFocus.isNotEmpty) {
      reasonsSelection = _mergeReasons(
        existing: reasonsSelection,
        draft: activeDraft,
      );

      await ReasonsStore.saveSelection(
        reasonsSelection,
      );

      savedReasons = true;
    }

    TriggersSelection triggersSelection =
        await TriggersStore.loadSelection();

    if (activeDraft.triggers.isNotEmpty ||
        activeDraft.riskyTimes.isNotEmpty) {
      triggersSelection = TriggersSelection(
        selectedTriggers: _mergeLists(
          triggersSelection.selectedTriggers,
          activeDraft.triggers,
        ),
        selectedRiskyTimes: _mergeLists(
          triggersSelection.selectedRiskyTimes,
          activeDraft.riskyTimes,
        ),
      );

      await TriggersStore.saveSelection(
        triggersSelection,
      );

      savedTriggers = true;
    }

    CustomWhyEntry customWhy =
        await CustomWhyStore.load();

    if (activeDraft.whyText.isNotEmpty &&
        customWhy.whyText.trim().isEmpty) {
      customWhy = CustomWhyEntry(
        whyText: activeDraft.whyText,
        imagePath: customWhy.imagePath,
      );

      await CustomWhyStore.save(customWhy);
      savedWhy = true;
    }

    final bool hasPlanInput =
        activeDraft.reasons.isNotEmpty ||
        activeDraft.currentFocus.isNotEmpty ||
        activeDraft.whyText.isNotEmpty ||
        activeDraft.triggers.isNotEmpty ||
        activeDraft.riskyTimes.isNotEmpty ||
        activeDraft
            .interruptionActions
            .isNotEmpty;

    if (hasPlanInput) {
      final PersonalRecoveryPlan? existingPlan =
          await PersonalRecoveryPlanStore.load();

      final PersonalRecoveryPlanPrefill prefill =
          const PersonalRecoveryPlanPrefill();

      PersonalRecoveryPlan nextPlan =
          prefill.fillEmptySections(
        current:
            existingPlan ??
            PersonalRecoveryPlan.empty,
        reasonsSelection: reasonsSelection,
        triggersSelection: triggersSelection,
        supportContact:
            await SupportContactStore.loadContact(),
        customWhy: customWhy,
      );

      if (nextPlan.redirectActions.isEmpty &&
          activeDraft
              .interruptionActions
              .isNotEmpty) {
        nextPlan = nextPlan.copyWith(
          redirectActions:
              activeDraft.interruptionActions,
        );
      }

      if (existingPlan == null) {
        final String importedPrimaryReason =
            customWhy.whyText.trim().isNotEmpty
                ? customWhy.whyText.trim()
                : reasonsSelection
                        .currentFocus
                        ?.trim() ??
                    '';

        nextPlan = nextPlan.copyWith(
          importedReasons:
              reasonsSelection.selectedReasons,
          importedPrimaryReason:
              importedPrimaryReason,
          importedTriggers:
              triggersSelection.selectedTriggers,
          importedDangerWindows:
              triggersSelection.selectedRiskyTimes,
          importedTrustedSupportName:
              nextPlan.trustedSupportName,
          importSchemaVersion:
              PersonalRecoveryPlanPrefill
                  .currentImportSchemaVersion,
        );
      }

      final PersonalRecoveryPlan prepared =
          nextPlan.preparedForSave(
        effectiveNow,
      );

      if (prepared.hasAnyContent) {
        await PersonalRecoveryPlanStore.save(
          prepared,
        );

        savedPersonalPlan = true;
      }
    }

    // Completion is written only after every requested
    // real-data merge succeeds. Retrying is safe because
    // list merges are deduplicated and text fields fill
    // only when the corresponding saved field is blank.
    await OnboardingStateStore.complete(
      now: effectiveNow,
    );

    await OnboardingDraftStore.clear();

    return OnboardingCompletionResult(
      shouldReviewPlus:
          activeDraft.accessChoice ==
          OnboardingAccessChoice.reviewPlus,
      savedRecoveryMode: savedRecoveryMode,
      savedReasons: savedReasons,
      savedTriggers: savedTriggers,
      savedWhy: savedWhy,
      savedPersonalPlan: savedPersonalPlan,
    );
  }

  Future<void> skip({
    DateTime? now,
  }) async {
    // Skipping changes only onboarding bookkeeping.
    // Existing recovery data is never cleared.
    await OnboardingStateStore.skip(
      now: now,
    );

    await OnboardingDraftStore.clear();
  }

  ReasonsSelection _mergeReasons({
    required ReasonsSelection existing,
    required OnboardingDraft draft,
  }) {
    final List<String> mergedReasons =
        _mergeLists(
      existing.selectedReasons,
      draft.reasons,
    );

    final String? draftFocus =
        _canonicalValue(
      mergedReasons,
      draft.currentFocus,
    );

    final String? existingFocus =
        _canonicalValue(
      mergedReasons,
      existing.currentFocus ?? '',
    );

    final String? resolvedFocus =
        draftFocus ??
        existingFocus ??
        (mergedReasons.isEmpty
            ? null
            : mergedReasons.first);

    return ReasonsSelection(
      selectedReasons: mergedReasons,
      currentFocus: resolvedFocus,
    );
  }

  List<String> _mergeLists(
    List<String> existing,
    List<String> incoming,
  ) {
    final List<String> result =
        <String>[];

    final Set<String> seen = <String>{};

    for (final String raw in <String>[
      ...existing,
      ...incoming,
    ]) {
      final String display = raw.trim();
      final String key =
          display.toLowerCase();

      if (display.isEmpty ||
          !seen.add(key)) {
        continue;
      }

      result.add(display);
    }

    return List<String>.unmodifiable(
      result,
    );
  }

  String? _canonicalValue(
    List<String> values,
    String requested,
  ) {
    final String key =
        requested.trim().toLowerCase();

    if (key.isEmpty) return null;

    for (final String value in values) {
      if (value.toLowerCase() == key) {
        return value;
      }
    }

    return null;
  }
}
