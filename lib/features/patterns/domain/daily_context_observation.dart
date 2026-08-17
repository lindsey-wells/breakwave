// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_context_observation.dart
// Purpose: BW-89A6 result model for Daily Context Signals.
// Notes: Daily Check-In context stays separate from behavioral Log evidence.
// ------------------------------------------------------------

class DailyContextObservationResult {
  const DailyContextObservationResult({
    required this.checkInCount,
    required this.hasEnoughData,
    required this.hasObservation,
    required this.windowDays,
    required this.message,
    required this.dominantStatus,
    required this.evidenceCount,
  });

  const DailyContextObservationResult.empty()
      : checkInCount = 0,
        hasEnoughData = false,
        hasObservation = false,
        windowDays = 7,
        message =
            'Keep checking in. Three recent Daily Check-Ins are needed before looking for repetition.',
        dominantStatus = null,
        evidenceCount = 0;

  final int checkInCount;
  final bool hasEnoughData;
  final bool hasObservation;
  final int windowDays;
  final String message;
  final String? dominantStatus;
  final int evidenceCount;
}
