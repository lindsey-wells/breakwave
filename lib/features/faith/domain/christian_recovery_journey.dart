// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_recovery_journey.dart
// Purpose: Structured Christian recovery journey definitions.
// Notes: BW-87B5A1 supports Scripture, context, reflection,
// practical action, and prayer as distinct guided steps.
// ------------------------------------------------------------

enum ChristianJourneyStepKind {
  scripture,
  context,
  reflection,
  action,
  prayer,
}

enum ChristianJourneyActionTarget {
  rescue,
  personalPlan,
}

class ChristianJourneyStep {
  const ChristianJourneyStep({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.scriptureReference = '',
    this.actionTarget,
    this.actionLabel = '',
  });

  final String id;
  final ChristianJourneyStepKind kind;
  final String title;
  final String body;
  final String scriptureReference;

  final ChristianJourneyActionTarget? actionTarget;
  final String actionLabel;

  bool get hasScriptureReference =>
      scriptureReference.trim().isNotEmpty;

  bool get hasAction =>
      actionTarget != null &&
      actionLabel.trim().isNotEmpty;
}

class ChristianRecoveryJourney {
  const ChristianRecoveryJourney({
    required this.id,
    required this.title,
    required this.summary,
    required this.whenToUse,
    required this.estimatedMinutes,
    required this.steps,
  });

  final String id;
  final String title;
  final String summary;
  final String whenToUse;
  final int estimatedMinutes;
  final List<ChristianJourneyStep> steps;

  bool get isUsable =>
      id.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      estimatedMinutes > 0 &&
      steps.isNotEmpty;

  bool get hasRequiredFlow {
    final Set<ChristianJourneyStepKind> kinds =
        steps
            .map(
              (ChristianJourneyStep step) =>
                  step.kind,
            )
            .toSet();

    return kinds.contains(
          ChristianJourneyStepKind.scripture,
        ) &&
        kinds.contains(
          ChristianJourneyStepKind.context,
        ) &&
        kinds.contains(
          ChristianJourneyStepKind.reflection,
        ) &&
        kinds.contains(
          ChristianJourneyStepKind.action,
        ) &&
        kinds.contains(
          ChristianJourneyStepKind.prayer,
        );
  }
}
