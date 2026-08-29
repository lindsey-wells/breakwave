import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/billing/revenuecat_catalog_contract.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';

void main() {
  const RevenueCatCatalogPolicy policy =
      RevenueCatCatalogPolicy();

  RevenueCatCatalogSnapshot snapshot({
    String? currentOfferingIdentifier =
        RevenueCatCatalogContract.defaultOfferingId,
    bool launchOfferingFound = true,
    List<RevenueCatCatalogPackageRecord>? packages,
  }) {
    return RevenueCatCatalogSnapshot(
      currentOfferingIdentifier:
          currentOfferingIdentifier,
      launchOfferingFound: launchOfferingFound,
      packages: packages ??
          const <RevenueCatCatalogPackageRecord>[
            RevenueCatCatalogPackageRecord(
              packageIdentifier: 'launch-plan',
              packageType: 'custom',
              storeProductIdentifier:
                  'breakwave_plus_v1:launch-plan',
              priceString: 'STORE_PRICE',
              subscriptionPeriod: 'P1M',
            ),
          ],
    );
  }

  test('production identifiers are locked', () {
    expect(
      RevenueCatCatalogContract.googlePlaySubscriptionId,
      'breakwave_plus_v1',
    );
    expect(
      RevenueCatCatalogContract.plusEntitlementId,
      'breakwave_plus',
    );
    expect(
      RevenueCatCatalogContract.defaultOfferingId,
      'default',
    );
  });

  test(
    'catalog accepts any real base plan without assuming launch cadence',
    () {
      final RevenueCatCatalogValidation result =
          policy.validate(
        snapshot(
          packages:
              const <RevenueCatCatalogPackageRecord>[
            RevenueCatCatalogPackageRecord(
              packageIdentifier: 'arbitrary-package',
              packageType: 'custom',
              storeProductIdentifier:
                  'breakwave_plus_v1:any-valid-base-plan',
              priceString: 'STORE_PRICE',
              subscriptionPeriod: 'P3M',
            ),
          ],
        ),
      );

      expect(result.isReady, isTrue);
      expect(result.issues, isEmpty);
    },
  );

  test('missing launch offering is rejected', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(
        launchOfferingFound: false,
        packages:
            const <RevenueCatCatalogPackageRecord>[],
      ),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.launchOfferingMissing,
      ),
    );
  });

  test('default offering must be current for launch', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(currentOfferingIdentifier: 'experiment'),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue
            .launchOfferingNotCurrent,
      ),
    );
  });

  test('unrelated Google Play product is rejected', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(
        packages:
            const <RevenueCatCatalogPackageRecord>[
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'wrong',
            packageType: 'custom',
            storeProductIdentifier:
                'other_subscription:base',
            priceString: 'STORE_PRICE',
            subscriptionPeriod: 'P1M',
          ),
        ],
      ),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.unrelatedGoogleProduct,
      ),
    );
  });

  test('subscription without base-plan suffix is rejected', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(
        packages:
            const <RevenueCatCatalogPackageRecord>[
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'bad-base-plan',
            packageType: 'custom',
            storeProductIdentifier:
                'breakwave_plus_v1:',
            priceString: 'STORE_PRICE',
            subscriptionPeriod: 'P1M',
          ),
        ],
      ),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.missingGoogleBasePlan,
      ),
    );
  });

  test('store price and billing period are required', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(
        packages:
            const <RevenueCatCatalogPackageRecord>[
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'missing-store-data',
            packageType: 'custom',
            storeProductIdentifier:
                'breakwave_plus_v1:base',
            priceString: '',
            subscriptionPeriod: null,
          ),
        ],
      ),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.missingStorePrice,
      ),
    );
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.missingBillingPeriod,
      ),
    );
  });

  test('duplicate RevenueCat package IDs are rejected', () {
    final RevenueCatCatalogValidation result =
        policy.validate(
      snapshot(
        packages:
            const <RevenueCatCatalogPackageRecord>[
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'same',
            packageType: 'custom',
            storeProductIdentifier:
                'breakwave_plus_v1:base-a',
            priceString: 'STORE_PRICE_A',
            subscriptionPeriod: 'P1M',
          ),
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'same',
            packageType: 'custom',
            storeProductIdentifier:
                'breakwave_plus_v1:base-b',
            priceString: 'STORE_PRICE_B',
            subscriptionPeriod: 'P1Y',
          ),
        ],
      ),
    );

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue
            .duplicatePackageIdentifier,
      ),
    );
  });
}
