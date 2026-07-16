// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_state.dart
// Purpose: Versioned progress state for guided onboarding.
// Notes: BW-87B6P2 supports safe resume, completion, and skip.
// ------------------------------------------------------------

enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
  skipped;

  String get storageValue => name;

  bool get isTerminal =>
      this == OnboardingStatus.completed ||
      this == OnboardingStatus.skipped;

  static OnboardingStatus? fromStorage(
    String? value,
  ) {
    switch (value) {
      case 'notStarted':
        return OnboardingStatus.notStarted;
      case 'inProgress':
        return OnboardingStatus.inProgress;
      case 'completed':
        return OnboardingStatus.completed;
      case 'skipped':
        return OnboardingStatus.skipped;
      default:
        return null;
    }
  }
}

class OnboardingState {
  const OnboardingState({
    required this.schemaVersion,
    required this.status,
    required this.currentStep,
    required this.migratedLegacyUser,
    required this.updatedAtIso,
  });

  static const int currentSchemaVersion = 1;
  static const int totalSteps = 10;

  final int schemaVersion;
  final OnboardingStatus status;
  final int currentStep;
  final bool migratedLegacyUser;
  final String updatedAtIso;

  bool get shouldShowOnboarding =>
      status == OnboardingStatus.notStarted ||
      status == OnboardingStatus.inProgress;

  bool get isTerminal => status.isTerminal;

  factory OnboardingState.initial({
    DateTime? now,
  }) {
    return OnboardingState(
      schemaVersion: currentSchemaVersion,
      status: OnboardingStatus.notStarted,
      currentStep: 0,
      migratedLegacyUser: false,
      updatedAtIso: _timestamp(now),
    );
  }

  factory OnboardingState.inProgress({
    required int step,
    DateTime? now,
  }) {
    return OnboardingState(
      schemaVersion: currentSchemaVersion,
      status: OnboardingStatus.inProgress,
      currentStep: _clampActiveStep(step),
      migratedLegacyUser: false,
      updatedAtIso: _timestamp(now),
    );
  }

  factory OnboardingState.completed({
    bool migratedLegacyUser = false,
    DateTime? now,
  }) {
    return OnboardingState(
      schemaVersion: currentSchemaVersion,
      status: OnboardingStatus.completed,
      currentStep: totalSteps,
      migratedLegacyUser: migratedLegacyUser,
      updatedAtIso: _timestamp(now),
    );
  }

  factory OnboardingState.skipped({
    DateTime? now,
  }) {
    return OnboardingState(
      schemaVersion: currentSchemaVersion,
      status: OnboardingStatus.skipped,
      currentStep: totalSteps,
      migratedLegacyUser: false,
      updatedAtIso: _timestamp(now),
    );
  }

  factory OnboardingState.fromMap(
    Map<String, dynamic> map,
  ) {
    final OnboardingStatus? parsedStatus =
        OnboardingStatus.fromStorage(
      map['status'] as String?,
    );

    if (parsedStatus == null) {
      throw const FormatException(
        'Unknown onboarding status.',
      );
    }

    final Object? rawVersion =
        map['schemaVersion'];

    final Object? rawStep =
        map['currentStep'];

    final int schemaVersion =
        rawVersion is int ? rawVersion : 0;

    final int parsedStep =
        rawStep is int ? rawStep : 0;

    final int normalizedStep;

    switch (parsedStatus) {
      case OnboardingStatus.notStarted:
        normalizedStep = 0;
        break;
      case OnboardingStatus.inProgress:
        normalizedStep =
            _clampActiveStep(parsedStep);
        break;
      case OnboardingStatus.completed:
      case OnboardingStatus.skipped:
        normalizedStep = totalSteps;
        break;
    }

    final String updatedAtIso =
        (map['updatedAtIso'] as String?)
                ?.trim() ??
            '';

    if (updatedAtIso.isEmpty) {
      throw const FormatException(
        'Missing onboarding update timestamp.',
      );
    }

    return OnboardingState(
      schemaVersion: schemaVersion,
      status: parsedStatus,
      currentStep: normalizedStep,
      migratedLegacyUser:
          map['migratedLegacyUser'] == true,
      updatedAtIso: updatedAtIso,
    );
  }

  OnboardingState copyWith({
    int? schemaVersion,
    OnboardingStatus? status,
    int? currentStep,
    bool? migratedLegacyUser,
    String? updatedAtIso,
  }) {
    return OnboardingState(
      schemaVersion:
          schemaVersion ?? this.schemaVersion,
      status: status ?? this.status,
      currentStep:
          currentStep ?? this.currentStep,
      migratedLegacyUser:
          migratedLegacyUser ??
              this.migratedLegacyUser,
      updatedAtIso:
          updatedAtIso ?? this.updatedAtIso,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'status': status.storageValue,
      'currentStep': currentStep,
      'migratedLegacyUser':
          migratedLegacyUser,
      'updatedAtIso': updatedAtIso,
    };
  }

  static int _clampActiveStep(
    int step,
  ) {
    return step.clamp(
      0,
      totalSteps - 1,
    );
  }

  static String _timestamp(
    DateTime? now,
  ) {
    return (now ?? DateTime.now())
        .toUtc()
        .toIso8601String();
  }
}
