import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/billing/breakwave_billing_composition.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_contract.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_lifecycle.dart';
import 'package:breakwave/features/billing_qa/application/billing_qa_controller.dart';

void main() {
  test('valid Test Store catalog is ready', () async {
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: false);
    addTearDown(entitlement.dispose);

    final BreakWaveBillingQaController controller =
        _controller(
      entitlement: entitlement,
      catalog: _validCatalog(),
    );

    final BreakWaveBillingQaSnapshot snapshot =
        await controller.refresh();

    expect(snapshot.configured, isTrue);
    expect(snapshot.catalogReady, isTrue);
    expect(snapshot.catalogIssues, isEmpty);
    expect(snapshot.trustedPlusUnlocked, isFalse);
  });

  test('missing annual Test Store package is not ready', () async {
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: false);
    addTearDown(entitlement.dispose);

    final RevenueCatCatalogSnapshot catalog =
        RevenueCatCatalogSnapshot(
      currentOfferingIdentifier:
          RevenueCatCatalogContract.defaultOfferingId,
      launchOfferingFound: true,
      packages: <RevenueCatCatalogPackageRecord>[
        _monthlyPackage(),
      ],
    );

    final BreakWaveBillingQaSnapshot snapshot =
        await _controller(
      entitlement: entitlement,
      catalog: catalog,
    ).refresh();

    expect(snapshot.catalogReady, isFalse);
    expect(
      snapshot.catalogIssues.any(
        (String issue) => issue.contains(
          RevenueCatCatalogContract.annualPackageIdentifier,
        ),
      ),
      isTrue,
    );
  });

  test('wrong Test Store product mapping is not ready', () async {
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: false);
    addTearDown(entitlement.dispose);

    final RevenueCatCatalogSnapshot catalog =
        RevenueCatCatalogSnapshot(
      currentOfferingIdentifier:
          RevenueCatCatalogContract.defaultOfferingId,
      launchOfferingFound: true,
      packages: <RevenueCatCatalogPackageRecord>[
        _monthlyPackage(
          productIdentifier: 'wrong-monthly-product',
        ),
        _annualPackage(),
      ],
    );

    final BreakWaveBillingQaSnapshot snapshot =
        await _controller(
      entitlement: entitlement,
      catalog: catalog,
    ).refresh();

    expect(snapshot.catalogReady, isFalse);
    expect(
      snapshot.catalogIssues.any(
        (String issue) => issue.contains(
          'wrong-monthly-product',
        ),
      ),
      isTrue,
    );
  });

  test(
    'monthly purchase uses lifecycle and reports trusted Plus',
    () async {
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final _FakePurchaseExecutor executor =
          _FakePurchaseExecutor(
        purchaseResult:
            RevenueCatPurchaseExecutorResult.completed,
      );

      final BreakWaveBillingQaController controller =
          _controller(
        entitlement: entitlement,
        catalog: _validCatalog(),
        executor: executor,
      );

      final BreakWaveBillingQaActionResult result =
          await controller.purchaseMonthly();

      expect(
        result.lifecycleResult.status,
        RevenueCatPurchaseLifecycleStatus.purchaseActivated,
      );
      expect(result.snapshot.trustedPlusUnlocked, isTrue);
      expect(executor.purchaseCalls, 1);
      expect(
        executor.lastPackageIdentifier,
        RevenueCatCatalogContract.monthlyPackageIdentifier,
      );
      expect(
        entitlement.readCount,
        1,
        reason:
            'Controller must use the lifecycle trusted read, '
            'not invent a second purchase authority.',
      );
    },
  );

  test(
    'cancelled purchase never fabricates activation',
    () async {
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: false);
      addTearDown(entitlement.dispose);

      final _FakePurchaseExecutor executor =
          _FakePurchaseExecutor(
        purchaseResult:
            RevenueCatPurchaseExecutorResult.cancelled,
      );

      final BreakWaveBillingQaActionResult result =
          await _controller(
        entitlement: entitlement,
        catalog: _validCatalog(),
        executor: executor,
      ).purchaseMonthly();

      expect(
        result.lifecycleResult.status,
        RevenueCatPurchaseLifecycleStatus.cancelled,
      );
      expect(
        result.lifecycleResult.isPlusUnlocked,
        isFalse,
      );
      expect(result.snapshot.trustedPlusUnlocked, isFalse);
      expect(
        entitlement.readCount,
        1,
        reason:
            'The lifecycle does not authorize cancellation; '
            'the QA snapshot separately refreshes current '
            'trusted state for accurate display.',
      );
    },
  );

  test('restore uses lifecycle trusted authority', () async {
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: true);
    addTearDown(entitlement.dispose);

    final _FakePurchaseExecutor executor =
        _FakePurchaseExecutor(
      restoreResult:
          RevenueCatPurchaseExecutorResult.completed,
    );

    final BreakWaveBillingQaActionResult result =
        await _controller(
      entitlement: entitlement,
      catalog: _validCatalog(),
      executor: executor,
    ).restorePurchases();

    expect(
      result.lifecycleResult.status,
      RevenueCatPurchaseLifecycleStatus.restoreActivated,
    );
    expect(result.snapshot.trustedPlusUnlocked, isTrue);
    expect(executor.restoreCalls, 1);
    expect(entitlement.readCount, 1);
  });

  test('catalog provider failure degrades safely', () async {
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: false);
    addTearDown(entitlement.dispose);

    final BreakWaveBillingQaController controller =
        BreakWaveBillingQaController(
      runtimeStatusProvider:
          const _FakeRuntimeStatusProvider(),
      catalogProvider:
          const _ThrowingCatalogProvider(),
      purchaseLifecycle:
          RevenueCatPurchaseLifecycleService(
        executor: _FakePurchaseExecutor(),
        entitlementSource: entitlement,
      ),
      entitlementSource: entitlement,
    );

    final BreakWaveBillingQaSnapshot snapshot =
        await controller.refresh();

    expect(snapshot.catalogReady, isFalse);
    expect(snapshot.packages, isEmpty);
    expect(snapshot.errorMessage, isNotNull);
    expect(snapshot.trustedPlusUnlocked, isFalse);
  });
}

BreakWaveBillingQaController _controller({
  required _FakeEntitlementSource entitlement,
  required RevenueCatCatalogSnapshot catalog,
  _FakePurchaseExecutor? executor,
}) {
  final _FakePurchaseExecutor purchaseExecutor =
      executor ?? _FakePurchaseExecutor();

  return BreakWaveBillingQaController(
    runtimeStatusProvider:
        const _FakeRuntimeStatusProvider(),
    catalogProvider: _FakeCatalogProvider(catalog),
    purchaseLifecycle:
        RevenueCatPurchaseLifecycleService(
      executor: purchaseExecutor,
      entitlementSource: entitlement,
    ),
    entitlementSource: entitlement,
  );
}

RevenueCatCatalogSnapshot _validCatalog() {
  return RevenueCatCatalogSnapshot(
    currentOfferingIdentifier:
        RevenueCatCatalogContract.defaultOfferingId,
    launchOfferingFound: true,
    packages: <RevenueCatCatalogPackageRecord>[
      _monthlyPackage(),
      _annualPackage(),
    ],
  );
}

RevenueCatCatalogPackageRecord _monthlyPackage({
  String? productIdentifier,
}) {
  return RevenueCatCatalogPackageRecord(
    packageIdentifier:
        RevenueCatCatalogContract.monthlyPackageIdentifier,
    packageType: 'monthly',
    storeProductIdentifier: productIdentifier ??
        RevenueCatCatalogContract
            .testStoreMonthlyProductIdentifier,
    priceString: 'test-price-monthly',
    subscriptionPeriod: 'P1M',
  );
}

RevenueCatCatalogPackageRecord _annualPackage() {
  return RevenueCatCatalogPackageRecord(
    packageIdentifier:
        RevenueCatCatalogContract.annualPackageIdentifier,
    packageType: 'annual',
    storeProductIdentifier:
        RevenueCatCatalogContract
            .testStoreAnnualProductIdentifier,
    priceString: 'test-price-annual',
    subscriptionPeriod: 'P1Y',
  );
}

class _FakeEntitlementSource
    extends BreakWaveEntitlementSource {
  _FakeEntitlementSource({
    required this.unlocked,
  });

  final bool unlocked;
  int readCount = 0;

  final ValueNotifier<int> _changes =
      ValueNotifier<int>(0);

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async {
    readCount += 1;
    return unlocked;
  }

  void dispose() {
    _changes.dispose();
  }
}

class _FakePurchaseExecutor
    extends RevenueCatPurchaseExecutor {
  _FakePurchaseExecutor({
    this.purchaseResult =
        RevenueCatPurchaseExecutorResult.completed,
    this.restoreResult =
        RevenueCatPurchaseExecutorResult.completed,
  });

  final RevenueCatPurchaseExecutorResult purchaseResult;
  final RevenueCatPurchaseExecutorResult restoreResult;

  int purchaseCalls = 0;
  int restoreCalls = 0;
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
  Future<RevenueCatPurchaseExecutorResult>
      restorePurchases() async {
    restoreCalls += 1;
    return restoreResult;
  }
}

class _FakeCatalogProvider
    extends RevenueCatCatalogProvider {
  const _FakeCatalogProvider(this.snapshot);

  final RevenueCatCatalogSnapshot snapshot;

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    return snapshot;
  }
}

class _ThrowingCatalogProvider
    extends RevenueCatCatalogProvider {
  const _ThrowingCatalogProvider();

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    throw StateError('catalog unavailable');
  }
}

class _FakeRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const _FakeRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() async => true;
}
