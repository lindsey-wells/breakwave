import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/privacy_access_class.dart';
import 'package:breakwave/core/privacy_lock/privacy_destination.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_route_policy.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_state.dart';

void main() {
  const Set<PrivacyDestination> sensitiveSectionsOpenDestinations =
      <PrivacyDestination>{
    PrivacyDestination.home,
    PrivacyDestination.rescuePersonalized,
  };

  bool expectedRequiresAuthentication({
    required PrivacyDestination destination,
    required PrivacyLockMode lockMode,
    required PrivacySessionState sessionState,
  }) {
    if (lockMode == PrivacyLockMode.none ||
        sessionState == PrivacySessionState.unlocked) {
      return false;
    }

    if (destination == PrivacyDestination.lockedLanding ||
        destination == PrivacyDestination.rescueSafe) {
      return false;
    }

    switch (lockMode) {
      case PrivacyLockMode.none:
        return false;
      case PrivacyLockMode.fullApp:
        return true;
      case PrivacyLockMode.sensitiveSections:
        return !sensitiveSectionsOpenDestinations.contains(destination);
    }
  }

  group('PrivacyRoutePolicy classification coverage', () {
    test('every destination has exactly one classification', () {
      expect(
        PrivacyRoutePolicy.classifications.length,
        PrivacyDestination.values.length,
      );
      expect(
        PrivacyRoutePolicy.classifications.keys.toSet(),
        PrivacyDestination.values.toSet(),
      );
    });

    test('only the locked landing is public while locked', () {
      for (final PrivacyDestination destination
          in PrivacyDestination.values) {
        expect(
          PrivacyRoutePolicy.accessClassFor(destination) ==
              PrivacyAccessClass.publicLocked,
          destination == PrivacyDestination.lockedLanding,
          reason: 'Unexpected public-locked classification: $destination',
        );
      }
    });

    test('only Rescue-safe is classified as Rescue-safe', () {
      for (final PrivacyDestination destination
          in PrivacyDestination.values) {
        expect(
          PrivacyRoutePolicy.accessClassFor(destination) ==
              PrivacyAccessClass.rescueSafe,
          destination == PrivacyDestination.rescueSafe,
          reason: 'Unexpected Rescue-safe classification: $destination',
        );
      }
    });

    test('unknown destinations fail closed as protected', () {
      expect(
        PrivacyRoutePolicy.accessClassFor(
          PrivacyDestination.unknown,
        ),
        PrivacyAccessClass.protected,
      );
    });
  });

  group('PrivacyRoutePolicy exhaustive matrix', () {
    test('all mode/state/destination combinations match the contract', () {
      for (final PrivacyLockMode lockMode in PrivacyLockMode.values) {
        for (final PrivacySessionState sessionState
            in PrivacySessionState.values) {
          for (final PrivacyDestination destination
              in PrivacyDestination.values) {
            final bool expected = expectedRequiresAuthentication(
              destination: destination,
              lockMode: lockMode,
              sessionState: sessionState,
            );

            expect(
              PrivacyRoutePolicy.requiresAuthentication(
                destination: destination,
                lockMode: lockMode,
                sessionState: sessionState,
              ),
              expected,
              reason:
                  'mode=$lockMode state=$sessionState destination=$destination',
            );

            expect(
              PrivacyRoutePolicy.canAccess(
                destination: destination,
                lockMode: lockMode,
                sessionState: sessionState,
              ),
              !expected,
              reason:
                  'canAccess mismatch for mode=$lockMode '
                  'state=$sessionState destination=$destination',
            );
          }
        }
      }
    });
  });

  group('Rescue-safe guardrails', () {
    test('Rescue-safe entry never requires authentication', () {
      for (final PrivacyLockMode lockMode in PrivacyLockMode.values) {
        for (final PrivacySessionState sessionState
            in PrivacySessionState.values) {
          expect(
            PrivacyRoutePolicy.requiresAuthentication(
              destination: PrivacyDestination.rescueSafe,
              lockMode: lockMode,
              sessionState: sessionState,
            ),
            isFalse,
          );
        }
      }
    });

    test('Rescue-safe state does not unlock protected full-app routes', () {
      for (final PrivacyDestination destination
          in PrivacyDestination.values) {
        if (destination == PrivacyDestination.lockedLanding ||
            destination == PrivacyDestination.rescueSafe) {
          continue;
        }

        expect(
          PrivacyRoutePolicy.requiresAuthentication(
            destination: destination,
            lockMode: PrivacyLockMode.fullApp,
            sessionState: PrivacySessionState.rescueSafe,
          ),
          isTrue,
          reason: '$destination leaked from Rescue-safe state.',
        );
      }
    });

    test('authenticating state does not grant protected access', () {
      for (final PrivacyDestination destination
          in PrivacyDestination.values) {
        if (destination == PrivacyDestination.lockedLanding ||
            destination == PrivacyDestination.rescueSafe) {
          continue;
        }

        expect(
          PrivacyRoutePolicy.requiresAuthentication(
            destination: destination,
            lockMode: PrivacyLockMode.fullApp,
            sessionState: PrivacySessionState.authenticating,
          ),
          isTrue,
          reason: '$destination opened before authentication succeeded.',
        );
      }
    });

    test('full-app lock protects personalized Rescue', () {
      expect(
        PrivacyRoutePolicy.requiresAuthentication(
          destination: PrivacyDestination.rescuePersonalized,
          lockMode: PrivacyLockMode.fullApp,
          sessionState: PrivacySessionState.rescueSafe,
        ),
        isTrue,
      );
    });

    test('sensitive-sections mode keeps Home and normal Rescue reachable', () {
      for (final PrivacyDestination destination
          in sensitiveSectionsOpenDestinations) {
        expect(
          PrivacyRoutePolicy.requiresAuthentication(
            destination: destination,
            lockMode: PrivacyLockMode.sensitiveSections,
            sessionState: PrivacySessionState.locked,
          ),
          isFalse,
        );
      }
    });

    test('sensitive-sections mode protects designated sensitive routes', () {
      const Set<PrivacyDestination> protectedDestinations =
          <PrivacyDestination>{
        PrivacyDestination.log,
        PrivacyDestination.support,
        PrivacyDestination.personalWhy,
        PrivacyDestination.insights,
        PrivacyDestination.personalPlan,
        PrivacyDestination.routineHistory,
        PrivacyDestination.recoveryReport,
        PrivacyDestination.privacySettings,
        PrivacyDestination.trustedContact,
        PrivacyDestination.exports,
        PrivacyDestination.billing,
        PrivacyDestination.internalQa,
        PrivacyDestination.unknown,
      };

      for (final PrivacyDestination destination
          in protectedDestinations) {
        expect(
          PrivacyRoutePolicy.requiresAuthentication(
            destination: destination,
            lockMode: PrivacyLockMode.sensitiveSections,
            sessionState: PrivacySessionState.locked,
          ),
          isTrue,
          reason: '$destination must remain protected.',
        );
      }
    });
  });
}
