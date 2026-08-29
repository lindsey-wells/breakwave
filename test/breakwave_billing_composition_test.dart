import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/access/breakwave_feature.dart';
import 'package:breakwave/core/billing/breakwave_billing_composition.dart';
import 'package:breakwave/core/billing/breakwave_billing_qa_config.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';

void main() {
  test('normal builds keep the Billing QA console disabled', () {
    expect(BreakWaveBillingQaConfig.enabled, isFalse);
  });

  test(
    'one entitlement source powers access and purchase lifecycle',
    () async {
      final _FakeEntitlementSource entitlement =
          _FakeEntitlementSource(unlocked: true);
      addTearDown(entitlement.dispose);

      final _FakePurchaseExecutor executor =
          _FakePurchaseExecutor();

      final BreakWaveBillingComposition composition =
          BreakWaveBillingComposition(
        entitlementSource: entitlement,
        purchaseExecutor: executor,
        catalogProvider: const _FakeCatalogProvider(),
        runtimeStatusProvider:
            const _FakeRuntimeStatusProvider(),
      );

      expect(
        identical(
          composition.entitlementSource,
          entitlement,
        ),
        isTrue,
      );

      final bool rescueAvailable =
          await composition.accessService.isAvailable(
        BreakWaveFeature.rescueNow,
      );

      expect(rescueAvailable, isTrue);
      expect(
        entitlement.readCount,
        0,
        reason:
            'Rescue must not consult billing entitlement state.',
      );

      final bool plusAvailable =
          await composition.accessService.isAvailable(
        BreakWaveFeature.advancedRecoveryInsights,
      );

      expect(plusAvailable, isTrue);
      expect(entitlement.readCount, 1);

      final result =
          await composition.purchaseLifecycle.purchaseMonthly();

      expect(result.isPlusUnlocked, isTrue);
      expect(entitlement.readCount, 2);
      expect(executor.purchaseCalls, 1);
    },
  );

  test('composition disposal is idempotent', () {
    int disposeCalls = 0;

    final _FakeEntitlementSource entitlement =
        _FakeEntitlementSource(unlocked: false);
    addTearDown(entitlement.dispose);

    final BreakWaveBillingComposition composition =
        BreakWaveBillingComposition(
      entitlementSource: entitlement,
      purchaseExecutor: _FakePurchaseExecutor(),
      catalogProvider: const _FakeCatalogProvider(),
      runtimeStatusProvider:
          const _FakeRuntimeStatusProvider(),
      disposeEntitlementSource: () {
        disposeCalls += 1;
      },
    );

    composition.dispose();
    composition.dispose();

    expect(disposeCalls, 1);
  });
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
  int purchaseCalls = 0;

  @override
  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  ) async {
    purchaseCalls += 1;
    return RevenueCatPurchaseExecutorResult.completed;
  }

  @override
  Future<RevenueCatPurchaseExecutorResult>
      restorePurchases() async {
    return RevenueCatPurchaseExecutorResult.completed;
  }
}

class _FakeCatalogProvider
    extends RevenueCatCatalogProvider {
  const _FakeCatalogProvider();

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    return const RevenueCatCatalogSnapshot(
      currentOfferingIdentifier: 'default',
      launchOfferingFound: true,
      packages: <RevenueCatCatalogPackageRecord>[],
    );
  }
}

class _FakeRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const _FakeRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() async => true;
}
