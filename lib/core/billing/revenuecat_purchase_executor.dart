// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_purchase_executor.dart
// Purpose: Narrow RevenueCat purchase/restore transport adapter.
// Notes: Transport completion is never Plus entitlement authority.
// ------------------------------------------------------------

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_catalog_contract.dart';

enum RevenueCatPurchaseExecutorResult {
  completed,
  cancelled,
  packageUnavailable,
  failed,
}

abstract class RevenueCatPurchaseExecutor {
  const RevenueCatPurchaseExecutor();

  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  );

  Future<RevenueCatPurchaseExecutorResult> restorePurchases();
}

class RevenueCatSdkPurchaseExecutor
    extends RevenueCatPurchaseExecutor {
  const RevenueCatSdkPurchaseExecutor();

  @override
  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  ) async {
    if (!RevenueCatCatalogContract
        .isSupportedPurchasePackage(packageIdentifier)) {
      return RevenueCatPurchaseExecutorResult.packageUnavailable;
    }

    try {
      if (!await Purchases.isConfigured) {
        return RevenueCatPurchaseExecutorResult.failed;
      }

      final Offerings offerings = await Purchases.getOfferings();

      final Offering? offering = offerings.getOffering(
        RevenueCatCatalogContract.defaultOfferingId,
      );

      if (offering == null) {
        return RevenueCatPurchaseExecutorResult.packageUnavailable;
      }

      Package? package;

      for (final Package candidate in offering.availablePackages) {
        if (candidate.identifier == packageIdentifier) {
          package = candidate;
          break;
        }
      }

      if (package == null) {
        return RevenueCatPurchaseExecutorResult.packageUnavailable;
      }

      // Intentionally ignore PurchaseResult.customerInfo.
      // Purchase completion is not BreakWave Plus authority.
      await Purchases.purchase(
        PurchaseParams.package(package),
      );

      return RevenueCatPurchaseExecutorResult.completed;
    } on PlatformException catch (error) {
      final PurchasesErrorCode code =
          PurchasesErrorHelper.getErrorCode(error);

      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return RevenueCatPurchaseExecutorResult.cancelled;
      }

      return RevenueCatPurchaseExecutorResult.failed;
    } catch (_) {
      return RevenueCatPurchaseExecutorResult.failed;
    }
  }

  @override
  Future<RevenueCatPurchaseExecutorResult> restorePurchases() async {
    try {
      if (!await Purchases.isConfigured) {
        return RevenueCatPurchaseExecutorResult.failed;
      }

      // Intentionally ignore the returned CustomerInfo.
      // Restore completion is not BreakWave Plus authority.
      await Purchases.restorePurchases();

      return RevenueCatPurchaseExecutorResult.completed;
    } catch (_) {
      return RevenueCatPurchaseExecutorResult.failed;
    }
  }
}
