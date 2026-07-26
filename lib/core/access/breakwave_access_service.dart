// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_access_service.dart
// Purpose: Central presentation-facing access decision service.
// Notes: Free access is resolved from product policy without
//        reading entitlement storage. Plus access temporarily
//        uses the replaceable local entitlement adapter.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';

import 'breakwave_access_decision.dart';
import 'breakwave_access_policy.dart';
import 'breakwave_entitlement_source.dart';
import 'breakwave_feature.dart';
import 'local_premium_entitlement_source.dart';

class BreakWaveAccessService {
  const BreakWaveAccessService({
    required this.entitlementSource,
  });

  static const BreakWaveAccessService localTesting =
      BreakWaveAccessService(
    entitlementSource:
        LocalPremiumEntitlementSource(),
  );

  final BreakWaveEntitlementSource entitlementSource;

  ValueListenable<int> get changes =>
      entitlementSource.changes;

  Future<BreakWaveAccessDecision> decisionFor(
    BreakWaveFeature feature,
  ) async {
    final BreakWaveAccessClass accessClass =
        BreakWaveAccessPolicy.accessClassFor(feature);

    final BreakWaveAccessTier minimumTier =
        BreakWaveAccessPolicy.minimumTierFor(feature);

    if (!accessClass.requiresPlus) {
      return BreakWaveAccessDecision(
        feature: feature,
        accessClass: accessClass,
        minimumTier: minimumTier,
        isAvailable: true,
      );
    }

    bool isPlusUnlocked = false;

    try {
      isPlusUnlocked =
          await entitlementSource.isPlusUnlocked();
    } catch (_) {
      // The temporary entitlement source fails closed for
      // Plus. Free and never-paywalled features never reach
      // this entitlement read.
      isPlusUnlocked = false;
    }

    return BreakWaveAccessDecision(
      feature: feature,
      accessClass: accessClass,
      minimumTier: minimumTier,
      isAvailable:
          BreakWaveAccessPolicy.isAvailable(
        feature,
        isPlusUnlocked: isPlusUnlocked,
      ),
    );
  }

  Future<bool> isAvailable(
    BreakWaveFeature feature,
  ) async {
    final BreakWaveAccessDecision decision =
        await decisionFor(feature);

    return decision.isAvailable;
  }
}
