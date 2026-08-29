// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_entitlement_source.dart
// Purpose: Trusted RevenueCat adapter for BreakWave Plus access.
// Notes: Purchase callbacks are never entitlement authority.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../access/breakwave_entitlement_source.dart';
import 'revenuecat_catalog_contract.dart';
import 'revenuecat_entitlement_policy.dart';
import 'revenuecat_trusted_state_store.dart';

abstract class RevenueCatEntitlementObservationProvider {
  const RevenueCatEntitlementObservationProvider();

  Future<RevenueCatEntitlementObservation> load(
    String entitlementId,
  );
}

class RevenueCatSdkEntitlementObservationProvider
    extends RevenueCatEntitlementObservationProvider {
  const RevenueCatSdkEntitlementObservationProvider();

  @override
  Future<RevenueCatEntitlementObservation> load(
    String entitlementId,
  ) async {
    if (!await Purchases.isConfigured) {
      throw StateError('RevenueCat is not configured.');
    }

    final CustomerInfo customerInfo =
        await Purchases.getCustomerInfo();

    final DateTime requestDateUtc =
        _requiredUtc(customerInfo.requestDate);

    final EntitlementInfo? entitlement =
        customerInfo.entitlements.all[entitlementId];

    return RevenueCatEntitlementObservation(
      requestDateUtc: requestDateUtc,
      verification: _verificationState(
        customerInfo.entitlements.verification,
      ),
      isActive: entitlement?.isActive ?? false,
      expirationDateUtc:
          _optionalUtc(entitlement?.expirationDate),
      billingIssueDetectedAtUtc:
          _optionalUtc(
        entitlement?.billingIssueDetectedAt,
      ),
    );
  }

  static RevenueCatVerificationState _verificationState(
    VerificationResult result,
  ) {
    return switch (result) {
      VerificationResult.verified =>
        RevenueCatVerificationState.verified,
      VerificationResult.verifiedOnDevice =>
        RevenueCatVerificationState.verifiedOnDevice,
      VerificationResult.notRequested =>
        RevenueCatVerificationState.notRequested,
      VerificationResult.failed =>
        RevenueCatVerificationState.failed,
    };
  }

  static DateTime _requiredUtc(String value) {
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException(
        'RevenueCat requestDate is invalid.',
      );
    }

    return parsed.toUtc();
  }

  static DateTime? _optionalUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}

class RevenueCatEntitlementSource
    extends BreakWaveEntitlementSource {
  RevenueCatEntitlementSource({
    required this.entitlementId,
    required RevenueCatEntitlementObservationProvider
        observationProvider,
    required RevenueCatTrustedStateStore stateStore,
    RevenueCatEntitlementPolicy policy =
        const RevenueCatEntitlementPolicy(),
    DateTime Function()? nowUtc,
  })  : _observationProvider = observationProvider,
        _stateStore = stateStore,
        _policy = policy,
        _nowUtc = nowUtc ?? _systemUtcNow;

  factory RevenueCatEntitlementSource.production() {
    return RevenueCatEntitlementSource(
      entitlementId: const String.fromEnvironment(
        'BREAKWAVE_REVENUECAT_PLUS_ENTITLEMENT_ID',
        defaultValue:
            RevenueCatCatalogContract.plusEntitlementId,
      ),
      observationProvider:
          const RevenueCatSdkEntitlementObservationProvider(),
      stateStore:
          const SharedPreferencesRevenueCatTrustedStateStore(),
    );
  }

  final String entitlementId;
  final RevenueCatEntitlementObservationProvider
      _observationProvider;
  final RevenueCatTrustedStateStore _stateStore;
  final RevenueCatEntitlementPolicy _policy;
  final DateTime Function() _nowUtc;

  final ValueNotifier<int> _changes =
      ValueNotifier<int>(0);

  bool? _lastPublishedUnlock;

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async {
    if (entitlementId.trim().isEmpty) {
      return _publish(false);
    }

    final RevenueCatTrustedState previous;

    try {
      previous = await _stateStore.read();
    } catch (_) {
      return _publish(false);
    }

    final DateTime nowUtc = _nowUtc().toUtc();

    RevenueCatEntitlementObservation? observation;

    try {
      observation =
          await _observationProvider.load(entitlementId);
    } catch (_) {
      observation = null;
    }

    final RevenueCatEntitlementDecision decision =
        _policy.evaluate(
      previous: previous,
      nowUtc: nowUtc,
      observation: observation,
    );

    try {
      await _stateStore.write(decision.nextState);
    } catch (_) {
      // Positive authorization is never returned if the
      // anti-stale / anti-clock state cannot be persisted.
      return _publish(false);
    }

    return _publish(decision.isPlusUnlocked);
  }

  bool _publish(bool unlocked) {
    final bool? previous = _lastPublishedUnlock;

    _lastPublishedUnlock = unlocked;

    if (previous != null && previous != unlocked) {
      _changes.value += 1;
    }

    return unlocked;
  }

  void dispose() {
    _changes.dispose();
  }

  static DateTime _systemUtcNow() =>
      DateTime.now().toUtc();
}
