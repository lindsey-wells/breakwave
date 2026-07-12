// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_routine_progress.dart
// Purpose: Durable progress for a repeatable guided routine.
// Notes: BW-87B4A preserves completion history across restarts.
// ------------------------------------------------------------

class RecoveryRoutineProgress {
  const RecoveryRoutineProgress({
    required this.routineId,
    required this.currentStepIndex,
    required this.completedStepIds,
    required this.startedAtIso,
    required this.updatedAtIso,
    required this.currentRunCompletedAtIso,
    required this.completionHistoryIso,
  });

  final String routineId;
  final int currentStepIndex;
  final List<String> completedStepIds;

  final String startedAtIso;
  final String updatedAtIso;
  final String currentRunCompletedAtIso;

  final List<String> completionHistoryIso;

  static RecoveryRoutineProgress emptyFor(
    String routineId,
  ) {
    return RecoveryRoutineProgress(
      routineId: routineId,
      currentStepIndex: 0,
      completedStepIds: const <String>[],
      startedAtIso: '',
      updatedAtIso: '',
      currentRunCompletedAtIso: '',
      completionHistoryIso: const <String>[],
    );
  }

  bool get isStarted =>
      DateTime.tryParse(startedAtIso) != null;

  bool get isComplete =>
      DateTime.tryParse(currentRunCompletedAtIso) != null;

  int get completionCount =>
      completionHistoryIso.length;

  double fractionFor(int totalSteps) {
    if (totalSteps <= 0) {
      return 0;
    }

    final int safeCompleted =
        completedStepIds.length.clamp(0, totalSteps);

    return safeCompleted / totalSteps;
  }

  RecoveryRoutineProgress begin(DateTime now) {
    if (isStarted || isComplete) {
      return this;
    }

    final String nowIso = now.toIso8601String();

    return RecoveryRoutineProgress(
      routineId: routineId,
      currentStepIndex: currentStepIndex,
      completedStepIds: completedStepIds,
      startedAtIso: nowIso,
      updatedAtIso: nowIso,
      currentRunCompletedAtIso: '',
      completionHistoryIso: completionHistoryIso,
    );
  }

  RecoveryRoutineProgress completeCurrentStep({
    required String stepId,
    required int totalSteps,
    required DateTime now,
  }) {
    if (stepId.trim().isEmpty ||
        totalSteps <= 0 ||
        isComplete) {
      return this;
    }

    final String nowIso = now.toIso8601String();

    final int safeCurrentIndex =
        currentStepIndex.clamp(0, totalSteps - 1);

    final List<String> completed =
        List<String>.from(completedStepIds);

    if (!completed.contains(stepId)) {
      completed.add(stepId);
    }

    final int nextStepIndex =
        safeCurrentIndex + 1;

    final bool completedRun =
        nextStepIndex >= totalSteps;

    final List<String> history =
        List<String>.from(completionHistoryIso);

    if (completedRun) {
      history.add(nowIso);
    }

    return RecoveryRoutineProgress(
      routineId: routineId,
      currentStepIndex:
          completedRun ? totalSteps : nextStepIndex,
      completedStepIds:
          List<String>.unmodifiable(completed),
      startedAtIso:
          isStarted ? startedAtIso : nowIso,
      updatedAtIso: nowIso,
      currentRunCompletedAtIso:
          completedRun ? nowIso : '',
      completionHistoryIso:
          List<String>.unmodifiable(history),
    );
  }

  RecoveryRoutineProgress restart(DateTime now) {
    final String nowIso = now.toIso8601String();

    return RecoveryRoutineProgress(
      routineId: routineId,
      currentStepIndex: 0,
      completedStepIds: const <String>[],
      startedAtIso: nowIso,
      updatedAtIso: nowIso,
      currentRunCompletedAtIso: '',
      completionHistoryIso:
          List<String>.unmodifiable(
        completionHistoryIso,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'routineId': routineId,
      'currentStepIndex': currentStepIndex,
      'completedStepIds': completedStepIds,
      'startedAtIso': startedAtIso,
      'updatedAtIso': updatedAtIso,
      'currentRunCompletedAtIso':
          currentRunCompletedAtIso,
      'completionHistoryIso':
          completionHistoryIso,
    };
  }

  factory RecoveryRoutineProgress.fromMap(
    Map<String, dynamic> map,
  ) {
    return RecoveryRoutineProgress(
      routineId:
          (map['routineId'] ?? '').toString().trim(),
      currentStepIndex: _intValue(
        map['currentStepIndex'],
        0,
      ),
      completedStepIds:
          _normalizedList(map['completedStepIds']),
      startedAtIso:
          (map['startedAtIso'] ?? '').toString().trim(),
      updatedAtIso:
          (map['updatedAtIso'] ?? '').toString().trim(),
      currentRunCompletedAtIso:
          (map['currentRunCompletedAtIso'] ?? '')
              .toString()
              .trim(),
      completionHistoryIso:
          _normalizedList(map['completionHistoryIso']),
    );
  }

  static int _intValue(
    dynamic raw,
    int fallback,
  ) {
    if (raw is int) {
      return raw;
    }

    if (raw is num) {
      return raw.round();
    }

    return int.tryParse(
          (raw ?? '').toString(),
        ) ??
        fallback;
  }

  static List<String> _normalizedList(
    dynamic raw,
  ) {
    final List<dynamic> values =
        raw is List<dynamic>
            ? raw
            : <dynamic>[];

    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    for (final dynamic value in values) {
      final String display =
          value.toString().trim();

      if (display.isEmpty ||
          !seen.add(display)) {
        continue;
      }

      result.add(display);
    }

    return List<String>.unmodifiable(result);
  }
}
