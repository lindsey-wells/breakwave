// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pattern_observation.dart
// Purpose: Immutable, cautious observations derived from saved Log data.
// Notes: BW-89A2 describes recorded patterns without causal or predictive claims.
// ------------------------------------------------------------

enum PatternObservationKind {
  recurringTrigger,
  timeWindow,
  repeatedVictoryAction,
}

class PatternObservation {
  const PatternObservation({
    required this.kind,
    required this.message,
    required this.evidenceCount,
  });

  final PatternObservationKind kind;
  final String message;
  final int evidenceCount;
}

class PatternObservationResult {
  const PatternObservationResult({
    required this.observations,
    required this.behavioralEntryCount,
    required this.hasEnoughData,
    required this.windowDays,
  });

  final List<PatternObservation> observations;
  final int behavioralEntryCount;
  final bool hasEnoughData;
  final int windowDays;

  bool get hasObservations => observations.isNotEmpty;
}
