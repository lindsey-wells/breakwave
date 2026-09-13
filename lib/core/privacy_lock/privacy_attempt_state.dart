// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_attempt_state.dart
// Purpose: IOS-G2E persistent non-secret failed-attempt state.
// Notes: Stores counters/timestamps only; never stores credential material.
// ------------------------------------------------------------

class PrivacyAttemptState {
  const PrivacyAttemptState({
    required this.failedAttemptCount,
    required this.cooldownUntilUtc,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  static const PrivacyAttemptState empty = PrivacyAttemptState(
    failedAttemptCount: 0,
    cooldownUntilUtc: null,
  );

  final int failedAttemptCount;
  final DateTime? cooldownUntilUtc;
  final int schemaVersion;

  bool isCoolingDownAt(DateTime at) {
    final DateTime? until = cooldownUntilUtc;
    if (until == null) return false;
    return at.toUtc().isBefore(until.toUtc());
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'failedAttemptCount': failedAttemptCount,
      'cooldownUntilUtc': cooldownUntilUtc?.toUtc().toIso8601String(),
      'schemaVersion': schemaVersion,
    };
  }

  factory PrivacyAttemptState.fromMap(Map<String, dynamic> map) {
    final Object? rawCount = map['failedAttemptCount'];
    final int failedAttemptCount = rawCount is int && rawCount >= 0
        ? rawCount
        : 0;

    DateTime? cooldownUntilUtc;
    final Object? rawCooldown = map['cooldownUntilUtc'];
    if (rawCooldown is String && rawCooldown.trim().isNotEmpty) {
      cooldownUntilUtc = DateTime.tryParse(rawCooldown)?.toUtc();
    }

    final Object? rawSchemaVersion = map['schemaVersion'];

    return PrivacyAttemptState(
      failedAttemptCount: failedAttemptCount,
      cooldownUntilUtc: cooldownUntilUtc,
      schemaVersion: rawSchemaVersion is int
          ? rawSchemaVersion
          : currentSchemaVersion,
    );
  }

  PrivacyAttemptState copyWith({
    int? failedAttemptCount,
    DateTime? cooldownUntilUtc,
    bool clearCooldown = false,
    int? schemaVersion,
  }) {
    return PrivacyAttemptState(
      failedAttemptCount: failedAttemptCount ?? this.failedAttemptCount,
      cooldownUntilUtc: clearCooldown
          ? null
          : (cooldownUntilUtc ?? this.cooldownUntilUtc),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
