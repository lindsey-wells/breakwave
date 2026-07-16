// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_feature.dart
// Purpose: Stable product-feature identifiers for access rules.
// Notes: BW-87B6P1 defines product access before billing.
// ------------------------------------------------------------

enum BreakWaveAccessTier {
  free,
  plus,
}

enum BreakWaveFeature {
  rescueNow,
  basicLogging,
  logHistory,
  editAndDeleteLogs,
  privacySettings,
  privacyLock,
  supportResources,
  recoveryMode,
  reasonsAndTriggers,
  personalWhy,
  dailyCheckIn,
  reminders,
  bedtimeRiskSupport,
  recoveryCycleEducation,
  recoveryInsights,
  personalRecoveryPlan,
  guidedRoutines,
  christianJourneys,
  recoveryReports,
  faithDepthPack;

  String get label {
    switch (this) {
      case BreakWaveFeature.rescueNow:
        return 'Rescue';
      case BreakWaveFeature.basicLogging:
        return 'Basic logging';
      case BreakWaveFeature.logHistory:
        return 'Log history';
      case BreakWaveFeature.editAndDeleteLogs:
        return 'Log correction tools';
      case BreakWaveFeature.privacySettings:
        return 'Privacy controls';
      case BreakWaveFeature.privacyLock:
        return 'Privacy lock';
      case BreakWaveFeature.supportResources:
        return 'Essential support resources';
      case BreakWaveFeature.recoveryMode:
        return 'Recovery mode';
      case BreakWaveFeature.reasonsAndTriggers:
        return 'Reasons and triggers';
      case BreakWaveFeature.personalWhy:
        return 'Personal Why';
      case BreakWaveFeature.dailyCheckIn:
        return 'Daily check-in';
      case BreakWaveFeature.reminders:
        return 'Recovery reminders';
      case BreakWaveFeature.bedtimeRiskSupport:
        return 'Bedtime risk support';
      case BreakWaveFeature.recoveryCycleEducation:
        return 'Recovery-cycle education';
      case BreakWaveFeature.recoveryInsights:
        return 'Recovery insights';
      case BreakWaveFeature.personalRecoveryPlan:
        return 'Personal recovery plan';
      case BreakWaveFeature.guidedRoutines:
        return 'Guided routines';
      case BreakWaveFeature.christianJourneys:
        return 'Christian recovery journeys';
      case BreakWaveFeature.recoveryReports:
        return 'Recovery reports';
      case BreakWaveFeature.faithDepthPack:
        return 'Christian depth pack';
    }
  }
}
