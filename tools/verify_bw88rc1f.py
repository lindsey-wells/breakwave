#!/usr/bin/env python3
"""Verify the Audit C billing architecture decision."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

DECISION_PATH = ROOT / (
    "docs/BW_88_AUDIT_C_BILLING_ARCHITECTURE_DECISION.md"
)

PRODUCT_CONTRACT_PATH = ROOT / (
    "docs/BW_87B6P_PRODUCT_ACCESS_CONTRACT.md"
)

LAUNCH_GATE_PATH = ROOT / (
    "launch/breakwave_plus_paid_launch_gate.md"
)


def fail(message: str) -> None:
    print(f"BW-88RC1F VERIFY: FAIL — {message}")
    raise SystemExit(1)


for path in (
    DECISION_PATH,
    PRODUCT_CONTRACT_PATH,
    LAUNCH_GATE_PATH,
):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

def semantic_text(value: str) -> str:
    """Normalize Markdown wrapping without changing meaning."""

    return " ".join(value.split())


decision = semantic_text(
    DECISION_PATH.read_text(encoding="utf-8")
)

product_contract = semantic_text(
    PRODUCT_CONTRACT_PATH.read_text(
        encoding="utf-8"
    )
)

launch_gate = semantic_text(
    LAUNCH_GATE_PATH.read_text(
        encoding="utf-8"
    )
)

for needle in (
    "privacy-first minimal-backend architecture",
    "device will not be the authoritative source",
    "Rejected approach",
    "grant Plus directly from a purchase callback",
    "acknowledge eligible initial purchases",
    "Real-time developer notifications",
    "RTDN is a signal to refresh state",
    "Active | Granted",
    "Grace period | Granted",
    "Pending | Not granted",
    "Account hold | Suspended",
    "Restore Purchases",
    "mandatory BreakWave recovery account is not required",
    "purchase token will be the primary billing-record identifier",
    "Signed entitlement snapshot",
    "first-time Plus grant requires online backend verification",
    "Billing-data allowlist",
    "Billing-data denylist",
    "recovery logs",
    "Personal Why text or images",
    "24/3CJ LLC production environment",
    "Billing failure must never become recovery failure",
    "Flutter billing-package selection",
    "exact offline duration",
):
    if needle not in decision:
        fail(f"architecture decision missing: {needle}")

for needle in (
    "Audit C production billing decision",
    "privacy-first minimal-backend architecture",
    "must not become the production billing authority",
    "verified, signed entitlement snapshot",
    "No recovery data may enter",
    "Billing failure must never become recovery failure",
):
    if needle not in product_contract:
        fail(f"product contract missing: {needle}")

for needle in (
    "Verified billing architecture",
    "Purchase tokens must be verified through a minimal secure backend",
    "Pending purchases must not grant Plus",
    "RTDN processing must be idempotent",
    "Restore Purchases must re-verify current Play purchases",
    "No recovery data may enter billing infrastructure",
    "Audit D lifecycle rules and Audit E test coverage",
):
    if needle not in launch_gate:
        fail(f"paid-launch gate missing: {needle}")

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
            "Audit C must not introduce billing dependency: "
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
            "premature production billing code found: "
            f"{marker}"
        )

print("BW-88RC1F VERIFY: PASS")
print("Architecture: privacy-first minimal backend")
print("Client-only billing authority: rejected")
print("Backend purchase verification: required")
print("RTDN authoritative refresh: required")
print("Recovery data allowed in billing infrastructure: 0")
print("Billing dependencies introduced: 0")
print("Production billing code introduced: 0")
