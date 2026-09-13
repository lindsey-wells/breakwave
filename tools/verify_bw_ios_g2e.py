#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> None:
    failed = False

    paths = {
        "attempt_state": ROOT / "lib/core/privacy_lock/privacy_attempt_state.dart",
        "attempt_store": ROOT / "lib/core/privacy_lock/privacy_attempt_store.dart",
        "config_store": ROOT / "lib/core/privacy_lock/privacy_lock_configuration_store.dart",
        "controller": ROOT / "lib/core/privacy_lock/privacy_session_controller.dart",
        "composition": ROOT / "lib/core/privacy_lock/privacy_lock_composition.dart",
        "attempt_state_test": ROOT / "test/privacy_attempt_state_test.dart",
        "attempt_store_test": ROOT / "test/privacy_attempt_store_test.dart",
        "config_store_test": ROOT / "test/privacy_lock_configuration_store_test.dart",
        "controller_test": ROOT / "test/privacy_session_controller_test.dart",
        "composition_test": ROOT / "test/privacy_lock_composition_test.dart",
        "shell": ROOT / "lib/features/shell/presentation/breakwave_shell.dart",
        "unlock_screen": ROOT / "lib/features/privacy_lock/presentation/privacy_unlock_screen.dart",
        "iap": ROOT / "docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md",
    }

    for name, path in paths.items():
        if not path.is_file():
            print(f"FAIL missing {name}: {path.relative_to(ROOT)}")
            failed = True

    if failed:
        raise SystemExit(1)

    texts = {
        name: path.read_text(encoding="utf-8")
        for name, path in paths.items()
    }

    def require(name: str, needle: str) -> None:
        nonlocal failed
        if needle not in texts[name]:
            print(f"FAIL {name} missing: {needle}")
            failed = True

    for needle in [
        "failedAttemptCount",
        "cooldownUntilUtc",
        "schemaVersion",
        "isCoolingDownAt",
    ]:
        require("attempt_state", needle)

    require("attempt_store", "bw_privacy_lock_attempt_v1")
    require("attempt_store", "defensiveFailureState")
    require("attempt_store", "SharedPreferences")

    require("config_store", "bw_privacy_lock_config_v2")
    require("config_store", "failClosedConfiguration")
    require("config_store", "PrivacyLockMode.fullApp")

    for forbidden in [
        "PrivacyLockSettings",
        "PrivacyLockStore",
        "LogRepository",
        "PersonalWhy",
        "Recovery",
    ]:
        if forbidden in texts["attempt_store"]:
            print(f"FAIL attempt_store references protected/legacy data: {forbidden}")
            failed = True
        if forbidden in texts["config_store"]:
            print(f"FAIL config_store references protected/legacy data: {forbidden}")
            failed = True

    for method in [
        "Future<void> initialize()",
        "Future<void> enterRescueSafe()",
        "Future<PrivacyAuthResult> unlockWithPin(String pin)",
        "Future<PrivacyAuthResult> unlockWithBiometrics()",
        "void authenticationCancelled()",
        "void onBackgrounded(DateTime at)",
        "void onResumed(DateTime at)",
        "void lockNow()",
        "Future<void> applyConfiguration(",
    ]:
        require("controller", method)

    for needle in [
        "failedAttemptCooldownThreshold = 10",
        "failedAttemptCooldownDuration = const Duration(minutes: 5)",
        "relockGracePeriod = const Duration(minutes: 2)",
        "PrivacySessionState.rescueSafe",
        "PrivacySessionState.authenticating",
        "PrivacySessionState.unlocked",
        "PrivacyAttemptStore.defensiveFailureState",
        "requestProtectedDestination",
        "takeRequestedProtectedDestination",
    ]:
        require("controller", needle)

    for forbidden in [
        "LogRepository",
        "RescueScreen",
        "PersonalWhy",
        "RevenueCat",
        "Purchases",
    ]:
        if forbidden in texts["controller"]:
            print(f"FAIL controller owns forbidden recovery/billing concern: {forbidden}")
            failed = True

    require("composition", "sessionControllerFor")
    require("composition", "PrivacySessionController(")
    require("composition_test", "session controller composition stays unhooked and injectable")

    for phrase in [
        "cold enabled start is locked",
        "enter Rescue-safe never grants an unlocked session",
        "successful PIN auth unlocks and clears persistent attempts",
        "auth cancellation returns to Rescue-safe",
        "manual authenticationCancelled invalidates stale success",
        "two-minute grace preserves then relocks an unlocked session",
        "restart semantics preserve an active cooldown",
        "ten failed PIN attempts enter a persisted five-minute cooldown",
        "cooldown never blocks Rescue-safe",
        "biometric failure never increments the PIN counter",
    ]:
        require("controller_test", phrase)

    require("attempt_store_test", "malformed persisted security state fails closed")
    require("config_store_test", "malformed existing configuration fails closed")

    # IOS-G2E must remain architecture-only. Shell and current unlock UI are
    # deliberately untouched until IOS-G2F/Unlock refactor.
    if "privacy_session_controller.dart" in texts["shell"]:
        print("FAIL G2E prematurely wires PrivacySessionController into BreakWaveShell")
        failed = True
    if "PrivacySessionController" in texts["unlock_screen"]:
        print("FAIL G2E prematurely rewires PrivacyUnlockScreen")
        failed = True
    require("shell", "bool _sessionUnlocked = false;")
    require("unlock_screen", "entered == widget.settings.passcode")

    require("iap", "IOS-G2E — Persistent Attempt State + Session Controller")

    if failed:
        raise SystemExit(1)

    print(
        "PASS: IOS-G2E adds non-secret persistent attempt/configuration stores "
        "and an unhooked PrivacySessionController with 10-attempt/5-minute "
        "cooldown persistence, Rescue-safe availability, two-minute relock "
        "grace, biometric counter isolation, and no shell/runtime wiring."
    )


if __name__ == "__main__":
    main()
