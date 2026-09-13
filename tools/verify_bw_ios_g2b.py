#!/usr/bin/env python3
from pathlib import Path
import re
import sys

failed = False

paths = {
    "session_state": Path(
        "lib/core/privacy_lock/privacy_session_state.dart"
    ),
    "destination": Path(
        "lib/core/privacy_lock/privacy_destination.dart"
    ),
    "access_class": Path(
        "lib/core/privacy_lock/privacy_access_class.dart"
    ),
    "route_policy": Path(
        "lib/core/privacy_lock/privacy_route_policy.dart"
    ),
    "configuration": Path(
        "lib/core/privacy_lock/privacy_lock_configuration.dart"
    ),
    "policy_test": Path("test/privacy_route_policy_test.dart"),
    "configuration_test": Path(
        "test/privacy_lock_configuration_test.dart"
    ),
    "g2a_contract": Path(
        "docs/BW_IOS_G2_RSLC_1_0_RESCUE_SAFE_LOCK_CONTRACT.md"
    ),
    "g2a_plan": Path(
        "docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md"
    ),
}

for name, path in paths.items():
    if not path.is_file():
        print(f"FAIL missing {name}: {path}")
        failed = True

if failed:
    sys.exit(1)

texts = {
    name: path.read_text(encoding="utf-8")
    for name, path in paths.items()
}

def require(name: str, needle: str) -> None:
    global failed
    if needle not in texts[name]:
        print(f"FAIL {name} missing: {needle}")
        failed = True

for value in [
    "locked",
    "rescueSafe",
    "authenticating",
    "unlocked",
]:
    require("session_state", value)

destinations = [
    "lockedLanding",
    "home",
    "rescueSafe",
    "rescuePersonalized",
    "log",
    "support",
    "personalWhy",
    "insights",
    "personalPlan",
    "routineHistory",
    "recoveryReport",
    "privacySettings",
    "trustedContact",
    "exports",
    "billing",
    "internalQa",
    "unknown",
]
for value in destinations:
    require("destination", value)

for value in ["publicLocked", "rescueSafe", "protected"]:
    require("access_class", value)

for destination in destinations:
    require(
        "route_policy",
        f"PrivacyDestination.{destination}:",
    )

for needle in [
    "PrivacyDestination.lockedLanding: PrivacyAccessClass.publicLocked",
    "PrivacyDestination.rescueSafe: PrivacyAccessClass.rescueSafe",
    "PrivacyDestination.unknown: PrivacyAccessClass.protected",
    "PrivacyLockMode.fullApp",
    "PrivacyLockMode.sensitiveSections",
    "PrivacySessionState.unlocked",
    "PrivacyDestination.home",
    "PrivacyDestination.rescuePersonalized",
]:
    require("route_policy", needle)

for forbidden in [
    "package:flutter/",
    "package:flutter_",
    "dart:io",
    "MethodChannel",
    "SharedPreferences",
    "LocalAuthentication",
    "Keychain",
]:
    for name in [
        "session_state",
        "destination",
        "access_class",
        "route_policy",
        "configuration",
    ]:
        if forbidden in texts[name]:
            print(
                f"FAIL pure-Dart policy layer contains "
                f"platform/UI dependency in {name}: {forbidden}"
            )
            failed = True

configuration = texts["configuration"]

for needle in [
    "final PrivacyLockMode mode;",
    "final bool biometricEnabled;",
    "final bool credentialConfigured;",
    "final int schemaVersion;",
    "static const int currentSchemaVersion = 2;",
    "credentialConfigured",
    "? PrivacyLockMode.fullApp",
]:
    require("configuration", needle)

approved_metadata_keys = {
    "mode",
    "biometricEnabled",
    "credentialConfigured",
    "schemaVersion",
}
to_map_block = configuration.split(
    "Map<String, dynamic> toMap() {", 1
)[1].split(
    "factory PrivacyLockConfiguration.fromMap", 1
)[0]

serialized_keys = set(
    re.findall(r"'([^']+)':", to_map_block)
)
read_keys = set(
    re.findall(r"map\['([^']+)'\]", configuration)
)

unexpected_keys = sorted(
    (serialized_keys | read_keys) - approved_metadata_keys
)
if unexpected_keys:
    print(
        "FAIL configuration contains unapproved serialized keys: "
        + ", ".join(unexpected_keys)
    )
    failed = True

for forbidden_secret in [
    "passcode",
    "rawPin",
    "pinHash",
    "pinVerifier",
]:
    if forbidden_secret.lower() in configuration.lower():
        print(
            "FAIL configuration model contains credential material: "
            + forbidden_secret
        )
        failed = True

for needle in [
    "every destination has exactly one classification",
    "all mode/state/destination combinations match the contract",
    "Rescue-safe state does not unlock protected full-app routes",
    "authenticating state does not grant protected access",
    "sensitive-sections mode protects designated sensitive routes",
]:
    require("policy_test", needle)

for needle in [
    "serializes only the approved non-secret metadata keys",
    "round-trips every lock mode without secret material",
    "biometrics cannot remain enabled without a credential",
    "unknown configured lock mode fails closed to full-app lock",
]:
    require("configuration_test", needle)

require(
    "g2a_contract",
    "Rescue-safe access is **not** an unlocked BreakWave session",
)
require(
    "g2a_plan",
    "IOS-G2B — Pure Dart Privacy Policy Types",
)

if failed:
    sys.exit(1)

print(
    "PASS: IOS-G2B defines a pure-Dart, fail-closed privacy state and "
    "route policy; Rescue-safe remains distinct from unlocked; unknown "
    "destinations are protected; and v2 configuration serializes only "
    "approved non-secret metadata."
)
