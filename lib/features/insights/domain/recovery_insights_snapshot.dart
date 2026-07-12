// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_insights_snapshot.dart
// Purpose: Immutable results for real log-based recovery insights.
// Notes: BW-87B2A keeps analytics separate from presentation.
// ------------------------------------------------------------

class RecoveryPeriodSummary {
  const RecoveryPeriodSummary({
    required this.days,
    required this.total,
    required this.urges,
    required this.slips,
    required this.victories,
    required this.averageIntensity,
  });

  final int days;
  final int total;
  final int urges;
  final int slips;
  final int victories;
  final double averageIntensity;

  bool get hasEntries => total > 0;
}

class TriggerInsight {
  const TriggerInsight({
    required this.trigger,
    required this.count,
  });

  final String trigger;
  final int count;
}

class RecoveryInsightsSnapshot {
  const RecoveryInsightsSnapshot({
    required this.validEntryCount,
    required this.ignoredEntryCount,
    required this.last7Days,
    required this.last30Days,
    required this.last90Days,
    required this.topTriggers30Days,
    required this.busiestWeekday30Days,
    required this.busiestTimeWindow30Days,
    required this.hasEnoughForTimePatterns,
  });

  final int validEntryCount;
  final int ignoredEntryCount;

  final RecoveryPeriodSummary last7Days;
  final RecoveryPeriodSummary last30Days;
  final RecoveryPeriodSummary last90Days;

  final List<TriggerInsight> topTriggers30Days;

  final String? busiestWeekday30Days;
  final String? busiestTimeWindow30Days;
  final bool hasEnoughForTimePatterns;

  bool get hasAnyData => validEntryCount > 0;
}
