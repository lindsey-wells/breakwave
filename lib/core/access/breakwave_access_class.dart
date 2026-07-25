// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_access_class.dart
// Purpose: Stable access classifications and derived tiers.
// Notes: Classifications express product protections independently
//        from billing or entitlement implementation.
// ------------------------------------------------------------

enum BreakWaveAccessTier {
  free,
  plus,
}

enum BreakWaveAccessClass {
  neverPaywalled,
  protectedFreeCore,
  freeSupport,
  plusCandidate,
}

extension BreakWaveAccessClassRules on BreakWaveAccessClass {
  BreakWaveAccessTier get minimumTier {
    switch (this) {
      case BreakWaveAccessClass.neverPaywalled:
      case BreakWaveAccessClass.protectedFreeCore:
      case BreakWaveAccessClass.freeSupport:
        return BreakWaveAccessTier.free;

      case BreakWaveAccessClass.plusCandidate:
        return BreakWaveAccessTier.plus;
    }
  }

  bool get requiresPlus =>
      minimumTier == BreakWaveAccessTier.plus;
}
