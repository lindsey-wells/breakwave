// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_routine.dart
// Purpose: Guided recovery routine and step definitions.
// Notes: BW-87B4A keeps actionable routine content separate from UI.
// ------------------------------------------------------------

enum RoutineActionTarget {
  rescue,
  log,
  support,
  personalPlan,
}

class RecoveryRoutineStep {
  const RecoveryRoutineStep({
    required this.id,
    required this.title,
    required this.instruction,
    this.actionTarget,
    this.actionLabel = '',
  });

  final String id;
  final String title;
  final String instruction;

  final RoutineActionTarget? actionTarget;
  final String actionLabel;

  bool get hasAction =>
      actionTarget != null &&
      actionLabel.trim().isNotEmpty;
}

class RecoveryRoutine {
  const RecoveryRoutine({
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
  final List<RecoveryRoutineStep> steps;

  bool get isUsable =>
      id.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      steps.isNotEmpty;
}
