// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_prefill.dart
// Purpose: Safely import and refresh personal-plan sections.
// Notes: BW-87B3B1 refreshes imported values without replacing manual work.
// Notes: BW-87B3B2 maps saved Why to the main reason and migrates legacy scalar imports.
// Notes: BW-87B3B3 migrates plans created before import schema v2.
// ------------------------------------------------------------

import '../../../core/reasons/reasons_selection.dart';
import '../../../core/support/support_contact.dart';
import '../../../core/triggers/triggers_selection.dart';
import '../../../core/why/custom_why_entry.dart';
import 'personal_recovery_plan.dart';

class PersonalRecoveryPlanPrefill {
  const PersonalRecoveryPlanPrefill();

  static const int currentImportSchemaVersion = 2;

  PersonalRecoveryPlan fillEmptySections({
    required PersonalRecoveryPlan current,
    required ReasonsSelection reasonsSelection,
    required TriggersSelection triggersSelection,
    required SupportContact? supportContact,
    required CustomWhyEntry customWhy,
  }) {
    final String savedFocus =
        reasonsSelection.currentFocus?.trim() ?? '';
    final String savedWhy =
        customWhy.whyText.trim();

    return current.copyWith(
      reasons: current.reasons.isEmpty
          ? reasonsSelection.selectedReasons
          : current.reasons,
      primaryReason:
          current.primaryReason.trim().isEmpty
              ? (savedWhy.isNotEmpty
                  ? savedWhy
                  : savedFocus)
              : current.primaryReason,
      triggers: current.triggers.isEmpty
          ? triggersSelection.selectedTriggers
          : current.triggers,
      dangerWindows:
          current.dangerWindows.isEmpty
              ? triggersSelection.selectedRiskyTimes
              : current.dangerWindows,
      trustedSupportName:
          current.trustedSupportName.trim().isEmpty
              ? (supportContact?.name.trim() ?? '')
              : current.trustedSupportName,
    );
  }

  PersonalRecoveryPlan refreshFromCurrentChoices({
    required PersonalRecoveryPlan current,
    required ReasonsSelection reasonsSelection,
    required TriggersSelection triggersSelection,
    required SupportContact? supportContact,
    required CustomWhyEntry customWhy,
    List<String> observedTriggers =
        const <String>[],
    List<String> observedDangerWindows =
        const <String>[],
  }) {
    final String savedWhy =
        customWhy.whyText.trim();
    final String savedFocus =
        reasonsSelection.currentFocus?.trim() ?? '';

    final List<String> importedReasons =
        _dedupe(
      reasonsSelection.selectedReasons,
    );

    final String importedPrimaryReason =
        savedWhy.isNotEmpty
            ? savedWhy
            : savedFocus;

    final List<String> importedTriggers =
        _dedupe(<String>[
      ...triggersSelection.selectedTriggers,
      ...observedTriggers,
    ]);

    final List<String> importedDangerWindows =
        _dedupe(<String>[
      ...triggersSelection.selectedRiskyTimes,
      ...observedDangerWindows,
    ]);

    final String importedSupportName =
        supportContact?.name.trim() ?? '';

    final bool requiresLegacyMigration =
        current.importSchemaVersion <
            currentImportSchemaVersion;

    return current.copyWith(
      reasons: _refreshList(
        current: current.reasons,
        previousImported:
            current.importedReasons,
        nextImported: importedReasons,
      ),
      primaryReason: _refreshText(
        current: current.primaryReason,
        previousImported:
            current.importedPrimaryReason,
        nextImported: importedPrimaryReason,
        forceSourceRefresh:
            requiresLegacyMigration,
      ),
      triggers: _refreshList(
        current: current.triggers,
        previousImported:
            current.importedTriggers,
        nextImported: importedTriggers,
      ),
      dangerWindows: _refreshList(
        current: current.dangerWindows,
        previousImported:
            current.importedDangerWindows,
        nextImported: importedDangerWindows,
      ),
      trustedSupportName: _refreshText(
        current: current.trustedSupportName,
        previousImported:
            current.importedTrustedSupportName,
        nextImported: importedSupportName,
        forceSourceRefresh:
            requiresLegacyMigration,
      ),
      importedReasons: importedReasons,
      importedPrimaryReason:
          importedPrimaryReason,
      importedTriggers: importedTriggers,
      importedDangerWindows:
          importedDangerWindows,
      importedTrustedSupportName:
          importedSupportName,
      importSchemaVersion:
          currentImportSchemaVersion,
    );
  }

  String _refreshText({
    required String current,
    required String previousImported,
    required String nextImported,
    bool forceSourceRefresh = false,
  }) {
    final String currentTrimmed = current.trim();
    final String previousTrimmed =
        previousImported.trim();
    final String nextTrimmed = nextImported.trim();

    if (forceSourceRefresh) {
      return nextImported;
    }

    if (previousTrimmed.isEmpty) {
      return nextTrimmed.isNotEmpty
          ? nextImported
          : current;
    }

    if (currentTrimmed.isEmpty ||
        _sameText(
          currentTrimmed,
          previousImported,
        )) {
      return nextImported;
    }

    return current;
  }

  List<String> _refreshList({
    required List<String> current,
    required List<String> previousImported,
    required List<String> nextImported,
  }) {
    final Set<String> previousKeys =
        previousImported
            .map(
              (String value) =>
                  value.trim().toLowerCase(),
            )
            .where((String value) => value.isNotEmpty)
            .toSet();

    final List<String> manualItems =
        current.where((String value) {
      return !previousKeys.contains(
        value.trim().toLowerCase(),
      );
    }).toList();

    return _dedupe(<String>[
      ...manualItems,
      ...nextImported,
    ]);
  }

  List<String> _dedupe(List<String> values) {
    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    for (final String raw in values) {
      final String display = raw.trim();
      final String key = display.toLowerCase();

      if (display.isEmpty || !seen.add(key)) {
        continue;
      }

      result.add(display);
    }

    return List<String>.unmodifiable(result);
  }

  bool _sameText(String first, String second) {
    return first.trim().toLowerCase() ==
        second.trim().toLowerCase();
  }
}
