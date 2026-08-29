import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_contract.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_lifecycle.dart';

void main() {
  test('monthly and annual package IDs are locked', () {
    expect(
      RevenueCatCatalogContract.monthlyPackageIdentifier,
      r'$rc_monthly',
    );
    expect(
      RevenueCatCatalogContract.annualPackageIdentifier,
      r'$rc_annual',
    );
  });

  test('current Test Store product IDs are QA-only constants', () {
    expect(
      RevenueCatCatalogContract.testStoreMonthlyProductIdentifier,
      'monthly',
    );
    expect(
      RevenueCatCatalogContract.testStoreAnnualProductIdentifier,
      'yearly',
    );
  });

  test(
    'successful purchase requires separate trusted entitlement read',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.completed,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseMonthly();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.purchaseActivated,
      );
      expect(result.isPlusUnlocked, isTrue);
      expect(executor.purchaseCalls, 1);
      expect(executor.lastPackageIdentifier, r'$rc_monthly');
      expect(entitlement.readCount, 1);
    },
  );

  test(
    'completed purchase stays locked when trusted source denies Plus',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.completed,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: false);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseAnnual();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.completedButNotVerified,
      );
      expect(result.isPlusUnlocked, isFalse);
      expect(entitlement.readCount, 1);
    },
  );

  test(
    'purchase cancellation does not fabricate or read Plus',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.cancelled,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseMonthly();

      expect(result.status, RevenueCatPurchaseLifecycleStatus.cancelled);
      expect(result.isPlusUnlocked, isFalse);
      expect(entitlement.readCount, 0);
    },
  );

  test(
    'missing package fails without trusted entitlement read',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.packageUnavailable,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseMonthly();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.packageUnavailable,
      );
      expect(entitlement.readCount, 0);
    },
  );

  test(
    'transport failure fails closed without entitlement read',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.failed,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseMonthly();

      expect(result.status, RevenueCatPurchaseLifecycleStatus.failed);
      expect(result.isPlusUnlocked, isFalse);
      expect(entitlement.readCount, 0);
    },
  );

  test(
    'trusted entitlement exception after purchase fails closed',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        purchaseResult: RevenueCatPurchaseExecutorResult.completed,
      );
      final _FakeEntitlementSource entitlement = _FakeEntitlementSource(
        unlocked: true,
        error: StateError('trusted read failed'),
      );
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.purchaseMonthly();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.completedButNotVerified,
      );
      expect(result.isPlusUnlocked, isFalse);
      expect(entitlement.readCount, 1);
    },
  );

  test(
    'successful restore still requires trusted entitlement verification',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        restoreResult: RevenueCatPurchaseExecutorResult.completed,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.restorePurchases();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.restoreActivated,
      );
      expect(result.isPlusUnlocked, isTrue);
      expect(executor.restoreCalls, 1);
      expect(entitlement.readCount, 1);
    },
  );

  test(
    'restore completion cannot unlock without trusted state',
    () async {
      final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
        restoreResult: RevenueCatPurchaseExecutorResult.completed,
      );
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: false);
      addTearDown(entitlement.dispose);

      final RevenueCatPurchaseLifecycleService service =
          RevenueCatPurchaseLifecycleService(
        executor: executor,
        entitlementSource: entitlement,
      );

      final RevenueCatPurchaseLifecycleResult result =
          await service.restorePurchases();

      expect(
        result.status,
        RevenueCatPurchaseLifecycleStatus.completedButNotVerified,
      );
      expect(result.isPlusUnlocked, isFalse);
      expect(entitlement.readCount, 1);
    },
  );

  test('restore transport failure fails closed', () async {
    final _FakePurchaseExecutor executor = _FakePurchaseExecutor(
      restoreResult: RevenueCatPurchaseExecutorResult.failed,
    );
    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: true);
    addTearDown(entitlement.dispose);

    final RevenueCatPurchaseLifecycleService service =
        RevenueCatPurchaseLifecycleService(
      executor: executor,
      entitlementSource: entitlement,
    );

    final RevenueCatPurchaseLifecycleResult result =
        await service.restorePurchases();

    expect(result.status, RevenueCatPurchaseLifecycleStatus.failed);
    expect(result.isPlusUnlocked, isFalse);
    expect(entitlement.readCount, 0);
  });
}

class _FakePurchaseExecutor extends RevenueCatPurchaseExecutor {
  _FakePurchaseExecutor({
    this.purchaseResult = RevenueCatPurchaseExecutorResult.completed,
    this.restoreResult = RevenueCatPurchaseExecutorResult.completed,
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
  Future<RevenueCatPurchaseExecutorResult> restorePurchases() async {
    restoreCalls += 1;
    return restoreResult;
  }
}

class _FakeEntitlementSource extends BreakWaveEntitlementSource {
  _FakeEntitlementSource({
    required this.unlocked,
    this.error,
  });

  final bool unlocked;
  final Object? error;
  int readCount = 0;
  final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async {
    readCount += 1;
    if (error != null) {
      throw error!;
    }
    return unlocked;
  }

  void dispose() {
    _changes.dispose();
  }
}
