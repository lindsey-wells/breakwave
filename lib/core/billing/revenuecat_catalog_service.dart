// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_catalog_service.dart
// Purpose: Read-only validation of the RevenueCat product catalog.
// Notes: No purchase, restore, paywall, or entitlement mutation.
// ------------------------------------------------------------

import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_catalog_contract.dart';

class RevenueCatCatalogPackageRecord {
  const RevenueCatCatalogPackageRecord({
    required this.packageIdentifier,
    required this.packageType,
    required this.storeProductIdentifier,
    required this.priceString,
    required this.subscriptionPeriod,
  });

  final String packageIdentifier;
  final String packageType;
  final String storeProductIdentifier;
  final String priceString;
  final String? subscriptionPeriod;
}

class RevenueCatCatalogSnapshot {
  const RevenueCatCatalogSnapshot({
    required this.currentOfferingIdentifier,
    required this.launchOfferingFound,
    required this.packages,
  });

  final String? currentOfferingIdentifier;
  final bool launchOfferingFound;
  final List<RevenueCatCatalogPackageRecord> packages;
}

enum RevenueCatCatalogIssue {
  providerUnavailable,
  launchOfferingMissing,
  launchOfferingNotCurrent,
  noPackages,
  duplicatePackageIdentifier,
  unrelatedGoogleProduct,
  missingGoogleBasePlan,
  missingStorePrice,
  missingBillingPeriod,
}

class RevenueCatCatalogValidation {
  const RevenueCatCatalogValidation({
    required this.isReady,
    required this.issues,
    required this.snapshot,
  });

  final bool isReady;
  final Set<RevenueCatCatalogIssue> issues;
  final RevenueCatCatalogSnapshot snapshot;
}

abstract class RevenueCatCatalogProvider {
  const RevenueCatCatalogProvider();

  Future<RevenueCatCatalogSnapshot> load();
}

class RevenueCatSdkCatalogProvider
    extends RevenueCatCatalogProvider {
  const RevenueCatSdkCatalogProvider();

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    if (!await Purchases.isConfigured) {
      throw StateError('RevenueCat is not configured.');
    }

    final Offerings offerings =
        await Purchases.getOfferings();

    final Offering? launchOffering =
        offerings.getOffering(
      RevenueCatCatalogContract.defaultOfferingId,
    );

    if (launchOffering == null) {
      return RevenueCatCatalogSnapshot(
        currentOfferingIdentifier:
            offerings.current?.identifier,
        launchOfferingFound: false,
        packages:
            const <RevenueCatCatalogPackageRecord>[],
      );
    }

    final List<RevenueCatCatalogPackageRecord> packages =
        launchOffering.availablePackages
            .map(
              (Package package) =>
                  RevenueCatCatalogPackageRecord(
                packageIdentifier:
                    package.identifier,
                packageType:
                    package.packageType.name,
                storeProductIdentifier:
                    package.storeProduct.identifier,
                priceString:
                    package.storeProduct.priceString,
                subscriptionPeriod:
                    package.storeProduct
                        .subscriptionPeriod,
              ),
            )
            .toList(growable: false);

    return RevenueCatCatalogSnapshot(
      currentOfferingIdentifier:
          offerings.current?.identifier,
      launchOfferingFound: true,
      packages: packages,
    );
  }
}

class RevenueCatCatalogPolicy {
  const RevenueCatCatalogPolicy();

  RevenueCatCatalogValidation validate(
    RevenueCatCatalogSnapshot snapshot,
  ) {
    final Set<RevenueCatCatalogIssue> issues =
        <RevenueCatCatalogIssue>{};

    if (!snapshot.launchOfferingFound) {
      issues.add(
        RevenueCatCatalogIssue.launchOfferingMissing,
      );
    }

    if (snapshot.currentOfferingIdentifier !=
        RevenueCatCatalogContract.defaultOfferingId) {
      issues.add(
        RevenueCatCatalogIssue.launchOfferingNotCurrent,
      );
    }

    if (snapshot.packages.isEmpty) {
      issues.add(RevenueCatCatalogIssue.noPackages);
    }

    final Set<String> packageIdentifiers = <String>{};

    for (final RevenueCatCatalogPackageRecord package
        in snapshot.packages) {
      if (!packageIdentifiers.add(
        package.packageIdentifier,
      )) {
        issues.add(
          RevenueCatCatalogIssue
              .duplicatePackageIdentifier,
        );
      }

      final String productId =
          package.storeProductIdentifier;

      if (!productId.startsWith(
        RevenueCatCatalogContract
            .googlePlayProductPrefix,
      )) {
        issues.add(
          RevenueCatCatalogIssue.unrelatedGoogleProduct,
        );
      } else if (!RevenueCatCatalogContract
          .isBreakWavePlusGoogleProduct(productId)) {
        issues.add(
          RevenueCatCatalogIssue.missingGoogleBasePlan,
        );
      }

      if (package.priceString.trim().isEmpty) {
        issues.add(
          RevenueCatCatalogIssue.missingStorePrice,
        );
      }

      if ((package.subscriptionPeriod ?? '')
          .trim()
          .isEmpty) {
        issues.add(
          RevenueCatCatalogIssue.missingBillingPeriod,
        );
      }
    }

    return RevenueCatCatalogValidation(
      isReady: issues.isEmpty,
      issues: Set<RevenueCatCatalogIssue>.unmodifiable(
        issues,
      ),
      snapshot: snapshot,
    );
  }
}

class RevenueCatCatalogService {
  const RevenueCatCatalogService({
    this.provider =
        const RevenueCatSdkCatalogProvider(),
    this.policy = const RevenueCatCatalogPolicy(),
  });

  final RevenueCatCatalogProvider provider;
  final RevenueCatCatalogPolicy policy;

  Future<RevenueCatCatalogValidation> validate() async {
    try {
      final RevenueCatCatalogSnapshot snapshot =
          await provider.load();

      return policy.validate(snapshot);
    } catch (_) {
      const RevenueCatCatalogSnapshot empty =
          RevenueCatCatalogSnapshot(
        currentOfferingIdentifier: null,
        launchOfferingFound: false,
        packages:
            <RevenueCatCatalogPackageRecord>[],
      );

      return const RevenueCatCatalogValidation(
        isReady: false,
        issues: <RevenueCatCatalogIssue>{
          RevenueCatCatalogIssue.providerUnavailable,
        },
        snapshot: empty,
      );
    }
  }
}
