import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/billing/breakwave_billing_composition.dart';
import 'package:breakwave/core/billing/breakwave_billing_scope.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget buildBreakWaveBillingTestApp({required Widget home}) {
  return BreakWaveBillingScope(
    composition: BreakWaveBillingComposition(
      entitlementSource: const _LockedTestEntitlementSource(),
      purchaseExecutor: const _FailClosedTestPurchaseExecutor(),
      catalogProvider: const _UnavailableTestCatalogProvider(),
      runtimeStatusProvider: const _UnconfiguredTestRuntimeStatusProvider(),
    ),
    child: MaterialApp(home: home),
  );
}

class _LockedTestEntitlementSource extends BreakWaveEntitlementSource {
  const _LockedTestEntitlementSource();

  @override
  ValueListenable<int> get changes =>
      const AlwaysStoppedAnimation<int>(0);

  @override
  Future<bool> isPlusUnlocked() async => false;
}

class _FailClosedTestPurchaseExecutor extends RevenueCatPurchaseExecutor {
  const _FailClosedTestPurchaseExecutor();

  @override
  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  ) async {
    return RevenueCatPurchaseExecutorResult.failed;
  }

  @override
  Future<RevenueCatPurchaseExecutorResult> restorePurchases() async {
    return RevenueCatPurchaseExecutorResult.failed;
  }
}

class _UnavailableTestCatalogProvider extends RevenueCatCatalogProvider {
  const _UnavailableTestCatalogProvider();

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    return const RevenueCatCatalogSnapshot(
      currentOfferingIdentifier: null,
      launchOfferingFound: false,
      packages: <RevenueCatCatalogPackageRecord>[],
    );
  }
}

class _UnconfiguredTestRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const _UnconfiguredTestRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() async => false;
}
