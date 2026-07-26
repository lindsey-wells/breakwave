// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_entitlement_source.dart
// Purpose: Replaceable source contract for Plus entitlement.
// Notes: This contract carries no recovery data and contains
//        no Google Play Billing implementation.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';

abstract class BreakWaveEntitlementSource {
  const BreakWaveEntitlementSource();

  ValueListenable<int> get changes;

  Future<bool> isPlusUnlocked();
}
