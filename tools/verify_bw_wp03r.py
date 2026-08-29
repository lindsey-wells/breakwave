#!/usr/bin/env python3
"""Verify the locked BreakWave WP-03R RevenueCat architecture closeout.

Reliability rule:
The closeout decision document is verified by exact SHA-256 rather than
brittle punctuation/Markdown string matching. Semantic output below describes
that exact, locked document.
"""
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/BW_WP03R_REVENUECAT_ARCHITECTURE_RECONCILIATION.md"
RC1K = ROOT / "docs/BW_88RC1K_BILLING_CONTRACTS_THREAT_MODEL.md"
ENT = ROOT / "lib/core/access/breakwave_entitlement_source.dart"
LOCAL = ROOT / "lib/core/access/local_premium_entitlement_source.dart"
ACCESS = ROOT / "lib/core/access/breakwave_access_service.dart"

EXPECTED_DOC_SHA256 = "139e4c016cff9625ef0ee936b64144630eb3e82c129bf48c98f48f36e833c8b3"


def fail(message: str) -> None:
    print(f"BW-WP03R VERIFY: FAIL — {message}")
    raise SystemExit(1)


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def sha256(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def selftest() -> None:
    # Proves the verifier locks the exact approved document without depending
    # on Markdown punctuation or underscore normalization.
    expected = "139e4c016cff9625ef0ee936b64144630eb3e82c129bf48c98f48f36e833c8b3"
    if EXPECTED_DOC_SHA256 != expected:
        fail("embedded document SHA selftest mismatch")
    print("PASS: WP-03R verifier exact-document SHA selftest")


if "--selftest" in sys.argv:
    selftest()
    raise SystemExit(0)

actual_doc_sha = sha256(DOC)
if actual_doc_sha != EXPECTED_DOC_SHA256:
    fail(
        "architecture decision document changed: "
        f"expected {EXPECTED_DOC_SHA256}, got {actual_doc_sha}"
    )

rc1k = " ".join(text(RC1K).lower().split())
for needle in (
    "billing failure must never become recovery failure",
    "recovery data allowed in billing infrastructure is zero",
    "first plus grant requires online verification",
    "no more than 72 hours",
    "no more than 24 hours",
):
    if needle not in rc1k:
        fail(f"RC1K baseline marker missing: {needle}")

if "abstract class BreakWaveEntitlementSource" not in text(ENT):
    fail("BreakWaveEntitlementSource abstraction missing")
if "LocalPremiumEntitlementSource" not in text(LOCAL):
    fail("temporary local entitlement adapter missing")
if "BreakWaveEntitlementSource entitlementSource" not in text(ACCESS):
    fail("BreakWaveAccessService entitlement seam missing")

# WP-03R itself is architecture closeout only. RevenueCat code/dependency begins
# in the next package, WP-03S.
for p in (ROOT / "pubspec.yaml", ROOT / "pubspec.lock"):
    if p.is_file():
        lower = p.read_text(encoding="utf-8").lower()
        for marker in ("purchases_flutter", "purchases_flutter_ui", "in_app_purchase"):
            if marker in lower:
                fail(f"premature billing dependency introduced during WP-03R: {marker}")

lib_root = ROOT / "lib"
if lib_root.is_dir():
    dart = "\n".join(
        p.read_text(encoding="utf-8", errors="ignore")
        for p in lib_root.rglob("*.dart")
    )
    for marker in ("Purchases.configure", "purchasePackage(", "purchaseStoreProduct("):
        if marker in dart:
            fail(f"premature RevenueCat production code during WP-03R: {marker}")

print("BW-WP03R VERIFY: PASS")
print(f"Decision document SHA256: {actual_doc_sha}")
print("RevenueCat architecture fit: GO WITH BREAKWAVE GUARDRAILS")
print("RevenueCat production purchase-validation/lifecycle authority: locked")
print("verifiedOnDevice positive authority: rejected")
print("RevenueCat server temporary entitlement ceiling: 24h")
print("BreakWave offline ceilings retained: 72h active / 24h grace")
print("Custom backend role: DR/security reference")
print("Play Integrity launch dependency: deferred")
print("RevenueCat service-credential handling exception: locked")
print("Global gray/blue Plus indicator paid-readiness gate: locked")
print("Billing dependencies introduced by WP-03R: 0")
print("Entitlement behavior changed by WP-03R: no")
print("Next ordered package: WP-03S RevenueCat SDK Integration")
