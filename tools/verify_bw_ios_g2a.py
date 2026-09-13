#!/usr/bin/env python3
from pathlib import Path
import sys

failed = False

paths = {
    "contract": Path("docs/BW_IOS_G2_RSLC_1_0_RESCUE_SAFE_LOCK_CONTRACT.md"),
    "plan": Path("docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md"),
    "ios_shadow": Path(".github/workflows/breakwave-ios-shadow-ci.yml"),
    "ios_g1": Path(".github/workflows/breakwave-ios-g1-proof.yml"),
}

for name, path in paths.items():
    if not path.is_file():
        print(f"FAIL missing {name}: {path}")
        failed = True

if failed:
    sys.exit(1)

contract = paths["contract"].read_text(encoding="utf-8")
plan = paths["plan"].read_text(encoding="utf-8")
shadow = paths["ios_shadow"].read_text(encoding="utf-8")
g1 = paths["ios_g1"].read_text(encoding="utf-8")

required_contract = [
    "IOS-G2 / RSLC-1.0",
    "**Status:** LOCKED FOR IMPLEMENTATION",
    "Rescue-safe access is **not** an unlocked BreakWave session",
    "Plaintext PIN storage is prohibited",
    "com.breakwaveapp.breakwave",
]
for needle in required_contract:
    if needle not in contract:
        print(f"FAIL contract missing locked requirement: {needle}")
        failed = True

required_plan = [
    "IAP-1.0",
    "**Status:** LOCKED FOR IMPLEMENTATION",
    "IOS-G2A — Architecture Freeze + Candidate iOS CI",
    "breakwave/privacy_auth",
    "BreakWaveKeychainCredentialStore.swift",
    "RescueSafeScreen",
    "rescue_safe_outcome_store.dart",
]
for needle in required_plan:
    if needle not in plan:
        print(f"FAIL plan missing architecture requirement: {needle}")
        failed = True

required_shadow = [
    "name: BreakWave iOS Shadow CI",
    '"validation/bw-ios-*"',
    "runs-on: macos-26",
    'BREAKWAVE_FLUTTER_VERSION: "3.44.9"',
    "Checkout exact candidate commit",
    'test "${actual}" = "${GITHUB_SHA}"',
    "git diff --exit-code -- pubspec.lock",
    "python3 tools/breakwave_verify.py selftest",
    "python3 tools/verify_bw_ios_g2a.py",
    "flutter analyze --no-fatal-infos",
    "flutter test",
    "flutter build ios --simulator --debug",
    '"signing_used": False',
    '"apple_credentials_used": False',
    "actions/upload-artifact@v4",
]
for needle in required_shadow:
    if needle not in shadow:
        print(f"FAIL iOS Shadow workflow missing: {needle}")
        failed = True

for forbidden in [
    "BREAKWAVE_IOS_G1_BASELINE_SHA",
    "07406b26dc3a98170c6181ef5cc69dac1f468496",
    "APPLE_CERTIFICATE",
    "PROVISIONING_PROFILE",
]:
    if forbidden in shadow:
        print(f"FAIL iOS Shadow workflow contains forbidden G2A/signing token: {forbidden}")
        failed = True

required_g1 = [
    "name: BreakWave iOS G1 Proof",
    'BREAKWAVE_IOS_G1_BASELINE_SHA: "07406b26dc3a98170c6181ef5cc69dac1f468496"',
    "Checkout exact September baseline",
]
for needle in required_g1:
    if needle not in g1:
        print(f"FAIL IOS-G1 immutable-proof marker missing: {needle}")
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: IOS-G2A architecture documents are locked, IOS-G1 remains pinned "
    "to the September baseline, and candidate iOS Shadow CI verifies the exact "
    "validation SHA without Apple signing or production behavior changes."
)
