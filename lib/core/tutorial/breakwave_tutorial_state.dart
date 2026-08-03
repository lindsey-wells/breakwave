// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_state.dart
// Purpose: Local progress state for the replayable BreakWave tutorial.
// Notes: BW-ONBOARD-01B1 keeps tutorial state separate from onboarding.
// ------------------------------------------------------------

class BreakWaveTutorialState {
  const BreakWaveTutorialState({
    required this.schemaVersion,
    required this.currentStep,
    required this.completed,
    required this.updatedAtIso,
    this.completedAtIso,
  });

  static const int currentSchemaVersion = 1;
  static const int totalSteps = 6;

  final int schemaVersion;
  final int currentStep;
  final bool completed;
  final String updatedAtIso;
  final String? completedAtIso;

  factory BreakWaveTutorialState.initial({
    DateTime? now,
  }) {
    return BreakWaveTutorialState(
      schemaVersion: currentSchemaVersion,
      currentStep: 0,
      completed: false,
      updatedAtIso: (now ?? DateTime.now()).toUtc().toIso8601String(),
    );
  }

  factory BreakWaveTutorialState.fromMap(
    Map<String, dynamic> map,
  ) {
    final int rawStep = map['currentStep'] is int
        ? map['currentStep'] as int
        : 0;
    final int safeStep = rawStep < 0
        ? 0
        : rawStep >= totalSteps
            ? totalSteps - 1
            : rawStep;

    return BreakWaveTutorialState(
      schemaVersion: map['schemaVersion'] is int
          ? map['schemaVersion'] as int
          : currentSchemaVersion,
      currentStep: safeStep,
      completed: map['completed'] == true,
      updatedAtIso: map['updatedAtIso'] is String
          ? map['updatedAtIso'] as String
          : DateTime.now().toUtc().toIso8601String(),
      completedAtIso: map['completedAtIso'] is String
          ? map['completedAtIso'] as String
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'currentStep': currentStep,
      'completed': completed,
      'updatedAtIso': updatedAtIso,
      'completedAtIso': completedAtIso,
    };
  }
}
