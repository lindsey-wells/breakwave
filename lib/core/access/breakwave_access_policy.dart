// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_access_policy.dart
// Purpose: Authoritative feature-to-access classification policy.
// Notes: This file contains product rules only. It does not read
//        local storage, billing state, or recovery data.
// ------------------------------------------------------------

import 'breakwave_access_class.dart';
import 'breakwave_feature.dart';

class BreakWaveAccessPolicy {
  const BreakWaveAccessPolicy._();

  static const Map<BreakWaveFeature, BreakWaveAccessClass>
      _classifications =
      <BreakWaveFeature, BreakWaveAccessClass>{
    // Never paywalled: urgent access, human help, privacy,
    // onboarding, basic recovery support, and user data control.
    BreakWaveFeature.rescueNow:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.rescueActions:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.onboarding:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.basicLogging:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.logHistory:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.editAndDeleteLogs:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.privacySettings:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.privacyLock:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.privacyPolicy:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.emergencyHelp:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.humanSupportActions:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.trustedContactTools:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.recoveryMode:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.basicSecularSupport:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.basicChristianSupport:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.personalWhy:
        BreakWaveAccessClass.neverPaywalled,
    BreakWaveFeature.personalDataControl:
        BreakWaveAccessClass.neverPaywalled,

    // Protected Free core: foundational repeat-use recovery tools.
    BreakWaveFeature.reasonsAndTriggers:
        BreakWaveAccessClass.protectedFreeCore,
    BreakWaveFeature.dailyCheckIn:
        BreakWaveAccessClass.protectedFreeCore,
    BreakWaveFeature.bedtimeRiskSupport:
        BreakWaveAccessClass.protectedFreeCore,
    BreakWaveFeature.starterRecoveryPlan:
        BreakWaveAccessClass.protectedFreeCore,

    // Free support: useful support and education without payment.
    BreakWaveFeature.reminders:
        BreakWaveAccessClass.freeSupport,
    BreakWaveFeature.recoveryCycleEducation:
        BreakWaveAccessClass.freeSupport,
    BreakWaveFeature.recoveryEducationResources:
        BreakWaveAccessClass.freeSupport,
    BreakWaveFeature.basicRecoverySnapshot:
        BreakWaveAccessClass.freeSupport,

    // Plus candidates: deeper, repeat-use recovery extensions.
    BreakWaveFeature.advancedRecoveryInsights:
        BreakWaveAccessClass.plusCandidate,
    BreakWaveFeature.savedPersonalRecoveryPlan:
        BreakWaveAccessClass.plusCandidate,
    BreakWaveFeature.guidedRoutines:
        BreakWaveAccessClass.plusCandidate,
    BreakWaveFeature.christianJourneys:
        BreakWaveAccessClass.plusCandidate,
    BreakWaveFeature.enhancedRecoveryReports:
        BreakWaveAccessClass.plusCandidate,
    BreakWaveFeature.extendedChristianDepth:
        BreakWaveAccessClass.plusCandidate,
  };

  static Map<BreakWaveFeature, BreakWaveAccessClass>
      get classifications =>
          Map<BreakWaveFeature, BreakWaveAccessClass>.unmodifiable(
            _classifications,
          );

  static BreakWaveAccessClass accessClassFor(
    BreakWaveFeature feature,
  ) {
    final BreakWaveAccessClass? accessClass =
        _classifications[feature];

    if (accessClass == null) {
      throw StateError(
        'No access classification exists for ${feature.name}.',
      );
    }

    return accessClass;
  }

  static BreakWaveAccessTier minimumTierFor(
    BreakWaveFeature feature,
  ) {
    return accessClassFor(feature).minimumTier;
  }

  static bool isAvailable(
    BreakWaveFeature feature, {
    required bool isPlusUnlocked,
  }) {
    final BreakWaveAccessClass accessClass =
        accessClassFor(feature);

    return !accessClass.requiresPlus || isPlusUnlocked;
  }

  static List<BreakWaveFeature> featuresForClass(
    BreakWaveAccessClass accessClass,
  ) {
    return BreakWaveFeature.values
        .where(
          (BreakWaveFeature feature) =>
              accessClassFor(feature) == accessClass,
        )
        .toList(growable: false);
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

  static Set<BreakWaveFeature> get neverPaywalled =>
      featuresForClass(
        BreakWaveAccessClass.neverPaywalled,
      ).toSet();

  static Set<BreakWaveFeature> get protectedFreeCore =>
      featuresForClass(
        BreakWaveAccessClass.protectedFreeCore,
      ).toSet();

  static Set<BreakWaveFeature> get freeSupport =>
      featuresForClass(
        BreakWaveAccessClass.freeSupport,
      ).toSet();

  static Set<BreakWaveFeature> get plusCandidates =>
      featuresForClass(
        BreakWaveAccessClass.plusCandidate,
      ).toSet();
}
