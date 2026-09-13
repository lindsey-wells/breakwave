// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_route_policy.dart
// Purpose: IOS-G2B pure-Dart privacy routing policy.
// Notes: Unknown destinations fail closed.
// ------------------------------------------------------------

import 'privacy_access_class.dart';
import 'privacy_destination.dart';
import 'privacy_lock_mode.dart';
import 'privacy_session_state.dart';

class PrivacyRoutePolicy {
  const PrivacyRoutePolicy._();

  static const Map<PrivacyDestination, PrivacyAccessClass> classifications =
      <PrivacyDestination, PrivacyAccessClass>{
    PrivacyDestination.lockedLanding: PrivacyAccessClass.publicLocked,
    PrivacyDestination.home: PrivacyAccessClass.protected,
    PrivacyDestination.rescueSafe: PrivacyAccessClass.rescueSafe,
    PrivacyDestination.rescuePersonalized: PrivacyAccessClass.protected,
    PrivacyDestination.log: PrivacyAccessClass.protected,
    PrivacyDestination.support: PrivacyAccessClass.protected,
    PrivacyDestination.personalWhy: PrivacyAccessClass.protected,
    PrivacyDestination.insights: PrivacyAccessClass.protected,
    PrivacyDestination.personalPlan: PrivacyAccessClass.protected,
    PrivacyDestination.routineHistory: PrivacyAccessClass.protected,
    PrivacyDestination.recoveryReport: PrivacyAccessClass.protected,
    PrivacyDestination.privacySettings: PrivacyAccessClass.protected,
    PrivacyDestination.trustedContact: PrivacyAccessClass.protected,
    PrivacyDestination.exports: PrivacyAccessClass.protected,
    PrivacyDestination.billing: PrivacyAccessClass.protected,
    PrivacyDestination.internalQa: PrivacyAccessClass.protected,
    PrivacyDestination.unknown: PrivacyAccessClass.protected,
  };

  static const Set<PrivacyDestination> _sensitiveSectionsOpenDestinations =
      <PrivacyDestination>{
    PrivacyDestination.home,
    PrivacyDestination.rescuePersonalized,
  };

  static PrivacyAccessClass accessClassFor(PrivacyDestination destination) {
    return classifications[destination] ?? PrivacyAccessClass.protected;
  }

  static bool requiresAuthentication({
    required PrivacyDestination destination,
    required PrivacyLockMode lockMode,
    required PrivacySessionState sessionState,
  }) {
    if (lockMode == PrivacyLockMode.none ||
        sessionState == PrivacySessionState.unlocked) {
      return false;
    }

    final PrivacyAccessClass accessClass = accessClassFor(destination);

    if (accessClass == PrivacyAccessClass.publicLocked ||
        accessClass == PrivacyAccessClass.rescueSafe) {
      return false;
    }

    switch (lockMode) {
      case PrivacyLockMode.none:
        return false;
      case PrivacyLockMode.fullApp:
        return true;
      case PrivacyLockMode.sensitiveSections:
        return !_sensitiveSectionsOpenDestinations.contains(destination);
    }
  }

  static bool canAccess({
    required PrivacyDestination destination,
    required PrivacyLockMode lockMode,
    required PrivacySessionState sessionState,
  }) {
    return !requiresAuthentication(
      destination: destination,
      lockMode: lockMode,
      sessionState: sessionState,
    );
  }
}
