// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_entitlement_policy.dart
// Purpose: Pure trusted-entitlement freshness and offline policy.
// Notes: Contains no purchase UI, product IDs, or recovery data.
// ------------------------------------------------------------

enum RevenueCatVerificationState {
  verified,
  verifiedOnDevice,
  notRequested,
  failed,
}

enum RevenueCatEntitlementDecisionReason {
  verifiedActive,
  verifiedBillingIssue,
  verifiedInactive,
  verifiedInvalidExpiration,
  verifiedOnDeviceUsingPriorTrustedState,
  verifiedOnDeviceDenied,
  notRequestedDenied,
  failedDenied,
  staleObservationIgnored,
  cachedTrustedState,
  noTrustedState,
  clockRollbackDenied,
  futureServerTimeDenied,
}

class RevenueCatEntitlementObservation {
  const RevenueCatEntitlementObservation({
    required this.requestDateUtc,
    required this.verification,
    required this.isActive,
    this.expirationDateUtc,
    this.billingIssueDetectedAtUtc,
  });

  final DateTime requestDateUtc;
  final RevenueCatVerificationState verification;
  final bool isActive;
  final DateTime? expirationDateUtc;
  final DateTime? billingIssueDetectedAtUtc;
}

class RevenueCatTrustedState {
  const RevenueCatTrustedState({
    this.acceptedRequestDateUtc,
    required this.authoritativePlus,
    this.validUntilUtc,
    this.lastObservedDeviceTimeUtc,
  });

  const RevenueCatTrustedState.empty()
      : acceptedRequestDateUtc = null,
        authoritativePlus = false,
        validUntilUtc = null,
        lastObservedDeviceTimeUtc = null;

  final DateTime? acceptedRequestDateUtc;
  final bool authoritativePlus;
  final DateTime? validUntilUtc;
  final DateTime? lastObservedDeviceTimeUtc;

  bool isUnlockedAt(DateTime nowUtc) {
    final DateTime? until = validUntilUtc;
    return authoritativePlus &&
        until != null &&
        nowUtc.isBefore(until);
  }

  RevenueCatTrustedState withLastObservedDeviceTime(
    DateTime nowUtc,
  ) {
    return RevenueCatTrustedState(
      acceptedRequestDateUtc: acceptedRequestDateUtc,
      authoritativePlus: authoritativePlus,
      validUntilUtc: validUntilUtc,
      lastObservedDeviceTimeUtc: nowUtc,
    );
  }
}

class RevenueCatEntitlementDecision {
  const RevenueCatEntitlementDecision({
    required this.isPlusUnlocked,
    required this.nextState,
    required this.reason,
  });

  final bool isPlusUnlocked;
  final RevenueCatTrustedState nextState;
  final RevenueCatEntitlementDecisionReason reason;
}

class RevenueCatEntitlementPolicy {
  const RevenueCatEntitlementPolicy();

  static const Duration activeOfflineCeiling =
      Duration(hours: 72);

  static const Duration billingIssueOfflineCeiling =
      Duration(hours: 24);

  RevenueCatEntitlementDecision evaluate({
    required RevenueCatTrustedState previous,
    required DateTime nowUtc,
    RevenueCatEntitlementObservation? observation,
  }) {
    if (_clockMovedBackward(previous, nowUtc)) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: previous,
        reason:
            RevenueCatEntitlementDecisionReason
                .clockRollbackDenied,
      );
    }

    if (observation == null) {
      final RevenueCatTrustedState next =
          previous.withLastObservedDeviceTime(nowUtc);

      return RevenueCatEntitlementDecision(
        isPlusUnlocked: previous.isUnlockedAt(nowUtc),
        nextState: next,
        reason: previous.isUnlockedAt(nowUtc)
            ? RevenueCatEntitlementDecisionReason
                .cachedTrustedState
            : RevenueCatEntitlementDecisionReason
                .noTrustedState,
      );
    }

    if (nowUtc.isBefore(observation.requestDateUtc)) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: previous,
        reason:
            RevenueCatEntitlementDecisionReason
                .futureServerTimeDenied,
      );
    }

    final DateTime? acceptedRequestDate =
        previous.acceptedRequestDateUtc;

    final bool observationIsNewer =
        acceptedRequestDate == null ||
        observation.requestDateUtc.isAfter(
          acceptedRequestDate,
        );

    if (observation.verification ==
        RevenueCatVerificationState.verifiedOnDevice) {
      final RevenueCatTrustedState next =
          previous.withLastObservedDeviceTime(nowUtc);

      final bool priorTrusted =
          previous.isUnlockedAt(nowUtc);

      return RevenueCatEntitlementDecision(
        isPlusUnlocked: priorTrusted,
        nextState: next,
        reason: priorTrusted
            ? RevenueCatEntitlementDecisionReason
                .verifiedOnDeviceUsingPriorTrustedState
            : RevenueCatEntitlementDecisionReason
                .verifiedOnDeviceDenied,
      );
    }

    if (!observationIsNewer) {
      final RevenueCatTrustedState next =
          previous.withLastObservedDeviceTime(nowUtc);

      return RevenueCatEntitlementDecision(
        isPlusUnlocked: previous.isUnlockedAt(nowUtc),
        nextState: next,
        reason:
            RevenueCatEntitlementDecisionReason
                .staleObservationIgnored,
      );
    }

    if (observation.verification ==
        RevenueCatVerificationState.notRequested) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: _negativeState(
          requestDateUtc: observation.requestDateUtc,
          nowUtc: nowUtc,
        ),
        reason:
            RevenueCatEntitlementDecisionReason
                .notRequestedDenied,
      );
    }

    if (observation.verification ==
        RevenueCatVerificationState.failed) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: _negativeState(
          requestDateUtc: observation.requestDateUtc,
          nowUtc: nowUtc,
        ),
        reason:
            RevenueCatEntitlementDecisionReason.failedDenied,
      );
    }

    if (!observation.isActive) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: _negativeState(
          requestDateUtc: observation.requestDateUtc,
          nowUtc: nowUtc,
        ),
        reason:
            RevenueCatEntitlementDecisionReason
                .verifiedInactive,
      );
    }

    final DateTime? expiration =
        observation.expirationDateUtc;

    if (expiration == null ||
        !expiration.isAfter(observation.requestDateUtc)) {
      return RevenueCatEntitlementDecision(
        isPlusUnlocked: false,
        nextState: _negativeState(
          requestDateUtc: observation.requestDateUtc,
          nowUtc: nowUtc,
        ),
        reason:
            RevenueCatEntitlementDecisionReason
                .verifiedInvalidExpiration,
      );
    }

    final bool billingIssue =
        observation.billingIssueDetectedAtUtc != null;

    final Duration ceiling = billingIssue
        ? billingIssueOfflineCeiling
        : activeOfflineCeiling;

    final DateTime ceilingEnd =
        observation.requestDateUtc.add(ceiling);

    final DateTime validUntil =
        expiration.isBefore(ceilingEnd)
            ? expiration
            : ceilingEnd;

    final RevenueCatTrustedState next =
        RevenueCatTrustedState(
      acceptedRequestDateUtc: observation.requestDateUtc,
      authoritativePlus: true,
      validUntilUtc: validUntil,
      lastObservedDeviceTimeUtc: nowUtc,
    );

    return RevenueCatEntitlementDecision(
      isPlusUnlocked: next.isUnlockedAt(nowUtc),
      nextState: next,
      reason: billingIssue
          ? RevenueCatEntitlementDecisionReason
              .verifiedBillingIssue
          : RevenueCatEntitlementDecisionReason
              .verifiedActive,
    );
  }

  bool _clockMovedBackward(
    RevenueCatTrustedState previous,
    DateTime nowUtc,
  ) {
    final DateTime? lastObserved =
        previous.lastObservedDeviceTimeUtc;

    if (lastObserved != null &&
        nowUtc.isBefore(lastObserved)) {
      return true;
    }

    final DateTime? acceptedRequest =
        previous.acceptedRequestDateUtc;

    return acceptedRequest != null &&
        nowUtc.isBefore(acceptedRequest);
  }

  RevenueCatTrustedState _negativeState({
    required DateTime requestDateUtc,
    required DateTime nowUtc,
  }) {
    return RevenueCatTrustedState(
      acceptedRequestDateUtc: requestDateUtc,
      authoritativePlus: false,
      validUntilUtc: null,
      lastObservedDeviceTimeUtc: nowUtc,
    );
  }
}
