// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_context_observation_engine.dart
// Purpose: BW-89A8B deterministic Bedtime Context observations.
// Notes: Uses BedtimeModeEntry history only; never converts bedtime context
// into Log behavior, diagnosis, causation, or prediction.
// ------------------------------------------------------------

import '../../../core/bedtime/bedtime_mode_entry.dart';
import 'bedtime_context_observation.dart';

class BedtimeContextObservationEngine {
  const BedtimeContextObservationEngine();

  static const int windowDays = 7;
  static const int minimumBedtimeCheckIns = 3;

  BedtimeContextObservationResult evaluate({
    required List<BedtimeModeEntry> entries,
    required DateTime now,
  }) {
    final DateTime localNow = now.toLocal();
    final Set<String> validDateKeys = <String>{};

    for (int offset = 0; offset < windowDays; offset += 1) {
      validDateKeys.add(
        _dateKeyFor(
          localNow.subtract(Duration(days: offset)),
        ),
      );
    }

    final Map<String, BedtimeModeEntry> latestByDate =
        <String, BedtimeModeEntry>{};

    for (final BedtimeModeEntry entry in entries) {
      final String dateKey = entry.dateKey.trim();
      if (!validDateKeys.contains(dateKey)) {
        continue;
      }

      final BedtimeModeEntry? existing =
          latestByDate[dateKey];
      if (existing == null ||
          _shouldReplace(existing, entry)) {
        latestByDate[dateKey] = entry;
      }
    }

    final List<BedtimeModeEntry> recent =
        latestByDate.values.toList()
          ..sort(
            (BedtimeModeEntry a, BedtimeModeEntry b) =>
                b.dateKey.compareTo(a.dateKey),
          );

    final int bedtimeCount = recent.length;
    final int riskyCount = recent
        .where((BedtimeModeEntry item) => item.isRisky)
        .length;
    final int steadyCount = bedtimeCount - riskyCount;

    if (bedtimeCount < minimumBedtimeCheckIns) {
      final int remaining =
          minimumBedtimeCheckIns - bedtimeCount;
      return BedtimeContextObservationResult(
        bedtimeCount: bedtimeCount,
        riskyCount: riskyCount,
        steadyCount: steadyCount,
        hasEnoughData: false,
        hasObservation: false,
        windowDays: windowDays,
        message:
            'Keep marking bedtime. $remaining more recent bedtime check-in${remaining == 1 ? '' : 's'} will give you enough context to look for repetition.',
      );
    }

    if (riskyCount == steadyCount) {
      return BedtimeContextObservationResult(
        bedtimeCount: bedtimeCount,
        riskyCount: riskyCount,
        steadyCount: steadyCount,
        hasEnoughData: true,
        hasObservation: false,
        windowDays: windowDays,
        message:
            'Risky and steady bedtime check-ins are evenly represented in the last $windowDays days.',
      );
    }

    final bool riskyDominates =
        riskyCount > steadyCount;
    final int dominantCount =
        riskyDominates ? riskyCount : steadyCount;
    final String dominantLabel =
        riskyDominates ? 'risky' : 'steady';

    return BedtimeContextObservationResult(
      bedtimeCount: bedtimeCount,
      riskyCount: riskyCount,
      steadyCount: steadyCount,
      hasEnoughData: true,
      hasObservation: true,
      windowDays: windowDays,
      message:
          'You marked $dominantCount of $bedtimeCount bedtime check-ins as $dominantLabel in the last $windowDays days.',
    );
  }

  bool _shouldReplace(
    BedtimeModeEntry existing,
    BedtimeModeEntry candidate,
  ) {
    final DateTime? existingSaved =
        DateTime.tryParse(existing.savedAtIso);
    final DateTime? candidateSaved =
        DateTime.tryParse(candidate.savedAtIso);

    if (existingSaved != null &&
        candidateSaved != null) {
      final int comparison =
          candidateSaved.compareTo(existingSaved);
      if (comparison != 0) {
        return comparison > 0;
      }
    } else if (candidateSaved != null) {
      return true;
    } else if (existingSaved != null) {
      return false;
    }

    if (candidate.isRisky != existing.isRisky) {
      return candidate.isRisky;
    }

    return false;
  }

  String _dateKeyFor(DateTime value) {
    final DateTime local = value.toLocal();
    final String year =
        local.year.toString().padLeft(4, '0');
    final String month =
        local.month.toString().padLeft(2, '0');
    final String day =
        local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
