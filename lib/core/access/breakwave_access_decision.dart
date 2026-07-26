// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_access_decision.dart
// Purpose: Immutable result of one feature-access decision.
// Notes: Decisions expose product-policy results without
//        exposing entitlement-storage implementation.
// ------------------------------------------------------------

import 'breakwave_access_class.dart';
import 'breakwave_feature.dart';

class BreakWaveAccessDecision {
  const BreakWaveAccessDecision({
    required this.feature,
    required this.accessClass,
    required this.minimumTier,
    required this.isAvailable,
  });

  final BreakWaveFeature feature;
  final BreakWaveAccessClass accessClass;
  final BreakWaveAccessTier minimumTier;
  final bool isAvailable;

  bool get isLocked => !isAvailable;
}
