#!/usr/bin/env python3
"""Verify the Audit E billing testing matrix."""

from __future__ import annotations

from collections import Counter
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]

MATRIX_PATH = ROOT / (
    "docs/BW_88_AUDIT_E_BILLING_TESTING_MATRIX.md"
)

AUDIT_D_PATH = ROOT / (
    "docs/BW_88_AUDIT_D_SUBSCRIPTION_LIFECYCLE_MATRIX.md"
)

LAUNCH_GATE_PATH = ROOT / (
    "launch/breakwave_plus_paid_launch_gate.md"
)


def fail(message: str) -> None:
    print(f"BW-88RC1H VERIFY: FAIL — {message}")
    raise SystemExit(1)


def semantic_text(value: str) -> str:
    return " ".join(value.split())


for path in (
    MATRIX_PATH,
    AUDIT_D_PATH,
    LAUNCH_GATE_PATH,
):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

raw_matrix = MATRIX_PATH.read_text(encoding="utf-8")
matrix = semantic_text(raw_matrix)

audit_d = semantic_text(
    AUDIT_D_PATH.read_text(encoding="utf-8")
)

launch_gate = semantic_text(
    LAUNCH_GATE_PATH.read_text(encoding="utf-8")
)

test_ids = re.findall(
    r"\b(?:SAF|CAT|PUR|ACK|LIF|RTD|RST|OFF|SEC|UXS|OPS)-\d{3}\b",
    raw_matrix,
)

unique_test_ids = set(test_ids)

if len(test_ids) != len(unique_test_ids):
    counts = Counter(test_ids)
    duplicates = sorted(
        test_id
        for test_id, count in counts.items()
        if count > 1
    )
    fail(f"duplicate test IDs: {duplicates}")

expected_prefix_counts = {
    "SAF": 8,
    "CAT": 6,
    "PUR": 10,
    "ACK": 6,
    "LIF": 16,
    "RTD": 8,
    "RST": 8,
    "OFF": 10,
    "SEC": 10,
    "UXS": 8,
    "OPS": 8,
}

actual_prefix_counts = Counter(
    test_id.split("-", 1)[0]
    for test_id in unique_test_ids
)

for prefix, expected in expected_prefix_counts.items():
    actual = actual_prefix_counts[prefix]

    if actual != expected:
        fail(
            f"{prefix} test count expected {expected}, "
            f"found {actual}"
        )

expected_total = sum(expected_prefix_counts.values())

if len(unique_test_ids) != expected_total:
    fail(
        f"expected {expected_total} unique tests, "
        f"found {len(unique_test_ids)}"
    )

for needle in (
    "Billing failure must never become recovery failure",
    "All P0 and P1 tests must pass before paid release",
    "Layer S0",
    "Layer S1",
    "Layer S2",
    "Layer S3",
    "Layer S4",
    "license tester",
    "Play Billing Lab",
    "A test-track user who is not a license tester may incur a real charge",
    "Safety and protected-Free tests",
    "Product-catalog and pricing tests",
    "Purchase-flow tests",
    "Acknowledgement tests",
    "Lifecycle-state tests",
    "RTDN and authoritative-refresh tests",
    "Restore and device-change tests",
    "Offline and signed-snapshot tests",
    "Security and privacy tests",
    "User experience and accessibility tests",
    "Operational and release-evidence tests",
    "slow card that approves",
    "slow card that declines",
    "72-hour Active offline boundary",
    "24-hour Grace Period offline boundary",
    "Stop-ship conditions",
    "24/3CJ LLC approves the release evidence",
):
    if needle not in matrix:
        fail(f"testing contract missing: {needle}")

for needle in (
    "Audit E testing decision",
    "BW_88_AUDIT_E_BILLING_TESTING_MATRIX.md",
    "Every P0 and P1 test must pass",
    "cannot be waived",
    "introduces no billing dependency",
):
    if needle not in audit_d:
        fail(f"Audit D handoff missing: {needle}")

for needle in (
    "Billing test evidence",
    "Every Audit E P0 and P1 test must pass",
    "Initial-purchase acknowledgement",
    "Restore Purchases must be verified",
    "Clock rollback must not extend Plus",
    "Recovery data must be absent",
    "No P0 or P1 defect may remain open",
    "24/3CJ LLC must approve",
):
    if needle not in launch_gate:
        fail(f"paid-launch gate missing: {needle}")

required_safety_assertions = (
    "No billing overlay, spinner, or gate blocks Rescue",
    "No Plus entitlement is granted",
    "Pending purchase is not acknowledged",
    "App does not say restored",
    "Evidence must not contain raw purchase tokens, credentials, recovery logs",
    "Rescue can be blocked by billing",
    "a Pending purchase grants Plus",
    "Restore Purchases claims success without verification",
)

for needle in required_safety_assertions:
    if needle not in matrix:
        fail(f"safety or stop-ship assertion missing: {needle}")

dependency_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (
        ROOT / "pubspec.yaml",
        ROOT / "pubspec.lock",
    )
    if path.is_file()
)

for dependency in (
    "in_app_purchase",
    "purchases_flutter",
    "revenuecat",
):
    if dependency.lower() in dependency_text.lower():
        fail(
            "Audit E must not introduce billing dependency: "
            f"{dependency}"
        )

production_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (ROOT / "lib").rglob("*.dart")
)

for marker in (
    "BillingClient",
    "purchaseStream",
    "buyNonConsumable",
    "buyConsumable",
    "launchBillingFlow",
):
    if marker in production_text:
        fail(
            "Audit E found premature production billing code: "
            f"{marker}"
        )

print("BW-88RC1H VERIFY: PASS")
print(f"Unique billing test cases documented: {expected_total}")
print("Safety and protected-Free tests: 8")
print("Purchase and acknowledgement tests: 16")
print("Lifecycle and RTDN tests: 24")
print("Restore and offline tests: 18")
print("Security and privacy tests: 10")
print("UX and operational tests: 16")
print("Required passing priorities: P0 and P1")
print("Recovery data allowed in billing tests: 0")
print("Billing dependencies introduced: 0")
print("Production billing code introduced: 0")
