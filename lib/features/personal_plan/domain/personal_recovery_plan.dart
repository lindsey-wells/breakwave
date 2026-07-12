// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan.dart
// Purpose: Saved longer-term personal recovery plan model.
// Notes: BW-87B3A stores concise, user-controlled recovery planning.
// Notes: BW-87B3B1 tracks imported values so they can refresh safely.
// ------------------------------------------------------------

class PersonalRecoveryPlan {
  const PersonalRecoveryPlan({
    required this.reasons,
    required this.primaryReason,
    required this.triggers,
    required this.dangerWindows,
    required this.redirectActions,
    required this.trustedSupportName,
    required this.phoneBoundary,
    required this.bedtimeStrategy,
    required this.afterSlipReset,
    required this.faithSupport,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.importedReasons = const <String>[],
    this.importedPrimaryReason = '',
    this.importedTriggers = const <String>[],
    this.importedDangerWindows = const <String>[],
    this.importedTrustedSupportName = '',
  });

  final List<String> reasons;
  final String primaryReason;
  final List<String> triggers;
  final List<String> dangerWindows;
  final List<String> redirectActions;
  final String trustedSupportName;
  final String phoneBoundary;
  final String bedtimeStrategy;
  final String afterSlipReset;
  final String faithSupport;
  final String createdAtIso;
  final String updatedAtIso;

  final List<String> importedReasons;
  final String importedPrimaryReason;
  final List<String> importedTriggers;
  final List<String> importedDangerWindows;
  final String importedTrustedSupportName;

  static const PersonalRecoveryPlan empty =
      PersonalRecoveryPlan(
    reasons: <String>[],
    primaryReason: '',
    triggers: <String>[],
    dangerWindows: <String>[],
    redirectActions: <String>[],
    trustedSupportName: '',
    phoneBoundary: '',
    bedtimeStrategy: '',
    afterSlipReset: '',
    faithSupport: '',
    createdAtIso: '',
    updatedAtIso: '',
  );

  bool get hasAnyContent =>
      reasons.isNotEmpty ||
      primaryReason.trim().isNotEmpty ||
      triggers.isNotEmpty ||
      dangerWindows.isNotEmpty ||
      redirectActions.isNotEmpty ||
      trustedSupportName.trim().isNotEmpty ||
      phoneBoundary.trim().isNotEmpty ||
      bedtimeStrategy.trim().isNotEmpty ||
      afterSlipReset.trim().isNotEmpty ||
      faithSupport.trim().isNotEmpty;

  PersonalRecoveryPlan copyWith({
    List<String>? reasons,
    String? primaryReason,
    List<String>? triggers,
    List<String>? dangerWindows,
    List<String>? redirectActions,
    String? trustedSupportName,
    String? phoneBoundary,
    String? bedtimeStrategy,
    String? afterSlipReset,
    String? faithSupport,
    String? createdAtIso,
    String? updatedAtIso,
    List<String>? importedReasons,
    String? importedPrimaryReason,
    List<String>? importedTriggers,
    List<String>? importedDangerWindows,
    String? importedTrustedSupportName,
  }) {
    return PersonalRecoveryPlan(
      reasons: reasons ?? this.reasons,
      primaryReason:
          primaryReason ?? this.primaryReason,
      triggers: triggers ?? this.triggers,
      dangerWindows:
          dangerWindows ?? this.dangerWindows,
      redirectActions:
          redirectActions ?? this.redirectActions,
      trustedSupportName:
          trustedSupportName ??
              this.trustedSupportName,
      phoneBoundary:
          phoneBoundary ?? this.phoneBoundary,
      bedtimeStrategy:
          bedtimeStrategy ?? this.bedtimeStrategy,
      afterSlipReset:
          afterSlipReset ?? this.afterSlipReset,
      faithSupport:
          faithSupport ?? this.faithSupport,
      createdAtIso:
          createdAtIso ?? this.createdAtIso,
      updatedAtIso:
          updatedAtIso ?? this.updatedAtIso,
      importedReasons:
          importedReasons ?? this.importedReasons,
      importedPrimaryReason:
          importedPrimaryReason ??
              this.importedPrimaryReason,
      importedTriggers:
          importedTriggers ?? this.importedTriggers,
      importedDangerWindows:
          importedDangerWindows ??
              this.importedDangerWindows,
      importedTrustedSupportName:
          importedTrustedSupportName ??
              this.importedTrustedSupportName,
    );
  }

  PersonalRecoveryPlan preparedForSave(DateTime now) {
    final String nowIso = now.toIso8601String();
    final bool hasValidCreatedAt =
        DateTime.tryParse(createdAtIso) != null;

    return copyWith(
      createdAtIso:
          hasValidCreatedAt ? createdAtIso : nowIso,
      updatedAtIso: nowIso,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reasons': reasons,
      'primaryReason': primaryReason,
      'triggers': triggers,
      'dangerWindows': dangerWindows,
      'redirectActions': redirectActions,
      'trustedSupportName': trustedSupportName,
      'phoneBoundary': phoneBoundary,
      'bedtimeStrategy': bedtimeStrategy,
      'afterSlipReset': afterSlipReset,
      'faithSupport': faithSupport,
      'createdAtIso': createdAtIso,
      'updatedAtIso': updatedAtIso,
      'importedReasons': importedReasons,
      'importedPrimaryReason':
          importedPrimaryReason,
      'importedTriggers': importedTriggers,
      'importedDangerWindows':
          importedDangerWindows,
      'importedTrustedSupportName':
          importedTrustedSupportName,
    };
  }

  factory PersonalRecoveryPlan.fromMap(
    Map<String, dynamic> map,
  ) {
    return PersonalRecoveryPlan(
      reasons: _normalizedList(map['reasons']),
      primaryReason:
          _normalizedText(map['primaryReason']),
      triggers: _normalizedList(map['triggers']),
      dangerWindows:
          _normalizedList(map['dangerWindows']),
      redirectActions:
          _normalizedList(map['redirectActions']),
      trustedSupportName:
          _normalizedText(
        map['trustedSupportName'],
      ),
      phoneBoundary:
          _normalizedText(map['phoneBoundary']),
      bedtimeStrategy:
          _normalizedText(map['bedtimeStrategy']),
      afterSlipReset:
          _normalizedText(map['afterSlipReset']),
      faithSupport:
          _normalizedText(map['faithSupport']),
      createdAtIso:
          _normalizedText(map['createdAtIso']),
      updatedAtIso:
          _normalizedText(map['updatedAtIso']),
      importedReasons:
          _normalizedList(map['importedReasons']),
      importedPrimaryReason:
          _normalizedText(
        map['importedPrimaryReason'],
      ),
      importedTriggers:
          _normalizedList(map['importedTriggers']),
      importedDangerWindows:
          _normalizedList(
        map['importedDangerWindows'],
      ),
      importedTrustedSupportName:
          _normalizedText(
        map['importedTrustedSupportName'],
      ),
    );
  }

  static String _normalizedText(dynamic raw) {
    return (raw ?? '').toString().trim();
  }

  static List<String> _normalizedList(dynamic raw) {
    final List<dynamic> values =
        raw is List<dynamic>
            ? raw
            : <dynamic>[];

    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    for (final dynamic value in values) {
      final String display =
          value.toString().trim();
      final String key = display.toLowerCase();

      if (display.isEmpty || !seen.add(key)) {
        continue;
      }

      result.add(display);
    }

    return List<String>.unmodifiable(result);
  }
}
