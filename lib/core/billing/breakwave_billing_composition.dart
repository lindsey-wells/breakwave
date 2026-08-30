// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_billing_composition.dart
// Purpose: Shared production billing composition for access and purchase.
// Notes: One trusted entitlement source powers both paths.
// ------------------------------------------------------------

import 'package:purchases_flutter/purchases_flutter.dart';

import '../access/breakwave_access_service.dart';
import '../access/breakwave_entitlement_source.dart';
import 'revenuecat_catalog_service.dart';
import 'revenuecat_entitlement_source.dart';
import 'revenuecat_purchase_executor.dart';
import 'revenuecat_purchase_lifecycle.dart';

abstract class RevenueCatRuntimeStatusProvider {
  const RevenueCatRuntimeStatusProvider();

  Future<bool> isConfigured();
}

class RevenueCatSdkRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const RevenueCatSdkRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() {
    return Purchases.isConfigured;
  }
}

class BreakWaveBillingComposition {
  BreakWaveBillingComposition({
    required BreakWaveEntitlementSource entitlementSource,
    required RevenueCatPurchaseExecutor purchaseExecutor,
    required RevenueCatCatalogProvider catalogProvider,
    required RevenueCatRuntimeStatusProvider runtimeStatusProvider,
    RevenueCatEntitlementDiagnosticsProvider?
        entitlementDiagnosticsProvider,
    void Function()? disposeEntitlementSource,
  })  : entitlementSource = entitlementSource,
        accessService = BreakWaveAccessService(
          entitlementSource: entitlementSource,
        ),
        purchaseLifecycle = RevenueCatPurchaseLifecycleService(
          executor: purchaseExecutor,
          entitlementSource: entitlementSource,
        ),
        catalogProvider = catalogProvider,
        runtimeStatusProvider = runtimeStatusProvider,
        entitlementDiagnosticsProvider =
            entitlementDiagnosticsProvider,
        _disposeEntitlementSource = disposeEntitlementSource;

  factory BreakWaveBillingComposition.production() {
    final RevenueCatEntitlementSource entitlementSource =
        RevenueCatEntitlementSource.production();

    return BreakWaveBillingComposition(
      entitlementSource: entitlementSource,
      purchaseExecutor: const RevenueCatSdkPurchaseExecutor(),
      catalogProvider: const RevenueCatSdkCatalogProvider(),
      runtimeStatusProvider:
          const RevenueCatSdkRuntimeStatusProvider(),
      entitlementDiagnosticsProvider: entitlementSource,
      disposeEntitlementSource: entitlementSource.dispose,
    );
  }

  final BreakWaveEntitlementSource entitlementSource;
  final BreakWaveAccessService accessService;
  final RevenueCatPurchaseLifecycleService purchaseLifecycle;
  final RevenueCatCatalogProvider catalogProvider;
  final RevenueCatRuntimeStatusProvider runtimeStatusProvider;
  final RevenueCatEntitlementDiagnosticsProvider?
      entitlementDiagnosticsProvider;

  final void Function()? _disposeEntitlementSource;
  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _disposeEntitlementSource?.call();
  }
}
