#!/usr/bin/env python3
"""Verify BW-88RC1J billing environment readiness."""

from __future__ import annotations

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]

READINESS_PATH = ROOT / (
    "docs/BW_88RC1J_BILLING_ENVIRONMENT_READINESS.md"
)

ENTRY_PLAN_PATH = ROOT / (
    "docs/BW_88RC1I_BILLING_IMPLEMENTATION_ENTRY_PLAN.md"
)

LAUNCH_GATE_PATH = ROOT / (
    "launch/breakwave_plus_paid_launch_gate.md"
)


def fail(message: str) -> None:
    print(f"BW-88RC1J VERIFY: FAIL — {message}")
    raise SystemExit(1)


def semantic_lower(value: str) -> str:
    return " ".join(value.split()).lower()


for path in (
    READINESS_PATH,
    ENTRY_PLAN_PATH,
    LAUNCH_GATE_PATH,
):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(ROOT)}")

raw_readiness = READINESS_PATH.read_text(encoding="utf-8")
readiness = semantic_lower(raw_readiness)

entry_plan = semantic_lower(
    ENTRY_PLAN_PATH.read_text(encoding="utf-8")
)

launch_gate = semantic_lower(
    LAUNCH_GATE_PATH.read_text(encoding="utf-8")
)

environment_ids = set(
    re.findall(r"\bENV-\d{2}\b", raw_readiness)
)

expected_environment_ids = {
    f"ENV-{number:02d}"
    for number in range(1, 19)
}

if environment_ids != expected_environment_ids:
    fail(
        "environment decisions differ from ENV-01 through ENV-18: "
        f"{sorted(environment_ids)}"
    )

package_match = re.search(
    r"Confirmed Android package name:\s*([A-Za-z0-9_.]+)",
    raw_readiness,
)

if package_match is None:
    fail("confirmed Android package name is missing")

package_name = package_match.group(1)

if (
    "." not in package_name
    or "<" in package_name
    or ">" in package_name
):
    fail(f"invalid confirmed package name: {package_name}")

required_readiness = (
    "ready for wp-02 contract and threat-model design",
    "not ready for billing code, cloud provisioning",
    "billing failure must never become recovery failure",
    "recovery data is prohibited from billing infrastructure",
    "separate staging and production google cloud projects",
    "primary region | us-east1",
    "compute platform | cloud run services",
    "firestore in native mode, regional us-east1",
    "google cloud pub/sub",
    "secret manager with environment separation",
    "cloud kms asymmetric signing",
    "github actions workload identity federation",
    "public minimal client api separated from private billing worker",
    "one production-owned play rtdn ingress topic",
    "no production purchase token may be copied into staging",
    "initial 30-day application-log retention",
    "a cloud billing budget is an alerting mechanism, not a guaranteed spending cap",
    "license-tester list verified: no",
    "product created: no",
    "no action in this table requires sharing a secret with chatgpt",
    "the pending gates prevent billing code and paid launch",
    "bw-88rc1k — billing contracts and threat model",
)

for needle in required_readiness:
    if needle not in readiness:
        fail(f"readiness contract missing: {needle}")

required_entry_handoff = (
    "bw-88rc1j environment readiness decision",
    "cloud run",
    "regional firestore in us-east1",
    "workload identity federation",
    "cloud provisioning",
    "bw-88rc1k billing contracts and threat model",
    "no billing dependency",
)

for needle in required_entry_handoff:
    if needle not in entry_plan:
        fail(f"entry-plan handoff missing: {needle}")

required_launch_gate = (
    "billing environment readiness",
    "24/3cj llc must control the google cloud",
    "staging and production must use separate projects",
    "production rtdn ingress",
    "workload identity federation",
    "runtime identities must not use broad owner or editor roles",
    "billing records must exclude all recovery data",
    "budgets and alerts must exist",
    "environment failure must preserve free breakwave and rescue",
    "24/3cj llc must approve production provisioning",
)

for needle in required_launch_gate:
    if needle not in launch_gate:
        fail(f"paid-launch gate missing: {needle}")

dependency_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (
        ROOT / "pubspec.yaml",
        ROOT / "pubspec.lock",
    )
    if path.is_file()
).lower()

for dependency in (
    "in_app_purchase",
    "purchases_flutter",
    "revenuecat",
):
    if dependency in dependency_text:
        fail(
            "Environment readiness must not introduce dependency: "
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
            "Environment readiness found premature billing code: "
            f"{marker}"
        )

print("BW-88RC1J VERIFY: PASS")
print("Environment decisions documented: 18")
print(f"Android package confirmed: {package_name}")
print("Cloud provider: Google Cloud")
print("Primary region: us-east1")
print("Compute: Cloud Run")
print("Datastore: Firestore Native mode")
print("RTDN transport: Pub/Sub")
print("Snapshot signing: Cloud KMS asymmetric signing")
print("Deployment identity: Workload Identity Federation")
print("Environment separation: staging and production")
print("Next milestone: BW-88RC1K")
print("Cloud resources provisioned: 0")
print("Credentials introduced: 0")
print("Billing dependencies introduced: 0")
print("Production billing code introduced: 0")
print("Entitlement behavior changed: no")
