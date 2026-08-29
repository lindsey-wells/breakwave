// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_access_service.dart
// Purpose: Compose trusted RevenueCat source with access policy.
// Notes: Does not alter Free/Rescue classification or add UI.
// ------------------------------------------------------------

import '../access/breakwave_access_service.dart';
import 'revenuecat_entitlement_source.dart';

class BreakWaveRevenueCatAccess {
  const BreakWaveRevenueCatAccess._();

  static BreakWaveAccessService create() {
    return BreakWaveAccessService(
      entitlementSource:
          RevenueCatEntitlementSource.production(),
    );
  }
}
