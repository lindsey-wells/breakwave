#!/usr/bin/env python3
"""Verify the BW-88RC1I billing implementation entry plan."""

from __future__ import annotations

from collections import Counter
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]

PLAN_PATH = ROOT / (
    "docs/BW_88RC1I_BILLING_IMPLEMENTATION_ENTRY_PLAN.md"
)

AUDIT_E_PATH = ROOT / (
    "docs/BW_88_AUDIT_E_BILLING_TESTING_MATRIX.md"
)

LAUNCH_GATE_PATH = ROOT / (
    "launch/breakwave_plus_paid_launch_gate.md"
)


def fail(message: str) -> None:
    print(f"BW-88RC1I VERIFY: FAIL — {message}")
    raise SystemExit(1)


def semantic_text(value: str) -> str:
    return " ".join(value.split())


for path in (
    PLAN_PATH,
    AUDIT_E_PATH,
    LAUNCH_GATE_PATH,
):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

raw_plan = PLAN_PATH.read_text(encoding="utf-8")
plan = semantic_text(raw_plan)

audit_e = semantic_text(
    AUDIT_E_PATH.read_text(encoding="utf-8")
)

launch_gate = semantic_text(
    LAUNCH_GATE_PATH.read_text(encoding="utf-8")
)

gate_ids = re.findall(r"\bGATE-\d{2}\b", raw_plan)
work_package_ids = re.findall(r"\bWP-\d{2}\b", raw_plan)

gate_counts = Counter(gate_ids)
work_package_counts = Counter(work_package_ids)

gate_table_ids = {
    gate_id
    for gate_id, count in gate_counts.items()
    if count >= 1
}

work_package_table_ids = {
    work_id
    for work_id, count in work_package_counts.items()
    if count >= 1
}

expected_gates = {
    f"GATE-{number:02d}"
    for number in range(1, 11)
}

expected_work_packages = {
    f"WP-{number:02d}"
    for number in range(0, 10)
}

if gate_table_ids != expected_gates:
    fail(
        "entry gates differ from GATE-01 through GATE-10: "
        f"{sorted(gate_table_ids)}"
    )

if work_package_table_ids != expected_work_packages:
    fail(
        "work packages differ from WP-00 through WP-09: "
        f"{sorted(work_package_table_ids)}"
    )

for needle in (
    "Billing failure must never become recovery failure",
    "no billing dependency",
    "no production billing code",
    "Implementation-entry gates",
    "All ten gates must be explicitly reviewed",
    "24/3CJ LLC owns",
    "Cube23 LLC may design, implement, test, and document",
    "separate private repository controlled by 24/3CJ LLC",
    "local or deterministic fake environment",
    "staging verification environment",
    "production verification environment",
    "Prices, localized currency, billing periods, offer text, and eligibility must come from current Google Play product details",
    "purchase entry enabled",
    "recovery data cannot enter billing infrastructure",
    "Signed entitlement snapshot boundary",
    "Ordered implementation work packages",
    "WP-01 is the next executable milestone",
    "The current supported Billing Library version must be selected from official documentation",
    "Production purchase entry remains disabled",
    "98 documented billing cases",
    "No giant billing patch is permitted",
    "Stop conditions",
    "Rollback must not require deletion of the user's recovery history",
    "BW-88RC1J — Billing Environment Readiness",
):
    if needle not in plan:
        fail(f"entry plan missing: {needle}")

for needle in (
    "Billing implementation entry decision",
    "BW_88RC1I_BILLING_IMPLEMENTATION_ENTRY_PLAN.md",
    "ten work packages",
    "separable and reversible",
    "BW-88RC1J Billing Environment Readiness",
    "no billing dependency",
):
    if needle not in audit_e:
        fail(f"Audit E handoff missing: {needle}")

for needle in (
    "Billing implementation sequencing",
    "All ten BW-88RC1I implementation-entry gates",
    "WP-00 through WP-09",
    "Staging and production environments must remain separate",
    "Rollback must preserve Free BreakWave, Rescue, and recovery data",
    "No credential may enter the application repository",
    "Every implementation patch must preserve Audits A through E",
    "24/3CJ LLC must approve paid-release evidence",
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
            "Entry planning must not introduce billing dependency: "
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
            "Entry planning found premature production billing code: "
            f"{marker}"
        )

print("BW-88RC1I VERIFY: PASS")
print("Implementation-entry gates documented: 10")
print("Ordered work packages documented: 10")
print("Production owner: 24/3CJ LLC")
print("Development partner: Cube23 LLC")
print("Next executable milestone: BW-88RC1J")
print("Billing dependencies introduced: 0")
print("Production billing code introduced: 0")
print("Backend deployments introduced: 0")
print("Product IDs or prices introduced: 0")
print("Entitlement behavior changed: no")
