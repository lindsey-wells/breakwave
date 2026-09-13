#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
RUNNER = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"
G2E_REF = "ddb21693e3fa3b1d2ca67a6bb866e0884c37b330"
HISTORICAL_PRIVACY_VERIFIERS = [
    "tools/verify_bw41.py",
    "tools/verify_bw49a.py",
    "tools/verify_bw49c.py",
    "tools/verify_bw49c1.py",
    "tools/verify_bw_ios_g2e.py",
]


def insert_after_line(text: str, anchor: str, addition: str, label: str) -> str:
    lines = text.splitlines(keepends=True)
    matches = [index for index, line in enumerate(lines) if line == anchor]
    if len(matches) != 1:
        raise SystemExit(
            f"STOP IOS-G2F apply: expected one {label} anchor, found {len(matches)}"
        )
    lines.insert(matches[0] + 1, addition)
    return "".join(lines)


def apply_stage() -> None:
    text = RUNNER.read_text(encoding="utf-8")

    mapping_anchor = (
        '    "tools/verify_bw_ios_g2c.py": '
        '"1a718ea0bcbdac31cd12bd2c747d5abe279c9cbc",\n'
    )
    expected_anchor = (
        '        "tools/verify_bw_ios_g2c.py": '
        '"1a718ea0bcbdac31cd12bd2c747d5abe279c9cbc",\n'
    )
    list_anchor = '            "tools/verify_bw_ios_g2c.py",\n'

    last_mapping = mapping_anchor
    last_expected = expected_anchor
    last_list = list_anchor

    for rel in HISTORICAL_PRIVACY_VERIFIERS:
        mapping_line = f'    "{rel}": "{G2E_REF}",\n'
        expected_line = f'        "{rel}": "{G2E_REF}",\n'
        list_line = f'            "{rel}",\n'

        if mapping_line not in text:
            text = insert_after_line(text, last_mapping, mapping_line, f"{rel} phase mapping")
        last_mapping = mapping_line

        if expected_line not in text:
            text = insert_after_line(text, last_expected, expected_line, f"{rel} selftest mapping")
        last_expected = expected_line

        if list_line not in text:
            text = insert_after_line(text, last_list, list_line, f"{rel} selftest verifier list")
        last_list = list_line

    RUNNER.write_text(text, encoding="utf-8")
    print(
        "APPLIED: IOS-G2F pins superseded Android privacy-lock and G2E "
        f"verifiers to {G2E_REF}."
    )


def verify() -> None:
    failed = False

    paths = {
        "legacy_config": ROOT / "lib/core/privacy_lock/platform/legacy_android_privacy_lock_configuration_store.dart",
        "composition": ROOT / "lib/core/privacy_lock/privacy_lock_composition.dart",
        "locked_screen": ROOT / "lib/features/privacy_lock/presentation/privacy_locked_screen.dart",
        "unlock_screen": ROOT / "lib/features/privacy_lock/presentation/privacy_unlock_screen.dart",
        "shell": ROOT / "lib/features/shell/presentation/breakwave_shell.dart",
        "legacy_config_test": ROOT / "test/legacy_android_privacy_lock_configuration_store_test.dart",
        "locked_screen_test": ROOT / "test/privacy_locked_screen_test.dart",
        "unlock_screen_test": ROOT / "test/privacy_unlock_screen_test.dart",
        "route_gate_test": ROOT / "test/privacy_route_gate_integration_test.dart",
        "ios_settings_guard_test": ROOT / "test/privacy_lock_settings_ios_guard_test.dart",
        "runner": RUNNER,
        "settings_card": ROOT / "lib/features/support/presentation/widgets/privacy_lock_settings_card.dart",
        "iap": ROOT / "docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md",
    }

    for name, path in paths.items():
        if not path.is_file():
            print(f"FAIL missing {name}: {path.relative_to(ROOT)}")
            failed = True

    if failed:
        raise SystemExit(1)

    texts = {name: path.read_text(encoding="utf-8") for name, path in paths.items()}

    def require(name: str, needle: str) -> None:
        nonlocal failed
        if needle not in texts[name]:
            print(f"FAIL {name} missing: {needle}")
            failed = True

    for needle in [
        "implements PrivacyLockConfigurationStoreApi",
        "PrivacyLockStore.load",
        "PrivacyLockStore.save",
        "settings.isEnabled ? settings.mode : PrivacyLockMode.none",
        "credentialConfigured: credentialConfigured",
        "biometricEnabled: false",
    ]:
        require("legacy_config", needle)

    require("composition", "LegacyAndroidPrivacyLockConfigurationStore()")
    require("composition", "configurationStoreFor")
    require("composition", "IosPrivacyCredentialGateway()")

    for needle in [
        "class PrivacyLockedScreen",
        "Unlock BreakWave",
        "Open Rescue",
        "Rescue-safe access",
        "Back to privacy lock",
    ]:
        require("locked_screen", needle)

    for forbidden in [
        "LogRepository",
        "RescueScreen",
        "RememberWhy",
        "PersonalWhy",
        "RevenueCat",
        "Purchases",
        "PrivacyLockStore",
    ]:
        if forbidden in texts["locked_screen"]:
            print(f"FAIL locked_screen references protected dependency: {forbidden}")
            failed = True

    for needle in [
        "PrivacySessionController",
        "unlockWithPin(pin)",
        "remainingPinCooldown",
        "failedAttemptCooldownThreshold",
        "authenticationCancelled()",
    ]:
        require("unlock_screen", needle)

    for forbidden in [
        "PrivacyLockSettings",
        "widget.settings.passcode",
        "entered ==",
        "_failedAttempts =",
        "_cooldownUntil =",
    ]:
        if forbidden in texts["unlock_screen"]:
            print(f"FAIL unlock_screen still owns legacy credential/security state: {forbidden}")
            failed = True

    for needle in [
        "PrivacyLockComposition.sessionControllerFor",
        "PrivacyRoutePolicy.requiresAuthentication",
        "PrivacyLockedScreen(",
        "PrivacyUnlockScreen(",
        "PrivacySessionState.rescueSafe",
        "requestProtectedDestination",
        "takeRequestedProtectedDestination",
        "Navigator.of(context).popUntil",
        "_buildAllowedShell()",
        "_requestDestinationOrRun",
    ]:
        require("shell", needle)

    for forbidden in [
        "bool _sessionUnlocked",
        "PrivacyLockSettings _lockSettings",
        "entered == widget.settings.passcode",
    ]:
        if forbidden in texts["shell"]:
            print(f"FAIL shell retains superseded lock ownership: {forbidden}")
            failed = True

    prefix = texts["shell"].split("Widget _buildAllowedShell()", 1)[0]
    for constructor in [
        "HomeScreen(",
        "RescueScreen(",
        "LogScreen(",
        "SupportScreen(",
        "BillingQaScreen(",
    ]:
        if constructor in prefix:
            print(
                "FAIL shell constructs protected/normal content before privacy gate: "
                + constructor
            )
            failed = True

    for phrase in [
        "Full App locked landing exposes Unlock BreakWave and Open Rescue",
        "Rescue-safe holding surface remains generic and still locked",
    ]:
        require("locked_screen_test", phrase)

    for phrase in [
        "unlock presentation delegates PIN verification to controller",
        "wrong PIN copy comes from persistent controller attempt state",
        "cancel never authenticates or exposes stored credential material",
    ]:
        require("unlock_screen_test", phrase)

    for phrase in [
        "Full App locked route gate exposes only locked landing and Rescue-safe",
        "requested protected destination survives failure and opens after success",
        "Sensitive Sections keeps Home and personalized Rescue open but gates Log",
    ]:
        require("route_gate_test", phrase)

    require("legacy_config_test", "cannot invent a legacy credential from non-secret metadata")
    require("ios_settings_guard_test", "iOS settings guard exposes no legacy raw-PIN entry controls")

    # G2F keeps Android settings on the released compatibility path but blocks
    # legacy raw-PIN writes on iOS until the native settings migration lands.
    for needle in [
        "defaultTargetPlatform == TargetPlatform.iOS",
        "if (_isIos || _saving) return;",
        "iPhone privacy-lock setup is being finalized with Keychain protection",
        "PrivacyLockStore.save(",
    ]:
        require("settings_card", needle)

    require("shell", "await PrivacyLockStore.clear();")

    for rel in HISTORICAL_PRIVACY_VERIFIERS:
        require("runner", f'"{rel}": "{G2E_REF}"')
    require("iap", "IOS-G2F — Locked Landing + Route Gate")

    if failed:
        raise SystemExit(1)

    print(
        "PASS: IOS-G2F wires PrivacySessionController into BreakWaveShell, "
        "adds a fail-closed locked landing and controller-driven PIN unlock, "
        "keeps Open Rescue separate from authentication, gates protected routes, "
        "preserves released Android lock configuration through a compatibility "
        "store, blocks legacy raw-PIN settings writes on iOS, and phase-pins "
        "superseded privacy verifiers historically."
    )


if __name__ == "__main__":
    if sys.argv[1:] == ["--apply-stage"]:
        apply_stage()
    elif sys.argv[1:]:
        raise SystemExit("Usage: verify_bw_ios_g2f.py [--apply-stage]")
    else:
        verify()
