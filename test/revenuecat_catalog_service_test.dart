import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/billing/revenuecat_catalog_contract.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_entitlement_source.dart';

void main() {
  test(
    'service validates a provider snapshot without purchasing',
    () async {
      const RevenueCatCatalogSnapshot snapshot =
          RevenueCatCatalogSnapshot(
        currentOfferingIdentifier: 'default',
        launchOfferingFound: true,
        packages: <RevenueCatCatalogPackageRecord>[
          RevenueCatCatalogPackageRecord(
            packageIdentifier: 'catalog-test',
            packageType: 'custom',
            storeProductIdentifier:
                'breakwave_plus_v1:catalog-test',
            priceString: 'STORE_PRICE',
            subscriptionPeriod: 'P1M',
          ),
        ],
      );

      final RevenueCatCatalogService service =
          RevenueCatCatalogService(
        provider: _FakeCatalogProvider(snapshot),
      );

      final RevenueCatCatalogValidation result =
          await service.validate();

      expect(result.isReady, isTrue);
    },
  );

  test('provider failure becomes not-ready', () async {
    final RevenueCatCatalogService service =
        RevenueCatCatalogService(
      provider: _ThrowingCatalogProvider(),
    );

    final RevenueCatCatalogValidation result =
        await service.validate();

    expect(result.isReady, isFalse);
    expect(
      result.issues,
      contains(
        RevenueCatCatalogIssue.providerUnavailable,
      ),
    );
  });

  test(
    'production entitlement source defaults to locked entitlement ID',
    () {
      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource.production();

      addTearDown(source.dispose);

      expect(
        source.entitlementId,
        RevenueCatCatalogContract.plusEntitlementId,
      );
    },
  );
}

class _FakeCatalogProvider
    extends RevenueCatCatalogProvider {
  const _FakeCatalogProvider(this.snapshot);

  final RevenueCatCatalogSnapshot snapshot;

  @override
  Future<RevenueCatCatalogSnapshot> load() async =>
      snapshot;
}

class _ThrowingCatalogProvider
    extends RevenueCatCatalogProvider {
  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    throw StateError('catalog unavailable');
  }
}
