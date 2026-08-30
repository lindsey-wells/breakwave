// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_controller.dart
// Purpose: Customer-facing Plus catalog, purchase, restore, and access state.
// Notes: UI-facing orchestration only; trusted entitlement remains authority.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../../core/access/breakwave_entitlement_source.dart';
import '../../../core/billing/breakwave_billing_composition.dart';
import '../../../core/billing/breakwave_billing_qa_config.dart';
import '../../../core/billing/revenuecat_catalog_contract.dart';
import '../../../core/billing/revenuecat_catalog_service.dart';
import '../../../core/billing/revenuecat_purchase_lifecycle.dart';

class BreakWavePlusPlanOption {
  const BreakWavePlusPlanOption({
    required this.packageIdentifier,
    required this.priceString,
    required this.subscriptionPeriod,
  });

  final String packageIdentifier;
  final String priceString;
  final String subscriptionPeriod;
}

class BreakWavePlusCatalogSelection {
  const BreakWavePlusCatalogSelection({
    required this.isReady,
    this.monthly,
    this.annual,
  });

  final bool isReady;
  final BreakWavePlusPlanOption? monthly;
  final BreakWavePlusPlanOption? annual;
}

class BreakWavePlusCatalogPolicy {
  const BreakWavePlusCatalogPolicy({
    required this.testStoreMode,
  });

  final bool testStoreMode;

  BreakWavePlusCatalogSelection validate(
    RevenueCatCatalogSnapshot snapshot,
  ) {
    if (!snapshot.launchOfferingFound ||
        snapshot.currentOfferingIdentifier !=
            RevenueCatCatalogContract.defaultOfferingId) {
      return const BreakWavePlusCatalogSelection(isReady: false);
    }

    if (!testStoreMode) {
      final RevenueCatCatalogValidation validation =
          const RevenueCatCatalogPolicy().validate(snapshot);

      if (!validation.isReady) {
        return const BreakWavePlusCatalogSelection(isReady: false);
      }
    }

    final Set<String> identifiers = <String>{};
    RevenueCatCatalogPackageRecord? monthly;
    RevenueCatCatalogPackageRecord? annual;

    for (final RevenueCatCatalogPackageRecord package
        in snapshot.packages) {
      if (!identifiers.add(package.packageIdentifier)) {
        return const BreakWavePlusCatalogSelection(isReady: false);
      }

      if (package.packageIdentifier ==
          RevenueCatCatalogContract.monthlyPackageIdentifier) {
        monthly = package;
      }

      if (package.packageIdentifier ==
          RevenueCatCatalogContract.annualPackageIdentifier) {
        annual = package;
      }
    }

    if (monthly == null || annual == null) {
      return const BreakWavePlusCatalogSelection(isReady: false);
    }

    if (!_hasDisplayData(monthly) || !_hasDisplayData(annual)) {
      return const BreakWavePlusCatalogSelection(isReady: false);
    }

    if (testStoreMode) {
      if (monthly.storeProductIdentifier !=
              RevenueCatCatalogContract
                  .testStoreMonthlyProductIdentifier ||
          annual.storeProductIdentifier !=
              RevenueCatCatalogContract
                  .testStoreAnnualProductIdentifier) {
        return const BreakWavePlusCatalogSelection(isReady: false);
      }
    }

    return BreakWavePlusCatalogSelection(
      isReady: true,
      monthly: _plan(monthly),
      annual: _plan(annual),
    );
  }

  bool _hasDisplayData(
    RevenueCatCatalogPackageRecord package,
  ) {
    return package.priceString.trim().isNotEmpty &&
        (package.subscriptionPeriod ?? '').trim().isNotEmpty;
  }

  BreakWavePlusPlanOption _plan(
    RevenueCatCatalogPackageRecord package,
  ) {
    return BreakWavePlusPlanOption(
      packageIdentifier: package.packageIdentifier,
      priceString: package.priceString.trim(),
      subscriptionPeriod: package.subscriptionPeriod!.trim(),
    );
  }
}

class BreakWavePlusSnapshot {
  const BreakWavePlusSnapshot({
    required this.loading,
    required this.busy,
    required this.revenueCatConfigured,
    required this.isPlusUnlocked,
    required this.catalogReady,
    required this.monthly,
    required this.annual,
    required this.notice,
    required this.lifecycleStatus,
  });

  const BreakWavePlusSnapshot.initial()
      : loading = true,
        busy = false,
        revenueCatConfigured = false,
        isPlusUnlocked = false,
        catalogReady = false,
        monthly = null,
        annual = null,
        notice = null,
        lifecycleStatus = null;

  final bool loading;
  final bool busy;
  final bool revenueCatConfigured;
  final bool isPlusUnlocked;
  final bool catalogReady;
  final BreakWavePlusPlanOption? monthly;
  final BreakWavePlusPlanOption? annual;
  final String? notice;
  final RevenueCatPurchaseLifecycleStatus? lifecycleStatus;
}

class BreakWavePlusController extends ChangeNotifier {
  BreakWavePlusController({
    required RevenueCatCatalogProvider catalogProvider,
    required RevenueCatRuntimeStatusProvider runtimeStatusProvider,
    required RevenueCatPurchaseLifecycleService purchaseLifecycle,
    required BreakWaveEntitlementSource entitlementSource,
    required BreakWavePlusCatalogPolicy catalogPolicy,
  })  : _catalogProvider = catalogProvider,
        _runtimeStatusProvider = runtimeStatusProvider,
        _purchaseLifecycle = purchaseLifecycle,
        _entitlementSource = entitlementSource,
        _catalogPolicy = catalogPolicy;

  factory BreakWavePlusController.fromComposition(
    BreakWaveBillingComposition composition,
  ) {
    return BreakWavePlusController(
      catalogProvider: composition.catalogProvider,
      runtimeStatusProvider: composition.runtimeStatusProvider,
      purchaseLifecycle: composition.purchaseLifecycle,
      entitlementSource: composition.entitlementSource,
      catalogPolicy: const BreakWavePlusCatalogPolicy(
        testStoreMode: BreakWaveBillingQaConfig.enabled,
      ),
    );
  }

  final RevenueCatCatalogProvider _catalogProvider;
  final RevenueCatRuntimeStatusProvider _runtimeStatusProvider;
  final RevenueCatPurchaseLifecycleService _purchaseLifecycle;
  final BreakWaveEntitlementSource _entitlementSource;
  final BreakWavePlusCatalogPolicy _catalogPolicy;

  BreakWavePlusSnapshot _snapshot =
      const BreakWavePlusSnapshot.initial();

  BreakWavePlusSnapshot get snapshot => _snapshot;

  Future<void> refresh() async {
    await _load(
      lifecycleStatus: _snapshot.lifecycleStatus,
      notice: _snapshot.notice,
    );
  }

  Future<void> purchaseMonthly() async {
    if (!_snapshot.catalogReady ||
        _snapshot.monthly == null ||
        _snapshot.busy) {
      return;
    }

    await _runLifecycle(
      () => _purchaseLifecycle.purchaseMonthly(),
    );
  }

  Future<void> purchaseAnnual() async {
    if (!_snapshot.catalogReady ||
        _snapshot.annual == null ||
        _snapshot.busy) {
      return;
    }

    await _runLifecycle(
      () => _purchaseLifecycle.purchaseAnnual(),
    );
  }

  Future<void> restorePurchases() async {
    if (_snapshot.busy) return;

    await _runLifecycle(
      _purchaseLifecycle.restorePurchases,
    );
  }

  Future<void> _runLifecycle(
    Future<RevenueCatPurchaseLifecycleResult> Function() operation,
  ) async {
    _snapshot = BreakWavePlusSnapshot(
      loading: false,
      busy: true,
      revenueCatConfigured: _snapshot.revenueCatConfigured,
      isPlusUnlocked: _snapshot.isPlusUnlocked,
      catalogReady: _snapshot.catalogReady,
      monthly: _snapshot.monthly,
      annual: _snapshot.annual,
      notice: null,
      lifecycleStatus: _snapshot.lifecycleStatus,
    );
    notifyListeners();

    RevenueCatPurchaseLifecycleResult result;

    try {
      result = await operation();
    } catch (_) {
      result = const RevenueCatPurchaseLifecycleResult(
        status: RevenueCatPurchaseLifecycleStatus.failed,
        isPlusUnlocked: false,
      );
    }

    await _load(
      lifecycleStatus: result.status,
      notice: _noticeFor(result.status),
    );
  }

  Future<void> _load({
    RevenueCatPurchaseLifecycleStatus? lifecycleStatus,
    String? notice,
  }) async {
    if (!_snapshot.busy) {
      _snapshot = BreakWavePlusSnapshot(
        loading: true,
        busy: false,
        revenueCatConfigured: _snapshot.revenueCatConfigured,
        isPlusUnlocked: _snapshot.isPlusUnlocked,
        catalogReady: _snapshot.catalogReady,
        monthly: _snapshot.monthly,
        annual: _snapshot.annual,
        notice: notice,
        lifecycleStatus: lifecycleStatus,
      );
      notifyListeners();
    }

    bool configured = false;
    bool unlocked = false;
    BreakWavePlusCatalogSelection catalog =
        const BreakWavePlusCatalogSelection(isReady: false);

    try {
      configured = await _runtimeStatusProvider.isConfigured();
    } catch (_) {
      configured = false;
    }

    try {
      unlocked = await _entitlementSource.isPlusUnlocked();
    } catch (_) {
      unlocked = false;
    }

    if (configured) {
      try {
        final RevenueCatCatalogSnapshot snapshot =
            await _catalogProvider.load();
        catalog = _catalogPolicy.validate(snapshot);
      } catch (_) {
        catalog =
            const BreakWavePlusCatalogSelection(isReady: false);
      }
    }

    String? finalNotice = notice;

    if (unlocked &&
        lifecycleStatus ==
            RevenueCatPurchaseLifecycleStatus
                .completedButNotVerified) {
      finalNotice =
          'Purchase verification completed. BreakWave Plus is active.';
    }

    _snapshot = BreakWavePlusSnapshot(
      loading: false,
      busy: false,
      revenueCatConfigured: configured,
      isPlusUnlocked: unlocked,
      catalogReady: catalog.isReady,
      monthly: catalog.monthly,
      annual: catalog.annual,
      notice: finalNotice,
      lifecycleStatus: lifecycleStatus,
    );
    notifyListeners();
  }

  String _noticeFor(
    RevenueCatPurchaseLifecycleStatus status,
  ) {
    return switch (status) {
      RevenueCatPurchaseLifecycleStatus.purchaseActivated =>
        'Purchase verified. BreakWave Plus is active.',
      RevenueCatPurchaseLifecycleStatus.restoreActivated =>
        'Purchases restored. BreakWave Plus is active.',
      RevenueCatPurchaseLifecycleStatus.completedButNotVerified =>
        'The store completed the action, but Plus is still being verified. Refresh access shortly.',
      RevenueCatPurchaseLifecycleStatus.cancelled =>
        'Purchase canceled. Your existing access was not changed.',
      RevenueCatPurchaseLifecycleStatus.packageUnavailable =>
        'That plan is not available from the store right now.',
      RevenueCatPurchaseLifecycleStatus.failed =>
        'The store action did not complete. Your existing access was not changed.',
    };
  }
}
