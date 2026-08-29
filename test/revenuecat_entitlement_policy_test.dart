import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/billing/revenuecat_entitlement_policy.dart';

void main() {
  const RevenueCatEntitlementPolicy policy =
      RevenueCatEntitlementPolicy();

  final DateTime t0 = DateTime.utc(2026, 8, 29, 12);

  RevenueCatEntitlementObservation observation({
    RevenueCatVerificationState verification =
        RevenueCatVerificationState.verified,
    bool isActive = true,
    Duration requestOffset = Duration.zero,
    Duration? expiresAfter = const Duration(days: 30),
    Duration? billingIssueAfter,
  }) {
    final DateTime request = t0.add(requestOffset);

    return RevenueCatEntitlementObservation(
      requestDateUtc: request,
      verification: verification,
      isActive: isActive,
      expirationDateUtc:
          expiresAfter == null
              ? null
              : request.add(expiresAfter),
      billingIssueDetectedAtUtc:
          billingIssueAfter == null
              ? null
              : request.add(billingIssueAfter),
    );
  }

  group('RevenueCat trusted verification', () {
    test('verified active can authorize Plus', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(),
      );

      expect(decision.isPlusUnlocked, isTrue);
      expect(
        decision.reason,
        RevenueCatEntitlementDecisionReason.verifiedActive,
      );
    });

    test('verifiedOnDevice cannot create Plus', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(
          verification:
              RevenueCatVerificationState
                  .verifiedOnDevice,
        ),
      );

      expect(decision.isPlusUnlocked, isFalse);
    });

    test(
      'verifiedOnDevice cannot extend prior trusted window',
      () {
        final RevenueCatTrustedState previous =
            RevenueCatTrustedState(
          acceptedRequestDateUtc: t0,
          authoritativePlus: true,
          validUntilUtc: t0.add(
            const Duration(hours: 3),
          ),
          lastObservedDeviceTimeUtc: t0,
        );

        final RevenueCatEntitlementDecision beforeExpiry =
            policy.evaluate(
          previous: previous,
          nowUtc: t0.add(const Duration(hours: 2)),
          observation: observation(
            verification:
                RevenueCatVerificationState
                    .verifiedOnDevice,
            requestOffset: const Duration(hours: 2),
          ),
        );

        expect(beforeExpiry.isPlusUnlocked, isTrue);
        expect(
          beforeExpiry.nextState.validUntilUtc,
          previous.validUntilUtc,
        );

        final RevenueCatEntitlementDecision afterExpiry =
            policy.evaluate(
          previous: beforeExpiry.nextState,
          nowUtc: t0.add(const Duration(hours: 4)),
          observation: observation(
            verification:
                RevenueCatVerificationState
                    .verifiedOnDevice,
            requestOffset: const Duration(hours: 4),
          ),
        );

        expect(afterExpiry.isPlusUnlocked, isFalse);
        expect(
          afterExpiry.nextState.validUntilUtc,
          previous.validUntilUtc,
        );
      },
    );

    test('notRequested denies Plus', () {
      expect(
        policy
            .evaluate(
              previous:
                  const RevenueCatTrustedState.empty(),
              nowUtc: t0,
              observation: observation(
                verification:
                    RevenueCatVerificationState
                        .notRequested,
              ),
            )
            .isPlusUnlocked,
        isFalse,
      );
    });

    test('failed verification denies Plus', () {
      expect(
        policy
            .evaluate(
              previous:
                  const RevenueCatTrustedState.empty(),
              nowUtc: t0,
              observation: observation(
                verification:
                    RevenueCatVerificationState.failed,
              ),
            )
            .isPlusUnlocked,
        isFalse,
      );
    });
  });

  group('BreakWave offline ceilings', () {
    test('normal verified active is capped at 72 hours', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(),
      );

      expect(
        decision.nextState.validUntilUtc,
        t0.add(const Duration(hours: 72)),
      );
    });

    test('billing issue is capped at 24 hours', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(
          billingIssueAfter: Duration.zero,
        ),
      );

      expect(
        decision.nextState.validUntilUtc,
        t0.add(const Duration(hours: 24)),
      );
      expect(
        decision.reason,
        RevenueCatEntitlementDecisionReason
            .verifiedBillingIssue,
      );
    });

    test(
      'short RevenueCat server grant cannot outlive its 24h expiration',
      () {
        final RevenueCatEntitlementDecision decision =
            policy.evaluate(
          previous: const RevenueCatTrustedState.empty(),
          nowUtc: t0,
          observation: observation(
            expiresAfter: const Duration(hours: 24),
          ),
        );

        expect(
          decision.nextState.validUntilUtc,
          t0.add(const Duration(hours: 24)),
        );

        expect(
          policy
              .evaluate(
                previous: decision.nextState,
                nowUtc:
                    t0.add(const Duration(hours: 24)),
              )
              .isPlusUnlocked,
          isFalse,
        );
      },
    );

    test('store expiration shorter than ceiling wins', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(
          expiresAfter: const Duration(hours: 5),
        ),
      );

      expect(
        decision.nextState.validUntilUtc,
        t0.add(const Duration(hours: 5)),
      );
    });
  });

  group('Negative and stale state protection', () {
    test('verified inactive denies Plus', () {
      expect(
        policy
            .evaluate(
              previous:
                  const RevenueCatTrustedState.empty(),
              nowUtc: t0,
              observation: observation(
                isActive: false,
              ),
            )
            .isPlusUnlocked,
        isFalse,
      );
    });

    test('active without usable expiration fails closed', () {
      expect(
        policy
            .evaluate(
              previous:
                  const RevenueCatTrustedState.empty(),
              nowUtc: t0,
              observation: observation(
                expiresAfter: null,
              ),
            )
            .isPlusUnlocked,
        isFalse,
      );
    });

    test(
      'stale positive cannot overwrite newer accepted negative',
      () {
        final RevenueCatTrustedState newerNegative =
            RevenueCatTrustedState(
          acceptedRequestDateUtc:
              t0.add(const Duration(hours: 10)),
          authoritativePlus: false,
          validUntilUtc: null,
          lastObservedDeviceTimeUtc:
              t0.add(const Duration(hours: 10)),
        );

        final RevenueCatEntitlementDecision decision =
            policy.evaluate(
          previous: newerNegative,
          nowUtc: t0.add(const Duration(hours: 11)),
          observation: observation(
            requestOffset: const Duration(hours: 5),
          ),
        );

        expect(decision.isPlusUnlocked, isFalse);
        expect(
          decision.nextState.acceptedRequestDateUtc,
          newerNegative.acceptedRequestDateUtc,
        );
      },
    );

    test(
      'stale negative cannot overwrite newer trusted positive',
      () {
        final RevenueCatTrustedState newerPositive =
            RevenueCatTrustedState(
          acceptedRequestDateUtc:
              t0.add(const Duration(hours: 10)),
          authoritativePlus: true,
          validUntilUtc:
              t0.add(const Duration(hours: 20)),
          lastObservedDeviceTimeUtc:
              t0.add(const Duration(hours: 10)),
        );

        final RevenueCatEntitlementDecision decision =
            policy.evaluate(
          previous: newerPositive,
          nowUtc: t0.add(const Duration(hours: 11)),
          observation: observation(
            verification:
                RevenueCatVerificationState.failed,
            requestOffset: const Duration(hours: 5),
          ),
        );

        expect(decision.isPlusUnlocked, isTrue);
        expect(
          decision.reason,
          RevenueCatEntitlementDecisionReason
              .staleObservationIgnored,
        );
      },
    );
  });

  group('Clock defense', () {
    test('device clock rollback fails closed', () {
      final RevenueCatTrustedState previous =
          RevenueCatTrustedState(
        acceptedRequestDateUtc: t0,
        authoritativePlus: true,
        validUntilUtc:
            t0.add(const Duration(hours: 12)),
        lastObservedDeviceTimeUtc:
            t0.add(const Duration(hours: 3)),
      );

      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: previous,
        nowUtc: t0.add(const Duration(hours: 2)),
      );

      expect(decision.isPlusUnlocked, isFalse);
      expect(
        decision.reason,
        RevenueCatEntitlementDecisionReason
            .clockRollbackDenied,
      );
    });

    test('future server request time fails closed', () {
      final RevenueCatEntitlementDecision decision =
          policy.evaluate(
        previous: const RevenueCatTrustedState.empty(),
        nowUtc: t0,
        observation: observation(
          requestOffset: const Duration(minutes: 1),
        ),
      );

      expect(decision.isPlusUnlocked, isFalse);
      expect(
        decision.reason,
        RevenueCatEntitlementDecisionReason
            .futureServerTimeDenied,
      );
    });
  });
}
