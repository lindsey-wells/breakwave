// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: local_premium_entitlement_source.dart
// Purpose: Adapt the existing local premium scaffold.
// Notes: This is temporary test-build compatibility, not a
//        production billing authority.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';

import '../premium/premium_state.dart';
import '../premium/premium_state_store.dart';
import 'breakwave_entitlement_source.dart';

class LocalPremiumEntitlementSource
    extends BreakWaveEntitlementSource {
  const LocalPremiumEntitlementSource();

  @override
  ValueListenable<int> get changes =>
      PremiumStateStore.changes;

  @override
  Future<bool> isPlusUnlocked() async {
    final PremiumState state =
        await PremiumStateStore.load();

    return state.isPlusUnlocked;
  }
}
