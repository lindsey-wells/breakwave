// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_context_observation.dart
// Purpose: BW-89A8B deterministic Bedtime Context observation result.
// Notes: Bedtime context remains separate from behavioral Log evidence.
// ------------------------------------------------------------

class BedtimeContextObservationResult {
  const BedtimeContextObservationResult({
    required this.bedtimeCount,
    required this.riskyCount,
    required this.steadyCount,
    required this.hasEnoughData,
    required this.hasObservation,
    required this.windowDays,
    required this.message,
  });

  const BedtimeContextObservationResult.empty()
      : bedtimeCount = 0,
        riskyCount = 0,
        steadyCount = 0,
        hasEnoughData = false,
        hasObservation = false,
        windowDays = 7,
        message =
            'Keep marking bedtime. Three recent bedtime check-ins are needed before looking for repetition.';

  final int bedtimeCount;
  final int riskyCount;
  final int steadyCount;
  final bool hasEnoughData;
  final bool hasObservation;
  final int windowDays;
  final String message;
}
