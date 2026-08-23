// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_draft_controllers.dart
// Purpose: Own Personal Recovery Plan text controllers and draft mapping.
// Notes: BW-MOD-01C extracts controller lifecycle without changing behavior.
// ------------------------------------------------------------

import 'package:flutter/widgets.dart';

import '../domain/personal_recovery_plan.dart';

class PersonalRecoveryPlanDraftControllers {
  PersonalRecoveryPlanDraftControllers({
    required VoidCallback onChanged,
  }) : _onChanged = onChanged {
    for (final TextEditingController controller in all) {
      controller.addListener(_handleChanged);
    }
  }

  final VoidCallback _onChanged;

  final TextEditingController reasons = TextEditingController();
  final TextEditingController primaryReason = TextEditingController();
  final TextEditingController triggers = TextEditingController();
  final TextEditingController dangerWindows = TextEditingController();
  final TextEditingController redirectActions = TextEditingController();
  final TextEditingController preferredPreparationAction =
      TextEditingController();
  final TextEditingController trustedSupport = TextEditingController();
  final TextEditingController phoneBoundary = TextEditingController();
  final TextEditingController bedtimeStrategy = TextEditingController();
  final TextEditingController afterSlipReset = TextEditingController();
  final TextEditingController faithSupport = TextEditingController();

  PersonalRecoveryPlan _basePlan = PersonalRecoveryPlan.empty;
  bool _suppressChanges = false;

  List<TextEditingController> get all => <TextEditingController>[
        reasons,
        primaryReason,
        triggers,
        dangerWindows,
        redirectActions,
        preferredPreparationAction,
        trustedSupport,
        phoneBoundary,
        bedtimeStrategy,
        afterSlipReset,
        faithSupport,
      ];

  void _handleChanged() {
    if (!_suppressChanges) {
      _onChanged();
    }
  }

  void applyPlan(PersonalRecoveryPlan plan) {
    _suppressChanges = true;

    try {
      _basePlan = plan;
      _writeLines(reasons, plan.reasons);
      primaryReason.text = plan.primaryReason;
      _writeLines(triggers, plan.triggers);
      _writeLines(dangerWindows, plan.dangerWindows);
      _writeLines(redirectActions, plan.redirectActions);
      preferredPreparationAction.text =
          plan.preferredPreparationAction;
      trustedSupport.text = plan.trustedSupportName;
      phoneBoundary.text = plan.phoneBoundary;
      bedtimeStrategy.text = plan.bedtimeStrategy;
      afterSlipReset.text = plan.afterSlipReset;
      faithSupport.text = plan.faithSupport;
    } finally {
      _suppressChanges = false;
    }
  }

  void updateBasePlan(PersonalRecoveryPlan plan) {
    _basePlan = plan;
  }

  PersonalRecoveryPlan currentDraft() {
    return _basePlan.copyWith(
      reasons: _parseLines(reasons.text),
      primaryReason: primaryReason.text.trim(),
      triggers: _parseLines(triggers.text),
      dangerWindows: _parseLines(dangerWindows.text),
      redirectActions: _parseLines(redirectActions.text),
      preferredPreparationAction:
          preferredPreparationAction.text.trim(),
      trustedSupportName: trustedSupport.text.trim(),
      phoneBoundary: phoneBoundary.text.trim(),
      bedtimeStrategy: bedtimeStrategy.text.trim(),
      afterSlipReset: afterSlipReset.text.trim(),
      faithSupport: faithSupport.text.trim(),
    );
  }

  List<String> get redirectActionChoices =>
      _parseLines(redirectActions.text);

  void setPreferredPreparationAction(String value) {
    preferredPreparationAction.text = value.trim();
  }

  void toggleSuggestion(
    TextEditingController controller,
    String value,
  ) {
    final List<String> items = _parseLines(controller.text);
    final int existingIndex = items.indexWhere(
      (String item) =>
          item.toLowerCase() == value.toLowerCase(),
    );

    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    } else {
      items.add(value);
    }

    _writeLines(controller, items);
  }

  List<String> _parseLines(String raw) {
    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    for (final String part in raw.split(RegExp(r'[\n,]'))) {
      final String display = part.trim();
      final String key = display.toLowerCase();

      if (display.isEmpty || !seen.add(key)) {
        continue;
      }

      result.add(display);
    }

    return result;
  }

  void _writeLines(
    TextEditingController controller,
    List<String> values,
  ) {
    controller.text = values.join('\n');
  }

  void dispose() {
    for (final TextEditingController controller in all) {
      controller
        ..removeListener(_handleChanged)
        ..dispose();
    }
  }
}
