#!/usr/bin/env python3
"""Verify Audit B pre-billing language hardening."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

PLUS_PATH = ROOT / (
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

GATE_PATH = ROOT / (
    "lib/features/premium/presentation/"
    "premium_gate_tile.dart"
)

FAITH_PATH = ROOT / (
    "lib/features/faith/presentation/"
    "faith_depth_pack_screen.dart"
)

CONTRACT_PATH = ROOT / (
    "docs/BW_88_AUDIT_B_PLUS_LANGUAGE_CONTRACT.md"
)

REQUIRED_FILES = (
    PLUS_PATH,
    GATE_PATH,
    FAITH_PATH,
    CONTRACT_PATH,
)


def fail(message: str) -> None:
    print(f"BW-88RC1E VERIFY: FAIL — {message}")
    raise SystemExit(1)


for path in REQUIRED_FILES:
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

plus = PLUS_PATH.read_text(encoding="utf-8")
gate = GATE_PATH.read_text(encoding="utf-8")
faith = FAITH_PATH.read_text(encoding="utf-8")
contract = CONTRACT_PATH.read_text(encoding="utf-8")

for needle in (
    "BreakWave Plus is in development.",
    "Subscriptions and purchases are not enabled.",
    "No charge can occur from this screen.",
    "Plan structure and pricing will be finalized only after",
    "If monthly and annual plans are both offered",
):
    if needle not in plus:
        fail(f"Plus screen missing safe language: {needle}")

for forbidden in (
    "class _PlanRow",
    "required this.price",
    "final String price;",
    "Monthly and annual plans will include the same core recovery features.",
    "$59.99/year",
    "$8.99/month",
    "Subscription pricing preview",
    "Expected launch pricing",
):
    if forbidden in plus:
        fail(f"Plus screen retains stale pricing language: {forbidden}")

for needle in (
    "this.availableText = 'Preview available'",
    "this.unavailableText = 'Planned for BreakWave Plus'",
    "final String availableText",
    "final String unavailableText",
    "? widget.availableText",
    ": widget.unavailableText",
):
    if needle not in gate:
        fail(f"Premium gate missing preview language: {needle}")

for forbidden in (
    "unlockedText",
    "'Unlocked'",
    "'Available in BreakWave Plus'",
):
    if forbidden in gate:
        fail(f"Premium gate retains misleading state: {forbidden}")

for needle in (
    "'Planned for BreakWave Plus'",
    "Core Rescue and basic Christian support stay free.",
    "Purchasing is not available yet.",
    "child: Text('Review BreakWave Plus')",
):
    if needle not in faith:
        fail(f"Faith depth screen missing safe language: {needle}")

for forbidden in (
    "'Locked in BreakWave Plus'",
    "child: Text('Open BreakWave Plus')",
    "deeper transformation layer inside BreakWave Plus",
):
    if forbidden in faith:
        fail(f"Faith depth screen retains misleading language: {forbidden}")

for needle in (
    "BreakWave Plus Language Contract",
    "Preview available",
    "Planned for BreakWave Plus",
    "Review BreakWave Plus",
    "purchasing is not available yet",
    "Restore Purchases remains a future production requirement",
    "Billing language must never pressure a user during an urge",
):
    if needle not in contract:
        fail(f"Audit B contract missing: {needle}")

production_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (ROOT / "lib").rglob("*.dart")
)

for forbidden in (
    "$59.99/year",
    "$8.99/month",
    "Select annual no-trial",
    "Select annual 7-day trial",
    "Subscribe now",
    "Buy now",
    "Start trial",
    "Purchase successful",
    "Purchases restored",
    "BreakWave Plus unlocked.",
):
    if forbidden.lower() in production_text.lower():
        fail(f"active production claim remains: {forbidden}")

dependency_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (
        ROOT / "pubspec.yaml",
        ROOT / "pubspec.lock",
    )
    if path.is_file()
)

for forbidden_dependency in (
    "in_app_purchase",
    "purchases_flutter",
    "revenuecat",
):
    if forbidden_dependency.lower() in dependency_text.lower():
        fail(
            "Audit B must not introduce billing dependency: "
            f"{forbidden_dependency}"
        )

print("BW-88RC1E VERIFY: PASS")
print("Active fake prices found: 0")
print("Active purchase or restore-success claims found: 0")
print("Misleading locked/open/unlocked Plus wording found: 0")
print("Billing dependencies introduced: 0")
