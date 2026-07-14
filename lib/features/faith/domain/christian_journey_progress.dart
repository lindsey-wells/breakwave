// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_journey_progress.dart
// Purpose: Durable progress for repeatable Christian journeys.
// Notes: BW-87B5A1 preserves completion history across restarts.
// ------------------------------------------------------------

class ChristianJourneyProgress {
  const ChristianJourneyProgress({
    required this.journeyId,
    required this.currentStepIndex,
    required this.completedStepIds,
    required this.startedAtIso,
    required this.updatedAtIso,
    required this.currentRunCompletedAtIso,
    required this.completionHistoryIso,
  });

  final String journeyId;
  final int currentStepIndex;
  final List<String> completedStepIds;

  final String startedAtIso;
  final String updatedAtIso;
  final String currentRunCompletedAtIso;

  final List<String> completionHistoryIso;

  static ChristianJourneyProgress emptyFor(
    String journeyId,
  ) {
    return ChristianJourneyProgress(
      journeyId: journeyId,
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
      DateTime.tryParse(
        currentRunCompletedAtIso,
      ) !=
      null;

  int get completionCount =>
      completionHistoryIso.length;

  double fractionFor(int totalSteps) {
    if (totalSteps <= 0) {
      return 0;
    }

    final int safeCompleted =
        completedStepIds.length
            .clamp(
              0,
              totalSteps,
            )
            .toInt();

    return safeCompleted / totalSteps;
  }

  ChristianJourneyProgress begin(
    DateTime now,
  ) {
    if (isStarted || isComplete) {
      return this;
    }

    final String nowIso =
        now.toIso8601String();

    return ChristianJourneyProgress(
      journeyId: journeyId,
      currentStepIndex: currentStepIndex,
      completedStepIds: completedStepIds,
      startedAtIso: nowIso,
      updatedAtIso: nowIso,
      currentRunCompletedAtIso: '',
      completionHistoryIso:
          completionHistoryIso,
    );
  }

  ChristianJourneyProgress
      completeCurrentStep({
    required String stepId,
    required int totalSteps,
    required DateTime now,
  }) {
    if (stepId.trim().isEmpty ||
        totalSteps <= 0 ||
        isComplete) {
      return this;
    }

    final String nowIso =
        now.toIso8601String();

    final int safeCurrentIndex =
        currentStepIndex
            .clamp(
              0,
              totalSteps - 1,
            )
            .toInt();

    final List<String> completed =
        List<String>.from(
      completedStepIds,
    );

    if (!completed.contains(stepId)) {
      completed.add(stepId);
    }

    final int nextStepIndex =
        safeCurrentIndex + 1;

    final bool completedRun =
        nextStepIndex >= totalSteps;

    final List<String> history =
        List<String>.from(
      completionHistoryIso,
    );

    if (completedRun) {
      history.add(nowIso);
    }

    return ChristianJourneyProgress(
      journeyId: journeyId,
      currentStepIndex:
          completedRun
              ? totalSteps
              : nextStepIndex,
      completedStepIds:
          List<String>.unmodifiable(
        completed,
      ),
      startedAtIso:
          isStarted
              ? startedAtIso
              : nowIso,
      updatedAtIso: nowIso,
      currentRunCompletedAtIso:
          completedRun ? nowIso : '',
      completionHistoryIso:
          List<String>.unmodifiable(
        history,
      ),
    );
  }

  ChristianJourneyProgress restart(
    DateTime now,
  ) {
    final String nowIso =
        now.toIso8601String();

    return ChristianJourneyProgress(
      journeyId: journeyId,
      currentStepIndex: 0,
      completedStepIds:
          const <String>[],
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
      'journeyId': journeyId,
      'currentStepIndex':
          currentStepIndex,
      'completedStepIds':
          completedStepIds,
      'startedAtIso': startedAtIso,
      'updatedAtIso': updatedAtIso,
      'currentRunCompletedAtIso':
          currentRunCompletedAtIso,
      'completionHistoryIso':
          completionHistoryIso,
    };
  }

  factory ChristianJourneyProgress.fromMap(
    Map<String, dynamic> map,
  ) {
    return ChristianJourneyProgress(
      journeyId:
          (map['journeyId'] ?? '')
              .toString()
              .trim(),
      currentStepIndex: _intValue(
        map['currentStepIndex'],
        0,
      ),
      completedStepIds:
          _normalizedList(
        map['completedStepIds'],
      ),
      startedAtIso:
          (map['startedAtIso'] ?? '')
              .toString()
              .trim(),
      updatedAtIso:
          (map['updatedAtIso'] ?? '')
              .toString()
              .trim(),
      currentRunCompletedAtIso:
          (map['currentRunCompletedAtIso'] ??
                  '')
              .toString()
              .trim(),
      completionHistoryIso:
          _normalizedList(
        map['completionHistoryIso'],
      ),
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

    final List<String> result =
        <String>[];

    final Set<String> seen =
        <String>{};

    for (final dynamic value in values) {
      final String display =
          value.toString().trim();

      if (display.isEmpty ||
          !seen.add(display)) {
        continue;
      }

      result.add(display);
    }

    return List<String>.unmodifiable(
      result,
    );
  }
}
