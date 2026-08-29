// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_purchase_lifecycle.dart
// Purpose: Fail-closed purchase/restore orchestration.
// Notes: Trusted entitlement source is the only Plus authority.
// ------------------------------------------------------------

import '../access/breakwave_entitlement_source.dart';
import 'revenuecat_catalog_contract.dart';
import 'revenuecat_purchase_executor.dart';

enum RevenueCatPurchaseLifecycleStatus {
  purchaseActivated,
  restoreActivated,
  completedButNotVerified,
  cancelled,
  packageUnavailable,
  failed,
}

class RevenueCatPurchaseLifecycleResult {
  const RevenueCatPurchaseLifecycleResult({
    required this.status,
    required this.isPlusUnlocked,
  });

  final RevenueCatPurchaseLifecycleStatus status;
  final bool isPlusUnlocked;
}

class RevenueCatPurchaseLifecycleService {
  const RevenueCatPurchaseLifecycleService({
    required RevenueCatPurchaseExecutor executor,
    required BreakWaveEntitlementSource entitlementSource,
  })  : _executor = executor,
        _entitlementSource = entitlementSource;

  final RevenueCatPurchaseExecutor _executor;
  final BreakWaveEntitlementSource _entitlementSource;

  Future<RevenueCatPurchaseLifecycleResult> purchaseMonthly() {
    return purchasePackage(
      RevenueCatCatalogContract.monthlyPackageIdentifier,
    );
  }

  Future<RevenueCatPurchaseLifecycleResult> purchaseAnnual() {
    return purchasePackage(
      RevenueCatCatalogContract.annualPackageIdentifier,
    );
  }

  Future<RevenueCatPurchaseLifecycleResult> purchasePackage(
    String packageIdentifier,
  ) async {
    if (!RevenueCatCatalogContract
        .isSupportedPurchasePackage(packageIdentifier)) {
      return const RevenueCatPurchaseLifecycleResult(
        status: RevenueCatPurchaseLifecycleStatus.packageUnavailable,
        isPlusUnlocked: false,
      );
    }

    final RevenueCatPurchaseExecutorResult execution =
        await _executor.purchasePackage(packageIdentifier);

    switch (execution) {
      case RevenueCatPurchaseExecutorResult.completed:
        final bool unlocked = await _readTrustedPlusState();

        return RevenueCatPurchaseLifecycleResult(
          status: unlocked
              ? RevenueCatPurchaseLifecycleStatus.purchaseActivated
              : RevenueCatPurchaseLifecycleStatus.completedButNotVerified,
          isPlusUnlocked: unlocked,
        );

      case RevenueCatPurchaseExecutorResult.cancelled:
        return const RevenueCatPurchaseLifecycleResult(
          status: RevenueCatPurchaseLifecycleStatus.cancelled,
          isPlusUnlocked: false,
        );

      case RevenueCatPurchaseExecutorResult.packageUnavailable:
        return const RevenueCatPurchaseLifecycleResult(
          status: RevenueCatPurchaseLifecycleStatus.packageUnavailable,
          isPlusUnlocked: false,
        );

      case RevenueCatPurchaseExecutorResult.failed:
        return const RevenueCatPurchaseLifecycleResult(
          status: RevenueCatPurchaseLifecycleStatus.failed,
          isPlusUnlocked: false,
        );
    }
  }

  Future<RevenueCatPurchaseLifecycleResult> restorePurchases() async {
    final RevenueCatPurchaseExecutorResult execution =
        await _executor.restorePurchases();

    if (execution != RevenueCatPurchaseExecutorResult.completed) {
      return const RevenueCatPurchaseLifecycleResult(
        status: RevenueCatPurchaseLifecycleStatus.failed,
        isPlusUnlocked: false,
      );
    }

    final bool unlocked = await _readTrustedPlusState();

    return RevenueCatPurchaseLifecycleResult(
      status: unlocked
          ? RevenueCatPurchaseLifecycleStatus.restoreActivated
          : RevenueCatPurchaseLifecycleStatus.completedButNotVerified,
      isPlusUnlocked: unlocked,
    );
  }

  Future<bool> _readTrustedPlusState() async {
    try {
      // This triggers the WP-03T trusted CustomerInfo path.
      // Purchase/restore callback objects cannot bypass it.
      return await _entitlementSource.isPlusUnlocked();
    } catch (_) {
      return false;
    }
  }
}
