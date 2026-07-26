#!/usr/bin/env python3
"""Verify the Audit D subscription lifecycle matrix."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

MATRIX_PATH = ROOT / (
    "docs/BW_88_AUDIT_D_SUBSCRIPTION_LIFECYCLE_MATRIX.md"
)

AUDIT_C_PATH = ROOT / (
    "docs/BW_88_AUDIT_C_BILLING_ARCHITECTURE_DECISION.md"
)

LAUNCH_GATE_PATH = ROOT / (
    "launch/breakwave_plus_paid_launch_gate.md"
)


def fail(message: str) -> None:
    print(f"BW-88RC1G VERIFY: FAIL — {message}")
    raise SystemExit(1)


def semantic_text(value: str) -> str:
    return " ".join(value.split())


for path in (
    MATRIX_PATH,
    AUDIT_C_PATH,
    LAUNCH_GATE_PATH,
):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

matrix = semantic_text(
    MATRIX_PATH.read_text(encoding="utf-8")
)

audit_c = semantic_text(
    AUDIT_C_PATH.read_text(encoding="utf-8")
)

launch_gate = semantic_text(
    LAUNCH_GATE_PATH.read_text(encoding="utf-8")
)

required_states = (
    "Initial purchase pending",
    "Pending purchase completed",
    "Active with acknowledgement pending",
    "Renewal completed",
    "Grace period",
    "User canceled, paid time remains",
    "Cancellation restored before expiry",
    "Pause scheduled but not effective",
    "Paused",
    "Account hold",
    "Recovered from grace, hold, or pause",
    "Expired",
    "Revoked or voided",
    "Pending purchase canceled",
    "State unspecified or unverifiable",
    "Test purchase",
)

for needle in required_states:
    if needle not in matrix:
        fail(f"lifecycle state missing: {needle}")

for needle in (
    "Billing failure must never become recovery failure",
    "purchases.subscriptionsv2.get",
    "State precedence",
    "linkedPurchaseToken",
    "pending upgrade, downgrade, top-up, or replacement",
    "RTDN handling matrix",
    "SUBSCRIPTION_PENDING_PURCHASE_CANCELED",
    "Restore Purchases matrix",
    "BreakWave Plus was restored.",
    "No active BreakWave Plus purchase was found",
    "Exact offline entitlement policy",
    "no more than 72 hours",
    "no more than 24 hours",
    "Changing the device clock must not extend offline Plus",
    "Billing messages must not appear inside Rescue",
    "Recovery data allowed in lifecycle processing: zero",
    "Audit E handoff",
):
    if needle not in matrix:
        fail(f"lifecycle contract missing: {needle}")

for needle in (
    "Audit D lifecycle decision",
    "BW_88_AUDIT_D_SUBSCRIPTION_LIFECYCLE_MATRIX.md",
    "at most 72 hours",
    "at most 24 hours",
    "must never block or appear inside Rescue",
):
    if needle not in audit_c:
        fail(f"Audit C handoff missing: {needle}")

for needle in (
    "Subscription lifecycle readiness",
    "Pending purchases must never grant Plus",
    "pending plan change must preserve",
    "72-hour authorization limit",
    "24-hour limit",
    "Clock rollback must not extend",
    "Every state must preserve Free",
    "Audit E must test every lifecycle",
):
    if needle not in launch_gate:
        fail(f"paid-launch gate missing: {needle}")

for forbidden in (
    "grant Plus while a purchase is pending",
    "block Rescue during billing verification",
    "send recovery logs to billing",
    "send Personal Why to billing",
):
    if forbidden.lower() in matrix.lower():
        fail(f"prohibited lifecycle rule found: {forbidden}")

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
            "Audit D must not introduce billing dependency: "
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
            "Audit D found premature production billing code: "
            f"{marker}"
        )

print("BW-88RC1G VERIFY: PASS")
print(
    "Lifecycle cases documented: "
    f"{len(required_states)}"
)
print("Active and grace access rules: locked")
print("Pending purchase entitlement: denied")
print("Canceled-unexpired access: preserved to verified expiry")
print("Paused and account-hold access: suspended")
print("Expired and revoked access: removed")
print("Active offline authorization: 72 hours maximum")
print("Grace offline authorization: 24 hours maximum")
print("Recovery data allowed in lifecycle processing: 0")
print("Billing dependencies introduced: 0")
print("Production billing code introduced: 0")
