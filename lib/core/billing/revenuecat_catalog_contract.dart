// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_catalog_contract.dart
// Purpose: Stable production billing catalog identifiers.
// Notes: Pricing, trials, and billing cadence remain store-owned.
// ------------------------------------------------------------

class RevenueCatCatalogContract {
  const RevenueCatCatalogContract._();

  static const String googlePlaySubscriptionId =
      'breakwave_plus_v1';

  static const String plusEntitlementId =
      'breakwave_plus';

  static const String defaultOfferingId = 'default';

  static const String googlePlayProductPrefix =
      '$googlePlaySubscriptionId:';

  static bool isBreakWavePlusGoogleProduct(
    String identifier,
  ) {
    if (!identifier.startsWith(googlePlayProductPrefix)) {
      return false;
    }

    return identifier
        .substring(googlePlayProductPrefix.length)
        .trim()
        .isNotEmpty;
  }
}
