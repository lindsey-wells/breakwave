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

      navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext routeContext) {
            resolved = BreakWaveBillingScope.of(routeContext);
            return const Scaffold(
              body: Text('billing-scope-route-probe'),
            );
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
      expect(resolved, same(composition));
      expect(find.text('billing-scope-route-probe'), findsOneWidget);
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
