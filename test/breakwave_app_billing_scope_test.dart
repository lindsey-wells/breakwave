import 'package:breakwave/app/breakwave_app.dart';
import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/billing/breakwave_billing_composition.dart';
import 'package:breakwave/core/billing/breakwave_billing_scope.dart';
import 'package:breakwave/core/billing/revenuecat_catalog_service.dart';
import 'package:breakwave/core/billing/revenuecat_purchase_executor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'pushed Navigator route inherits the one shared billing composition',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final _LockedEntitlementSource entitlement =
          _LockedEntitlementSource();
      final BreakWaveBillingComposition composition =
          BreakWaveBillingComposition(
        entitlementSource: entitlement,
        purchaseExecutor: const _FailClosedPurchaseExecutor(),
        catalogProvider: const _UnavailableCatalogProvider(),
        runtimeStatusProvider:
            const _UnconfiguredRuntimeStatusProvider(),
        disposeEntitlementSource: entitlement.dispose,
      );
      addTearDown(composition.dispose);

      await tester.pumpWidget(
        BreakWaveApp(billingComposition: composition),
      );
      await tester.pump();

      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      BreakWaveBillingComposition? resolved;
      bool routeBuilt = false;

      navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext routeContext) {
            routeBuilt = true;
            resolved = BreakWaveBillingScope.of(routeContext);
            return const SizedBox.shrink();
          },
        ),
      );

      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'A route pushed by the real BreakWave Navigator must remain '
            'under BreakWaveBillingScope.',
      );
      expect(
        routeBuilt,
        isTrue,
        reason:
            'The pushed Navigator route must build before its billing '
            'scope inheritance can be evaluated.',
      );
      expect(resolved, same(composition));
    },
  );
}

class _LockedEntitlementSource extends BreakWaveEntitlementSource {
  final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async => false;

  void dispose() => _changes.dispose();
}

class _FailClosedPurchaseExecutor extends RevenueCatPurchaseExecutor {
  const _FailClosedPurchaseExecutor();

  @override
  Future<RevenueCatPurchaseExecutorResult> purchasePackage(
    String packageIdentifier,
  ) async => RevenueCatPurchaseExecutorResult.failed;

  @override
  Future<RevenueCatPurchaseExecutorResult> restorePurchases() async =>
      RevenueCatPurchaseExecutorResult.failed;
}

class _UnavailableCatalogProvider extends RevenueCatCatalogProvider {
  const _UnavailableCatalogProvider();

  @override
  Future<RevenueCatCatalogSnapshot> load() async {
    return const RevenueCatCatalogSnapshot(
      currentOfferingIdentifier: null,
      launchOfferingFound: false,
      packages: <RevenueCatCatalogPackageRecord>[],
    );
  }
}

class _UnconfiguredRuntimeStatusProvider
    extends RevenueCatRuntimeStatusProvider {
  const _UnconfiguredRuntimeStatusProvider();

  @override
  Future<bool> isConfigured() async => false;
}
