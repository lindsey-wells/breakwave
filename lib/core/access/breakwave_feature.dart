// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_feature.dart
// Purpose: Stable identifiers for separately auditable features.
// Notes: Broad features are split where Free and Plus value differ.
// ------------------------------------------------------------

export 'breakwave_access_class.dart';

enum BreakWaveFeature {
  rescueNow,
  rescueActions,
  onboarding,
  basicLogging,
  logHistory,
  editAndDeleteLogs,
  privacySettings,
  privacyLock,
  privacyPolicy,
  emergencyHelp,
  humanSupportActions,
  trustedContactTools,
  recoveryMode,
  basicSecularSupport,
  basicChristianSupport,
  personalWhy,
  personalDataControl,
  reasonsAndTriggers,
  dailyCheckIn,
  bedtimeRiskSupport,
  starterRecoveryPlan,
  reminders,
  recoveryCycleEducation,
  recoveryEducationResources,
  basicRecoverySnapshot,
  advancedRecoveryInsights,
  savedPersonalRecoveryPlan,
  guidedRoutines,
  christianJourneys,
  enhancedRecoveryReports,
  extendedChristianDepth;

  String get label {
    switch (this) {
      case BreakWaveFeature.rescueNow:
        return 'Rescue';

      case BreakWaveFeature.rescueActions:
        return 'Immediate Rescue actions';

      case BreakWaveFeature.onboarding:
        return 'Onboarding';

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

      case BreakWaveFeature.privacyPolicy:
        return 'Privacy Policy';

      case BreakWaveFeature.emergencyHelp:
        return 'Emergency information';

      case BreakWaveFeature.humanSupportActions:
        return 'Human-support actions';

      case BreakWaveFeature.trustedContactTools:
        return 'Trusted-contact tools';

      case BreakWaveFeature.recoveryMode:
        return 'Recovery mode';

      case BreakWaveFeature.basicSecularSupport:
        return 'Basic secular recovery support';

      case BreakWaveFeature.basicChristianSupport:
        return 'Basic Christian recovery support';

      case BreakWaveFeature.personalWhy:
        return 'Personal Why';

      case BreakWaveFeature.personalDataControl:
        return 'Personal-data access and control';

      case BreakWaveFeature.reasonsAndTriggers:
        return 'Reasons and triggers';

      case BreakWaveFeature.dailyCheckIn:
        return 'Daily check-in';

      case BreakWaveFeature.bedtimeRiskSupport:
        return 'Bedtime risk support';

      case BreakWaveFeature.starterRecoveryPlan:
        return 'Starter recovery plan';

      case BreakWaveFeature.reminders:
        return 'Recovery reminders';

      case BreakWaveFeature.recoveryCycleEducation:
        return 'Recovery-cycle education';

      case BreakWaveFeature.recoveryEducationResources:
        return 'Recovery education resources';

      case BreakWaveFeature.basicRecoverySnapshot:
        return 'Basic recovery snapshot';

      case BreakWaveFeature.advancedRecoveryInsights:
        return 'Advanced recovery insights';

      case BreakWaveFeature.savedPersonalRecoveryPlan:
        return 'Saved personal recovery plan';

      case BreakWaveFeature.guidedRoutines:
        return 'Guided routines';

      case BreakWaveFeature.christianJourneys:
        return 'Christian recovery journeys';

      case BreakWaveFeature.enhancedRecoveryReports:
        return 'Enhanced recovery reports';

      case BreakWaveFeature.extendedChristianDepth:
        return 'Extended Christian depth';
    }
  }
}
