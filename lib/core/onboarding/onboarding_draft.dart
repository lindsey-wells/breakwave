// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_draft.dart
// Purpose: Temporary, versioned answers for guided onboarding.
// Notes: BW-87B6P3A1 stores no contact details or log content.
// ------------------------------------------------------------

import '../recovery/recovery_mode.dart';

enum OnboardingAccessChoice {
  undecided,
  continueFree,
  reviewPlus;

  String get storageValue => name;

  static OnboardingAccessChoice fromStorage(
    String? value,
  ) {
    switch (value) {
      case 'continueFree':
        return OnboardingAccessChoice.continueFree;
      case 'reviewPlus':
        return OnboardingAccessChoice.reviewPlus;
      case 'undecided':
      default:
        return OnboardingAccessChoice.undecided;
    }
  }
}

class OnboardingDraft {
  const OnboardingDraft({
    required this.schemaVersion,
    required this.recoveryMode,
    required this.supportNeeds,
    required this.reasons,
    required this.currentFocus,
    required this.whyText,
    required this.triggers,
    required this.riskyTimes,
    required this.interruptionActions,
    required this.accessChoice,
    required this.updatedAtIso,
  });

  static const int currentSchemaVersion = 1;

  static const OnboardingDraft empty =
      OnboardingDraft(
    schemaVersion: currentSchemaVersion,
    recoveryMode: null,
    supportNeeds: <String>[],
    reasons: <String>[],
    currentFocus: '',
    whyText: '',
    triggers: <String>[],
    riskyTimes: <String>[],
    interruptionActions: <String>[],
    accessChoice:
        OnboardingAccessChoice.undecided,
    updatedAtIso: '',
  );

  final int schemaVersion;
  final RecoveryMode? recoveryMode;

  final List<String> supportNeeds;
  final List<String> reasons;
  final String currentFocus;
  final String whyText;
  final List<String> triggers;
  final List<String> riskyTimes;
  final List<String> interruptionActions;

  final OnboardingAccessChoice accessChoice;
  final String updatedAtIso;

  bool get hasAnyAnswer =>
      recoveryMode != null ||
      supportNeeds.isNotEmpty ||
      reasons.isNotEmpty ||
      currentFocus.isNotEmpty ||
      whyText.isNotEmpty ||
      triggers.isNotEmpty ||
      riskyTimes.isNotEmpty ||
      interruptionActions.isNotEmpty ||
      accessChoice !=
          OnboardingAccessChoice.undecided;

  OnboardingDraft copyWith({
    int? schemaVersion,
    RecoveryMode? recoveryMode,
    bool clearRecoveryMode = false,
    List<String>? supportNeeds,
    List<String>? reasons,
    String? currentFocus,
    String? whyText,
    List<String>? triggers,
    List<String>? riskyTimes,
    List<String>? interruptionActions,
    OnboardingAccessChoice? accessChoice,
    String? updatedAtIso,
  }) {
    return OnboardingDraft(
      schemaVersion:
          schemaVersion ?? this.schemaVersion,
      recoveryMode: clearRecoveryMode
          ? null
          : recoveryMode ?? this.recoveryMode,
      supportNeeds:
          supportNeeds ?? this.supportNeeds,
      reasons: reasons ?? this.reasons,
      currentFocus:
          currentFocus ?? this.currentFocus,
      whyText: whyText ?? this.whyText,
      triggers: triggers ?? this.triggers,
      riskyTimes:
          riskyTimes ?? this.riskyTimes,
      interruptionActions:
          interruptionActions ??
              this.interruptionActions,
      accessChoice:
          accessChoice ?? this.accessChoice,
      updatedAtIso:
          updatedAtIso ?? this.updatedAtIso,
    );
  }

  OnboardingDraft preparedForSave(
    DateTime now,
  ) {
    final OnboardingDraft normalized =
        OnboardingDraft.fromMap(toMap());

    return normalized.copyWith(
      schemaVersion: currentSchemaVersion,
      updatedAtIso:
          now.toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'recoveryMode':
          recoveryMode?.storageValue,
      'supportNeeds': supportNeeds,
      'reasons': reasons,
      'currentFocus': currentFocus,
      'whyText': whyText,
      'triggers': triggers,
      'riskyTimes': riskyTimes,
      'interruptionActions':
          interruptionActions,
      'accessChoice':
          accessChoice.storageValue,
      'updatedAtIso': updatedAtIso,
    };
  }

  factory OnboardingDraft.fromMap(
    Map<String, dynamic> map,
  ) {
    final List<String> reasons =
        _normalizedList(map['reasons']);

    final String requestedFocus =
        _normalizedText(
      map['currentFocus'],
    );

    final String normalizedFocus =
        _resolvedFocus(
      reasons,
      requestedFocus,
    );

    return OnboardingDraft(
      schemaVersion:
          map['schemaVersion'] is int
              ? map['schemaVersion'] as int
              : 0,
      recoveryMode:
          RecoveryMode.fromStorage(
        map['recoveryMode']?.toString(),
      ),
      supportNeeds:
          _normalizedList(
        map['supportNeeds'],
      ),
      reasons: reasons,
      currentFocus: normalizedFocus,
      whyText:
          _normalizedText(map['whyText']),
      triggers:
          _normalizedList(map['triggers']),
      riskyTimes:
          _normalizedList(
        map['riskyTimes'],
      ),
      interruptionActions:
          _normalizedList(
        map['interruptionActions'],
      ),
      accessChoice:
          OnboardingAccessChoice.fromStorage(
        map['accessChoice']?.toString(),
      ),
      updatedAtIso:
          _normalizedText(
        map['updatedAtIso'],
      ),
    );
  }

  static String _resolvedFocus(
    List<String> reasons,
    String requestedFocus,
  ) {
    if (reasons.isEmpty) {
      return '';
    }

    final String requestedKey =
        requestedFocus.toLowerCase();

    for (final String reason in reasons) {
      if (reason.toLowerCase() ==
          requestedKey) {
        return reason;
      }
    }

    return reasons.first;
  }

  static String _normalizedText(
    dynamic raw,
  ) {
    return (raw ?? '').toString().trim();
  }

  static List<String> _normalizedList(
    dynamic raw,
  ) {
    final List<dynamic> values =
        raw is List<dynamic>
            ? raw
            : const <dynamic>[];

    final List<String> result =
        <String>[];

    final Set<String> seen = <String>{};

    for (final dynamic value in values) {
      final String display =
          value.toString().trim();

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
}
