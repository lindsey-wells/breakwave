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

  static const String monthlyPackageIdentifier =
      r'$rc_monthly';

  static const String annualPackageIdentifier =
      r'$rc_annual';

  static const String testStoreMonthlyProductIdentifier =
      'monthly';

  static const String testStoreAnnualProductIdentifier =
      'yearly';

  static const String googlePlayProductPrefix =
      '$googlePlaySubscriptionId:';

  static bool isSupportedPurchasePackage(
    String identifier,
  ) {
    return identifier == monthlyPackageIdentifier ||
        identifier == annualPackageIdentifier;
  }

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
