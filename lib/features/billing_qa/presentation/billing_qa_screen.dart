// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: billing_qa_screen.dart
// Purpose: Internal RevenueCat Test Store purchase/restore console.
// Notes: Visible only when the compile-time QA flag is true.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/billing/breakwave_billing_scope.dart';
import '../../../core/billing/revenuecat_catalog_service.dart';
import '../../../core/billing/revenuecat_entitlement_policy.dart';
import '../../../core/billing/revenuecat_entitlement_source.dart';
import '../../../core/billing/revenuecat_purchase_lifecycle.dart';
import '../application/billing_qa_controller.dart';

class BillingQaScreen extends StatefulWidget {
  const BillingQaScreen({super.key});

  @override
  State<BillingQaScreen> createState() =>
      _BillingQaScreenState();
}

class _BillingQaScreenState extends State<BillingQaScreen> {
  BreakWaveBillingQaController? _controller;
  Object? _boundComposition;

  BreakWaveBillingQaSnapshot? _snapshot;
  BreakWaveBillingQaActionResult? _lastAction;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final composition = BreakWaveBillingScope.of(context);

    if (identical(_boundComposition, composition)) {
      return;
    }

    _boundComposition = composition;
    _controller =
        BreakWaveBillingQaController.fromComposition(
      composition,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refresh();
      }
    });
  }

  Future<void> _refresh() async {
    final BreakWaveBillingQaController? controller =
        _controller;

    if (controller == null || _busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final BreakWaveBillingQaSnapshot snapshot =
        await controller.refresh();

    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _busy = false;
    });
  }

  Future<void> _runAction(
    Future<BreakWaveBillingQaActionResult> Function()
        operation,
  ) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final BreakWaveBillingQaActionResult result =
        await operation();

    if (!mounted) {
      return;
    }

    setState(() {
      _lastAction = result;
      _snapshot = result.snapshot;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final BreakWaveBillingQaSnapshot? snapshot =
        _snapshot;

    final bool purchaseReady = !_busy &&
        (snapshot?.configured ?? false) &&
        (snapshot?.catalogReady ?? false);

    final bool restoreReady =
        !_busy && (snapshot?.configured ?? false);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: <Widget>[
          Text(
            'Billing QA — Test Store',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'TEST STORE QA — NO REAL MONEY',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Internal billing controls. This screen is '
                    'compile-time gated and is not a customer '
                    'paywall.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_busy) ...<Widget>[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          _StatusCard(snapshot: snapshot),
          const SizedBox(height: 16),
          _EntitlementDiagnosticCard(snapshot: snapshot),
          const SizedBox(height: 16),
          Text(
            'Catalog',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (snapshot == null)
            const Text('Refresh to read the Test Store catalog.')
          else if (snapshot.packages.isEmpty)
            const Text('No packages returned.')
          else
            for (final RevenueCatCatalogPackageRecord package
                in snapshot.packages)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PackageCard(package: package),
              ),
          if (snapshot != null &&
              snapshot.catalogIssues.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Catalog issues',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            for (final String issue
                in snapshot.catalogIssues)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $issue'),
              ),
          ],
          const SizedBox(height: 20),
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: purchaseReady
                ? () => _runAction(
                      _controller!.purchaseMonthly,
                    )
                : null,
            child: const Text('Buy Monthly'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: purchaseReady
                ? () => _runAction(
                      _controller!.purchaseAnnual,
                    )
                : null,
            child: const Text('Buy Annual'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: restoreReady
                ? () => _runAction(
                      _controller!.restorePurchases,
                    )
                : null,
            child: const Text('Restore Purchases'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _refresh,
            child: const Text(
              'Refresh Trusted Entitlement',
            ),
          ),
          if (_lastAction != null) ...<Widget>[
            const SizedBox(height: 20),
            _LastActionCard(result: _lastAction!),
          ],
          if (snapshot?.errorMessage != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              snapshot!.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.snapshot,
  });

  final BreakWaveBillingQaSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final BreakWaveBillingQaSnapshot? value = snapshot;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Runtime status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              label: 'RevenueCat configured',
              value: value == null
                  ? 'UNKNOWN'
                  : value.configured
                      ? 'YES'
                      : 'NO',
            ),
            _StatusRow(
              label: 'Current Offering',
              value:
                  value?.currentOfferingIdentifier ?? 'NONE',
            ),
            _StatusRow(
              label: 'Catalog ready',
              value: value == null
                  ? 'UNKNOWN'
                  : value.catalogReady
                      ? 'YES'
                      : 'NO',
            ),
            _StatusRow(
              label: 'Trusted access',
              value: value == null
                  ? 'UNKNOWN'
                  : value.trustedPlusUnlocked
                      ? 'PLUS'
                      : 'FREE',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}


class _EntitlementDiagnosticCard extends StatelessWidget {
  const _EntitlementDiagnosticCard({required this.snapshot});

  final BreakWaveBillingQaSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final RevenueCatEntitlementDiagnosticSnapshot? diagnostic =
        snapshot?.entitlementDiagnostic;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Entitlement diagnostics',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Raw entitlement active',
              value: diagnostic?.isActive == null
                  ? 'UNKNOWN'
                  : diagnostic!.isActive! ? 'YES' : 'NO',
            ),
            _StatusRow(
              label: 'Verification',
              value: _verificationLabel(diagnostic?.verification),
            ),
            _StatusRow(
              label: 'Policy decision',
              value: _decisionLabel(diagnostic?.decisionReason),
            ),
            _StatusRow(
              label: 'Policy would unlock',
              value: diagnostic == null
                  ? 'UNKNOWN'
                  : diagnostic.policyWouldUnlock ? 'YES' : 'NO',
            ),
            _StatusRow(
              label: 'Trusted result',
              value: snapshot == null
                  ? 'UNKNOWN'
                  : snapshot!.trustedPlusUnlocked ? 'PLUS' : 'FREE',
            ),
          ],
        ),
      ),
    );
  }

  String _verificationLabel(RevenueCatVerificationState? verification) {
    return switch (verification) {
      null => 'UNKNOWN',
      RevenueCatVerificationState.verified => 'VERIFIED',
      RevenueCatVerificationState.verifiedOnDevice => 'VERIFIED_ON_DEVICE',
      RevenueCatVerificationState.notRequested => 'NOT_REQUESTED',
      RevenueCatVerificationState.failed => 'FAILED',
    };
  }

  String _decisionLabel(RevenueCatEntitlementDecisionReason? reason) {
    return switch (reason) {
      null => 'UNKNOWN',
      RevenueCatEntitlementDecisionReason.verifiedActive => 'VERIFIED_ACTIVE',
      RevenueCatEntitlementDecisionReason.verifiedBillingIssue => 'VERIFIED_BILLING_ISSUE',
      RevenueCatEntitlementDecisionReason.verifiedInactive => 'VERIFIED_INACTIVE',
      RevenueCatEntitlementDecisionReason.verifiedInvalidExpiration => 'VERIFIED_INVALID_EXPIRATION',
      RevenueCatEntitlementDecisionReason.verifiedOnDeviceUsingPriorTrustedState => 'VERIFIED_ON_DEVICE_USING_PRIOR_TRUSTED_STATE',
      RevenueCatEntitlementDecisionReason.verifiedOnDeviceDenied => 'VERIFIED_ON_DEVICE_DENIED',
      RevenueCatEntitlementDecisionReason.notRequestedDenied => 'NOT_REQUESTED_DENIED',
      RevenueCatEntitlementDecisionReason.failedDenied => 'FAILED_DENIED',
      RevenueCatEntitlementDecisionReason.staleObservationIgnored => 'STALE_OBSERVATION_IGNORED',
      RevenueCatEntitlementDecisionReason.cachedTrustedState => 'CACHED_TRUSTED_STATE',
      RevenueCatEntitlementDecisionReason.noTrustedState => 'NO_TRUSTED_STATE',
      RevenueCatEntitlementDecisionReason.clockRollbackDenied => 'CLOCK_ROLLBACK_DENIED',
      RevenueCatEntitlementDecisionReason.futureServerTimeDenied => 'FUTURE_SERVER_TIME_DENIED',
    };
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
  });

  final RevenueCatCatalogPackageRecord package;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              package.packageIdentifier,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('Product: ${package.storeProductIdentifier}'),
            Text('Type: ${package.packageType}'),
            Text('Store price: ${package.priceString}'),
            Text(
              'Billing period: '
              '${package.subscriptionPeriod ?? 'unknown'}',
            ),
          ],
        ),
      ),
    );
  }
}

class _LastActionCard extends StatelessWidget {
  const _LastActionCard({
    required this.result,
  });

  final BreakWaveBillingQaActionResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Last action',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Action: ${_actionLabel(result.action)}'),
            Text(
              'Lifecycle: '
              '${_lifecycleLabel(result.lifecycleResult.status)}',
            ),
            Text(
              'Trusted access after action: '
              '${result.snapshot.trustedPlusUnlocked ? 'PLUS' : 'FREE'}',
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(BreakWaveBillingQaAction action) {
    return switch (action) {
      BreakWaveBillingQaAction.purchaseMonthly =>
        'PURCHASE MONTHLY',
      BreakWaveBillingQaAction.purchaseAnnual =>
        'PURCHASE ANNUAL',
      BreakWaveBillingQaAction.restore => 'RESTORE',
    };
  }

  String _lifecycleLabel(
    RevenueCatPurchaseLifecycleStatus status,
  ) {
    return switch (status) {
      RevenueCatPurchaseLifecycleStatus.purchaseActivated =>
        'PURCHASE ACTIVATED',
      RevenueCatPurchaseLifecycleStatus.restoreActivated =>
        'RESTORE ACTIVATED',
      RevenueCatPurchaseLifecycleStatus.completedButNotVerified =>
        'COMPLETED BUT NOT TRUSTED',
      RevenueCatPurchaseLifecycleStatus.cancelled => 'CANCELLED',
      RevenueCatPurchaseLifecycleStatus.packageUnavailable =>
        'PACKAGE UNAVAILABLE',
      RevenueCatPurchaseLifecycleStatus.failed => 'FAILED',
    };
  }
}
