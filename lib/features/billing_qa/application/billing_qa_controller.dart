// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: billing_qa_controller.dart
// Purpose: Test Store QA orchestration without direct purchase SDK calls.
// ------------------------------------------------------------

import '../../../core/access/breakwave_entitlement_source.dart';
import '../../../core/billing/breakwave_billing_composition.dart';
import '../../../core/billing/revenuecat_catalog_contract.dart';
import '../../../core/billing/revenuecat_catalog_service.dart';
import '../../../core/billing/revenuecat_entitlement_source.dart';
import '../../../core/billing/revenuecat_purchase_lifecycle.dart';

enum BreakWaveBillingQaAction {
  purchaseMonthly,
  purchaseAnnual,
  restore,
}

class BreakWaveBillingQaSnapshot {
  const BreakWaveBillingQaSnapshot({
    required this.configured,
    required this.launchOfferingFound,
    required this.currentOfferingIdentifier,
    required this.packages,
    required this.catalogIssues,
    required this.trustedPlusUnlocked,
    required this.entitlementDiagnostic,
    this.errorMessage,
  });

  final bool configured;
  final bool launchOfferingFound;
  final String? currentOfferingIdentifier;
  final List<RevenueCatCatalogPackageRecord> packages;
  final List<String> catalogIssues;
  final bool trustedPlusUnlocked;
  final RevenueCatEntitlementDiagnosticSnapshot?
      entitlementDiagnostic;
  final String? errorMessage;

  bool get catalogReady => catalogIssues.isEmpty;
}

class BreakWaveBillingQaActionResult {
  const BreakWaveBillingQaActionResult({
    required this.action,
    required this.lifecycleResult,
    required this.snapshot,
  });

  final BreakWaveBillingQaAction action;
  final RevenueCatPurchaseLifecycleResult lifecycleResult;
  final BreakWaveBillingQaSnapshot snapshot;
}

class BreakWaveBillingQaController {
  const BreakWaveBillingQaController({
    required RevenueCatRuntimeStatusProvider runtimeStatusProvider,
    required RevenueCatCatalogProvider catalogProvider,
    required RevenueCatPurchaseLifecycleService purchaseLifecycle,
    required BreakWaveEntitlementSource entitlementSource,
    RevenueCatEntitlementDiagnosticsProvider?
        entitlementDiagnosticsProvider,
  })  : _runtimeStatusProvider = runtimeStatusProvider,
        _catalogProvider = catalogProvider,
        _purchaseLifecycle = purchaseLifecycle,
        _entitlementSource = entitlementSource,
        _entitlementDiagnosticsProvider =
            entitlementDiagnosticsProvider;

  factory BreakWaveBillingQaController.fromComposition(
    BreakWaveBillingComposition composition,
  ) {
    return BreakWaveBillingQaController(
      runtimeStatusProvider: composition.runtimeStatusProvider,
      catalogProvider: composition.catalogProvider,
      purchaseLifecycle: composition.purchaseLifecycle,
      entitlementSource: composition.entitlementSource,
      entitlementDiagnosticsProvider:
          composition.entitlementDiagnosticsProvider,
    );
  }

  final RevenueCatRuntimeStatusProvider _runtimeStatusProvider;
  final RevenueCatCatalogProvider _catalogProvider;
  final RevenueCatPurchaseLifecycleService _purchaseLifecycle;
  final BreakWaveEntitlementSource _entitlementSource;
  final RevenueCatEntitlementDiagnosticsProvider?
      _entitlementDiagnosticsProvider;

  Future<BreakWaveBillingQaSnapshot> refresh() {
    return _loadSnapshot();
  }

  Future<BreakWaveBillingQaActionResult> purchaseMonthly() async {
    final RevenueCatPurchaseLifecycleResult lifecycleResult =
        await _purchaseLifecycle.purchaseMonthly();

    return BreakWaveBillingQaActionResult(
      action: BreakWaveBillingQaAction.purchaseMonthly,
      lifecycleResult: lifecycleResult,
      snapshot: await _loadSnapshot(
        trustedPlusOverride:
            _trustedOverrideFor(lifecycleResult),
      ),
    );
  }

  Future<BreakWaveBillingQaActionResult> purchaseAnnual() async {
    final RevenueCatPurchaseLifecycleResult lifecycleResult =
        await _purchaseLifecycle.purchaseAnnual();

    return BreakWaveBillingQaActionResult(
      action: BreakWaveBillingQaAction.purchaseAnnual,
      lifecycleResult: lifecycleResult,
      snapshot: await _loadSnapshot(
        trustedPlusOverride:
            _trustedOverrideFor(lifecycleResult),
      ),
    );
  }

  Future<BreakWaveBillingQaActionResult> restorePurchases() async {
    final RevenueCatPurchaseLifecycleResult lifecycleResult =
        await _purchaseLifecycle.restorePurchases();

    return BreakWaveBillingQaActionResult(
      action: BreakWaveBillingQaAction.restore,
      lifecycleResult: lifecycleResult,
      snapshot: await _loadSnapshot(
        trustedPlusOverride:
            _trustedOverrideFor(lifecycleResult),
      ),
    );
  }

  bool? _trustedOverrideFor(
    RevenueCatPurchaseLifecycleResult result,
  ) {
    switch (result.status) {
      case RevenueCatPurchaseLifecycleStatus.purchaseActivated:
      case RevenueCatPurchaseLifecycleStatus.restoreActivated:
      case RevenueCatPurchaseLifecycleStatus.completedButNotVerified:
        return result.isPlusUnlocked;
      case RevenueCatPurchaseLifecycleStatus.cancelled:
      case RevenueCatPurchaseLifecycleStatus.packageUnavailable:
      case RevenueCatPurchaseLifecycleStatus.failed:
        return null;
    }
  }

  Future<BreakWaveBillingQaSnapshot> _loadSnapshot({
    bool? trustedPlusOverride,
  }) async {
    bool configured = false;
    String? errorMessage;

    try {
      configured = await _runtimeStatusProvider.isConfigured();
    } catch (_) {
      errorMessage = 'RevenueCat runtime status unavailable.';
    }

    RevenueCatCatalogSnapshot catalogSnapshot =
        const RevenueCatCatalogSnapshot(
      currentOfferingIdentifier: null,
      launchOfferingFound: false,
      packages: <RevenueCatCatalogPackageRecord>[],
    );

    try {
      catalogSnapshot = await _catalogProvider.load();
    } catch (_) {
      errorMessage ??= 'RevenueCat Test Store catalog unavailable.';
    }

    bool trustedPlusUnlocked = trustedPlusOverride ?? false;

    if (trustedPlusOverride == null) {
      try {
        trustedPlusUnlocked =
            await _entitlementSource.isPlusUnlocked();
      } catch (_) {
        trustedPlusUnlocked = false;
        errorMessage ??= 'Trusted entitlement read failed closed.';
      }
    }

    final RevenueCatEntitlementDiagnosticSnapshot?
        entitlementDiagnostic =
        _entitlementDiagnosticsProvider?.lastDiagnostic;

    final List<RevenueCatCatalogPackageRecord> packages =
        List<RevenueCatCatalogPackageRecord>.of(
      catalogSnapshot.packages,
    )..sort(
            (
              RevenueCatCatalogPackageRecord a,
              RevenueCatCatalogPackageRecord b,
            ) =>
                a.packageIdentifier.compareTo(
              b.packageIdentifier,
            ),
          );

    final List<String> issues = _testStoreCatalogIssues(
      catalogSnapshot,
    );

    return BreakWaveBillingQaSnapshot(
      configured: configured,
      launchOfferingFound: catalogSnapshot.launchOfferingFound,
      currentOfferingIdentifier:
          catalogSnapshot.currentOfferingIdentifier,
      packages:
          List<RevenueCatCatalogPackageRecord>.unmodifiable(
        packages,
      ),
      catalogIssues: List<String>.unmodifiable(issues),
      trustedPlusUnlocked: trustedPlusUnlocked,
      entitlementDiagnostic: entitlementDiagnostic,
      errorMessage: errorMessage,
    );
  }

  List<String> _testStoreCatalogIssues(
    RevenueCatCatalogSnapshot snapshot,
  ) {
    final List<String> issues = <String>[];

    if (!snapshot.launchOfferingFound) {
      issues.add('Offering default was not found.');
    }

    if (snapshot.currentOfferingIdentifier !=
        RevenueCatCatalogContract.defaultOfferingId) {
      issues.add('Offering default is not current.');
    }

    final Map<String, RevenueCatCatalogPackageRecord>
        packagesByIdentifier =
        <String, RevenueCatCatalogPackageRecord>{};

    for (final RevenueCatCatalogPackageRecord package
        in snapshot.packages) {
      if (packagesByIdentifier.containsKey(
        package.packageIdentifier,
      )) {
        issues.add(
          'Duplicate package ${package.packageIdentifier}.',
        );
        continue;
      }

      packagesByIdentifier[package.packageIdentifier] = package;

      if (package.priceString.trim().isEmpty) {
        issues.add(
          'Package ${package.packageIdentifier} has no store price.',
        );
      }

      if ((package.subscriptionPeriod ?? '').trim().isEmpty) {
        issues.add(
          'Package ${package.packageIdentifier} has no billing period.',
        );
      }
    }

    _checkTestStorePackage(
      packagesByIdentifier,
      packageIdentifier:
          RevenueCatCatalogContract.monthlyPackageIdentifier,
      expectedProductIdentifier:
          RevenueCatCatalogContract
              .testStoreMonthlyProductIdentifier,
      issues: issues,
    );

    _checkTestStorePackage(
      packagesByIdentifier,
      packageIdentifier:
          RevenueCatCatalogContract.annualPackageIdentifier,
      expectedProductIdentifier:
          RevenueCatCatalogContract
              .testStoreAnnualProductIdentifier,
      issues: issues,
    );

    const Set<String> expectedPackageIdentifiers = <String>{
      RevenueCatCatalogContract.monthlyPackageIdentifier,
      RevenueCatCatalogContract.annualPackageIdentifier,
    };

    final Set<String> unexpected = packagesByIdentifier.keys
        .where(
          (String identifier) =>
              !expectedPackageIdentifiers.contains(identifier),
        )
        .toSet();

    if (unexpected.isNotEmpty) {
      final List<String> sortedUnexpected =
          unexpected.toList()..sort();

      issues.add(
        'Unexpected Test Store package(s): '
        '$sortedUnexpected.',
      );
    }

    return issues;
  }

  void _checkTestStorePackage(
    Map<String, RevenueCatCatalogPackageRecord> packages, {
    required String packageIdentifier,
    required String expectedProductIdentifier,
    required List<String> issues,
  }) {
    final RevenueCatCatalogPackageRecord? package =
        packages[packageIdentifier];

    if (package == null) {
      issues.add('Missing package $packageIdentifier.');
      return;
    }

    if (package.storeProductIdentifier !=
        expectedProductIdentifier) {
      issues.add(
        'Package $packageIdentifier maps to '
        '${package.storeProductIdentifier}; expected '
        '$expectedProductIdentifier.',
      );
    }
  }
}
