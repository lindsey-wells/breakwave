// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_access_policy.dart
// Purpose: Authoritative Free-versus-Plus feature contract.
// Notes: Rescue and protected recovery basics cannot be paywalled.
// ------------------------------------------------------------

import 'breakwave_feature.dart';

class BreakWaveAccessPolicy {
  const BreakWaveAccessPolicy._();

  static const Set<BreakWaveFeature>
      protectedFreeCore = <BreakWaveFeature>{
    BreakWaveFeature.rescueNow,
    BreakWaveFeature.basicLogging,
    BreakWaveFeature.logHistory,
    BreakWaveFeature.editAndDeleteLogs,
    BreakWaveFeature.privacySettings,
    BreakWaveFeature.privacyLock,
    BreakWaveFeature.supportResources,
    BreakWaveFeature.recoveryMode,
    BreakWaveFeature.reasonsAndTriggers,
    BreakWaveFeature.personalWhy,
  };

  static BreakWaveAccessTier minimumTierFor(
    BreakWaveFeature feature,
  ) {
    switch (feature) {
      case BreakWaveFeature.rescueNow:
      case BreakWaveFeature.basicLogging:
      case BreakWaveFeature.logHistory:
      case BreakWaveFeature.editAndDeleteLogs:
      case BreakWaveFeature.privacySettings:
      case BreakWaveFeature.privacyLock:
      case BreakWaveFeature.supportResources:
      case BreakWaveFeature.recoveryMode:
      case BreakWaveFeature.reasonsAndTriggers:
      case BreakWaveFeature.personalWhy:
      case BreakWaveFeature.dailyCheckIn:
      case BreakWaveFeature.reminders:
      case BreakWaveFeature.bedtimeRiskSupport:
      case BreakWaveFeature.recoveryCycleEducation:
        return BreakWaveAccessTier.free;

      case BreakWaveFeature.recoveryInsights:
      case BreakWaveFeature.personalRecoveryPlan:
      case BreakWaveFeature.guidedRoutines:
      case BreakWaveFeature.christianJourneys:
      case BreakWaveFeature.recoveryReports:
      case BreakWaveFeature.faithDepthPack:
        return BreakWaveAccessTier.plus;
    }
  }

  static bool isAvailable(
    BreakWaveFeature feature, {
    required bool isPlusUnlocked,
  }) {
    final BreakWaveAccessTier requiredTier =
        minimumTierFor(feature);

    return requiredTier == BreakWaveAccessTier.free ||
        isPlusUnlocked;
  }

  static List<BreakWaveFeature> featuresFor(
    BreakWaveAccessTier tier,
  ) {
    return BreakWaveFeature.values
        .where(
          (BreakWaveFeature feature) =>
              minimumTierFor(feature) == tier,
        )
        .toList(growable: false);
  }
}
