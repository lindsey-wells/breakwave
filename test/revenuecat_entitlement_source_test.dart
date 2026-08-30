import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_access_service.dart';
import 'package:breakwave/core/access/breakwave_feature.dart';
import 'package:breakwave/core/billing/revenuecat_entitlement_policy.dart';
import 'package:breakwave/core/billing/revenuecat_entitlement_source.dart';
import 'package:breakwave/core/billing/revenuecat_trusted_state_store.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 8, 29, 12);

  RevenueCatEntitlementObservation trustedActive() {
    return RevenueCatEntitlementObservation(
      requestDateUtc: t0,
      verification: RevenueCatVerificationState.verified,
      isActive: true,
      expirationDateUtc:
          t0.add(const Duration(days: 30)),
    );
  }

  test(
    'missing entitlement ID fails closed without RevenueCat read',
    () async {
      final _FakeProvider provider = _FakeProvider(
        observation: trustedActive(),
      );
      final _MemoryStore store = _MemoryStore();

      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource(
        entitlementId: '',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => t0,
      );
      addTearDown(source.dispose);

      expect(await source.isPlusUnlocked(), isFalse);
      expect(provider.readCount, 0);
    },
  );

  test(
    'verified CustomerInfo grants through existing BreakWave access seam',
    () async {
      final _FakeProvider provider = _FakeProvider(
        observation: trustedActive(),
      );
      final _MemoryStore store = _MemoryStore();

      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource(
        entitlementId: 'test-entitlement',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => t0,
      );
      addTearDown(source.dispose);

      final BreakWaveAccessService service =
          BreakWaveAccessService(
        entitlementSource: source,
      );

      expect(
        await service.isAvailable(
          BreakWaveFeature.guidedRoutines,
        ),
        isTrue,
      );
      expect(provider.readCount, 1);
    },
  );


  test(
    'verified-on-device diagnostics reuse the same authority read',
    () async {
      final RevenueCatEntitlementObservation observation =
          RevenueCatEntitlementObservation(
        requestDateUtc: t0,
        verification: RevenueCatVerificationState.verifiedOnDevice,
        isActive: true,
        expirationDateUtc: t0.add(const Duration(days: 30)),
      );
      final _FakeProvider provider = _FakeProvider(observation: observation);
      final _MemoryStore store = _MemoryStore();

      final RevenueCatEntitlementSource source = RevenueCatEntitlementSource(
        entitlementId: 'test-entitlement',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => t0,
      );
      addTearDown(source.dispose);

      expect(await source.isPlusUnlocked(), isFalse);
      final RevenueCatEntitlementDiagnosticSnapshot? diagnostic =
          source.lastDiagnostic;

      expect(provider.readCount, 1);
      expect(diagnostic, isNotNull);
      expect(diagnostic!.verification,
          RevenueCatVerificationState.verifiedOnDevice);
      expect(diagnostic.isActive, isTrue);
      expect(diagnostic.decisionReason,
          RevenueCatEntitlementDecisionReason.verifiedOnDeviceDenied);
      expect(diagnostic.policyWouldUnlock, isFalse);
      expect(store.state.authoritativePlus, isFalse);
    },
  );

  test(
    'Rescue bypasses RevenueCat entirely',
    () async {
      final _FakeProvider provider = _FakeProvider(
        error: StateError('RevenueCat unavailable'),
      );
      final _MemoryStore store = _MemoryStore();

      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource(
        entitlementId: 'test-entitlement',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => t0,
      );
      addTearDown(source.dispose);

      final BreakWaveAccessService service =
          BreakWaveAccessService(
        entitlementSource: source,
      );

      expect(
        await service.isAvailable(
          BreakWaveFeature.rescueNow,
        ),
        isTrue,
      );
      expect(provider.readCount, 0);
    },
  );

  test(
    'provider outage can use only unexpired persisted trusted state',
    () async {
      final RevenueCatTrustedState existing =
          RevenueCatTrustedState(
        acceptedRequestDateUtc: t0,
        authoritativePlus: true,
        validUntilUtc:
            t0.add(const Duration(hours: 3)),
        lastObservedDeviceTimeUtc: t0,
      );

      final _FakeProvider provider = _FakeProvider(
        error: StateError('offline'),
      );
      final _MemoryStore store =
          _MemoryStore(initial: existing);

      DateTime now = t0.add(const Duration(hours: 2));

      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource(
        entitlementId: 'test-entitlement',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => now,
      );
      addTearDown(source.dispose);

      expect(await source.isPlusUnlocked(), isTrue);

      now = t0.add(const Duration(hours: 4));

      expect(await source.isPlusUnlocked(), isFalse);
    },
  );

  test(
    'trusted positive fails closed when anti-stale state cannot persist',
    () async {
      final _FakeProvider provider = _FakeProvider(
        observation: trustedActive(),
      );
      final _MemoryStore store = _MemoryStore(
        writeError: StateError('storage unavailable'),
      );

      final RevenueCatEntitlementSource source =
          RevenueCatEntitlementSource(
        entitlementId: 'test-entitlement',
        observationProvider: provider,
        stateStore: store,
        nowUtc: () => t0,
      );
      addTearDown(source.dispose);

      expect(await source.isPlusUnlocked(), isFalse);
    },
  );
}

class _FakeProvider
    extends RevenueCatEntitlementObservationProvider {
  _FakeProvider({
    this.observation,
    this.error,
  });

  final RevenueCatEntitlementObservation? observation;
  final Object? error;
  int readCount = 0;

  @override
  Future<RevenueCatEntitlementObservation> load(
    String entitlementId,
  ) async {
    readCount += 1;

    if (error != null) {
      throw error!;
    }

    return observation!;
  }
}

class _MemoryStore extends RevenueCatTrustedStateStore {
  _MemoryStore({
    RevenueCatTrustedState initial =
        const RevenueCatTrustedState.empty(),
    this.writeError,
  }) : state = initial;

  RevenueCatTrustedState state;
  final Object? writeError;

  @override
  Future<RevenueCatTrustedState> read() async => state;

  @override
  Future<void> write(
    RevenueCatTrustedState next,
  ) async {
    if (writeError != null) {
      throw writeError!;
    }

    state = next;
  }
}
