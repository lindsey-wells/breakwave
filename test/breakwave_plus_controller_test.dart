import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/billing/breakwave_billing_composition.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_contract.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_lifecycle.dart';
import 'package:breakwave/features/premium/application/breakwave_plus_controller.dart';

void main() {
  test(
    'Test Store catalog exposes store-owned monthly and annual prices',
    () async {
      final _SequenceEntitlementSource entitlement =
          _SequenceEntitlementSource(<bool>[false]);
      addTearDown(entitlement.dispose);

      final BreakWavePlusController controller = _controller(
        entitlement: entitlement,
        executor: _FakeExecutor(
          purchaseResult: RevenueCatPurchaseExecutorResult.completed,
        ),
        catalog: _testStoreCatalog(
          monthlyPrice: r'$4.32',
          annualPrice: r'$43.21',
        ),
        testStoreMode: true,
      );
      addTearDown(controller.dispose);

      await controller.refresh();

      expect(controller.snapshot.catalogReady, isTrue);
      expect(controller.snapshot.monthly!.priceString, r'$4.32');
      expect(controller.snapshot.annual!.priceString, r'$43.21');
      expect(controller.snapshot.monthly!.subscriptionPeriod, 'P1M');
      expect(controller.snapshot.annual!.subscriptionPeriod, 'P1Y');
      expect(controller.snapshot.isPlusUnlocked, isFalse);
    },
  );

  test(
    'production customer catalog rejects Test Store product identifiers',
    () async {
      final _SequenceEntitlementSource entitlement =
          _SequenceEntitlementSource(<bool>[false]);
      addTearDown(entitlement.dispose);

      final BreakWavePlusController controller = _controller(
        entitlement: entitlement,
        executor: _FakeExecutor(
          purchaseResult: RevenueCatPurchaseExecutorResult.completed,
        ),
        catalog: _testStoreCatalog(
          monthlyPrice: r'$1.23',
          annualPrice: r'$12.34',
        ),
        testStoreMode: false,
      );
      addTearDown(controller.dispose);

      await controller.refresh();

      expect(controller.snapshot.catalogReady, isFalse);
      expect(controller.snapshot.monthly, isNull);
      expect(controller.snapshot.annual, isNull);
    },
  );

  test(
    'purchase uses lifecycle then a trusted reread before showing Plus',
    () async {
      final _SequenceEntitlementSource entitlement =
          _SequenceEntitlementSource(<bool>[false, false, true]);
      addTearDown(entitlement.dispose);

      final _FakeExecutor executor = _FakeExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.completed,
      );

      final BreakWavePlusController controller = _controller(
        entitlement: entitlement,
        executor: executor,
        catalog: _testStoreCatalog(
          monthlyPrice: r'$9.99',
          annualPrice: r'$79.98',
        ),
        testStoreMode: true,
      );
      addTearDown(controller.dispose);

      await controller.refresh();
      expect(controller.snapshot.isPlusUnlocked, isFalse);

      await controller.purchaseMonthly();

      expect(executor.purchaseCalls, 1);
      expect(
        executor.lastPackageIdentifier,
        RevenueCatCatalogContract.monthlyPackageIdentifier,
      );
      expect(entitlement.readCount, 3);
      expect(controller.snapshot.isPlusUnlocked, isTrue);
    },
  );

  test(
    'restore re-reads trusted state and preserves valid Plus',
    () async {
      final _SequenceEntitlementSource entitlement =
          _SequenceEntitlementSource(<bool>[true, true, true]);
      addTearDown(entitlement.dispose);

      final BreakWavePlusController controller = _controller(
        entitlement: entitlement,
        executor: _FakeExecutor(
          purchaseResult: RevenueCatPurchaseExecutorResult.cancelled,
        ),
        catalog: _testStoreCatalog(
          monthlyPrice: r'$9.99',
          annualPrice: r'$79.98',
        ),
        testStoreMode: true,
      );
      addTearDown(controller.dispose);

      await controller.refresh();
      expect(controller.snapshot.isPlusUnlocked, isTrue);

      await controller.restorePurchases();
      expect(controller.snapshot.isPlusUnlocked, isTrue);
    },
  );
}

BreakWavePlusController _controller({
  required _SequenceEntitlementSource entitlement,
  required _FakeExecutor executor,
  required RevenueCatCatalogSnapshot catalog,
  required bool testStoreMode,
}) {
  final RevenueCatPurchaseLifecycleService lifecycle =
      RevenueCatPurchaseLifecycleService(
    executor: executor,
    entitlementSource: entitlement,
  );

  return BreakWavePlusController(
    catalogProvider: _FakeCatalogProvider(catalog),
    runtimeStatusProvider: const _ConfiguredRuntimeStatusProvider(),
    purchaseLifecycle: lifecycle,
    entitlementSource: entitlement,
    catalogPolicy: BreakWavePlusCatalogPolicy(
      testStoreMode: testStoreMode,
    ),
  );
}

RevenueCatCatalogSnapshot _testStoreCatalog({
  required String monthlyPrice,
  required String annualPrice,
}) {
  return RevenueCatCatalogSnapshot(
    currentOfferingIdentifier:
        RevenueCatCatalogContract.defaultOfferingId,
    launchOfferingFound: true,
    packages: <RevenueCatCatalogPackageRecord>[
      RevenueCatCatalogPackageRecord(
        packageIdentifier:
            RevenueCatCatalogContract.monthlyPackageIdentifier,
        packageType: 'monthly',
        storeProductIdentifier:
            RevenueCatCatalogContract.testStoreMonthlyProductIdentifier,
        priceString: monthlyPrice,
        subscriptionPeriod: 'P1M',
      ),
      RevenueCatCatalogPackageRecord(
        packageIdentifier:
            RevenueCatCatalogContract.annualPackageIdentifier,
        packageType: 'annual',
        storeProductIdentifier:
            RevenueCatCatalogContract.testStoreAnnualProductIdentifier,
        priceString: annualPrice,
        subscriptionPeriod: 'P1Y',
      ),
    ],
  );
}

class _SequenceEntitlementSource extends BreakWaveEntitlementSource {
  _SequenceEntitlementSource(this.values);

  final List<bool> values;
  int readCount = 0;
  final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async {
    readCount += 1;
    if (values.isEmpty) return false;
    if (values.length == 1) return values.first;
    return values.removeAt(0);
  }

  void dispose() {
    _changes.dispose();
  }
}

class _FakeExecutor extends RevenueCatPurchaseExecutor {
  _FakeExecutor({required this.purchaseResult});

  final RevenueCatPurchaseExecutorResult purchaseResult;
  int purchaseCalls = 0;
  String? lastPackageIdentifier;

  @override
  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  ) async {
    purchaseCalls += 1;
    lastPackageIdentifier = packageIdentifier;
    return purchaseResult;
  }

  @override
  Future<RevenueCatPurchaseExecutorResult> restorePurchases() async {
    return RevenueCatPurchaseExecutorResult.completed;
  }
}

class _FakeCatalogProvider extends RevenueCatCatalogProvider {
  const _FakeCatalogProvider(this.snapshot);
  final RevenueCatCatalogSnapshot snapshot;

  @override
  Future<RevenueCatCatalogSnapshot> load() async => snapshot;
}

class _ConfiguredRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const _ConfiguredRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() async => true;
}
