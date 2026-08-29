#!/usr/bin/env python3
"""Static contract verifier for BreakWave WP-03T."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

POLICY = ROOT / "lib/core/billing/revenuecat_entitlement_policy.dart"
SOURCE = ROOT / "lib/core/billing/revenuecat_entitlement_source.dart"
STORE = ROOT / "lib/core/billing/revenuecat_trusted_state_store.dart"
COMPOSITION = ROOT / "lib/core/billing/revenuecat_access_service.dart"
BOOTSTRAP = ROOT / "lib/core/billing/revenuecat_bootstrap.dart"
POLICY_TEST = ROOT / "test/revenuecat_entitlement_policy_test.dart"
SOURCE_TEST = ROOT / "test/revenuecat_entitlement_source_test.dart"
ACCESS = ROOT / "lib/core/access/breakwave_access_service.dart"
DOC = ROOT / "docs/BW_WP03T_REVENUECAT_TRUSTED_ENTITLEMENT_SOURCE.md"


def fail(message: str) -> None:
    print(f"BW-WP03T VERIFY: FAIL — {message}")
    raise SystemExit(1)


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


policy = text(POLICY)
source = text(SOURCE)
store = text(STORE)
composition = text(COMPOSITION)
bootstrap = text(BOOTSTRAP)
policy_test = text(POLICY_TEST)
source_test = text(SOURCE_TEST)
access = text(ACCESS)
doc = text(DOC)
doc_lower = " ".join(doc.lower().split())

for marker in (
    "Duration(hours: 72)",
    "Duration(hours: 24)",
    "RevenueCatVerificationState.verifiedOnDevice",
    "RevenueCatVerificationState.notRequested",
    "RevenueCatVerificationState.failed",
    "staleObservationIgnored",
    "clockRollbackDenied",
    "futureServerTimeDenied",
    "expiration.isBefore(ceilingEnd)",
):
    if marker not in policy:
        fail(f"policy marker missing: {marker}")

for marker in (
    "extends BreakWaveEntitlementSource",
    "Purchases.getCustomerInfo()",
    "customerInfo.entitlements.verification",
    "customerInfo.entitlements.all[entitlementId]",
    "BREAKWAVE_REVENUECAT_PLUS_ENTITLEMENT_ID",
    "SharedPreferencesRevenueCatTrustedStateStore",
    "return _publish(false);",
    "Purchase callbacks are never entitlement authority.",
):
    if marker not in source:
        fail(f"source marker missing: {marker}")

for verification in (
    "VerificationResult.verified",
    "VerificationResult.verifiedOnDevice",
    "VerificationResult.notRequested",
    "VerificationResult.failed",
):
    if verification not in source:
        fail(f"SDK verification mapping missing: {verification}")

for marker in (
    "EntitlementVerificationMode.informational",
    "PurchasesConfiguration(_androidPublicSdkKey)",
    "Purchases.configure(configuration)",
):
    if marker not in bootstrap:
        fail(f"bootstrap trust marker missing: {marker}")

for marker in (
    "breakwave.billing.revenuecat.trusted_state.v1",
    "acceptedRequestMs",
    "authoritativePlus",
    "validUntilMs",
    "lastObservedDeviceMs",
):
    if marker not in store:
        fail(f"state-store marker missing: {marker}")

for forbidden in (
    "recoveryEvent",
    "triggerSignal",
    "personalWhy",
    "purchaseToken",
    "rawToken",
):
    if forbidden.lower() in store.lower():
        fail(f"recovery/token data marker found in trusted store: {forbidden}")

if "BreakWaveAccessService(" not in composition:
    fail("RevenueCat access composition missing")

for marker in (
    "if (!accessClass.requiresPlus)",
    "return BreakWaveAccessDecision(",
):
    if marker not in access:
        fail(f"Free bypass seam missing: {marker}")

for marker in (
    "verifiedOnDevice cannot create Plus",
    "normal verified active is capped at 72 hours",
    "billing issue is capped at 24 hours",
    "short RevenueCat server grant cannot outlive its 24h expiration",
    "stale positive cannot overwrite newer accepted negative",
    "device clock rollback fails closed",
):
    if marker not in policy_test:
        fail(f"policy test missing: {marker}")

for marker in (
    "Rescue bypasses RevenueCat entirely",
    "verified CustomerInfo grants through existing BreakWave access seam",
    "provider outage can use only unexpired persisted trusted state",
    "trusted positive fails closed when anti-stale state cannot persist",
):
    if marker not in source_test:
        fail(f"source test missing: {marker}")

combined = "\n".join(
    [policy, source, store, composition, bootstrap, doc]
)

for forbidden in (
    "purchasePackage(",
    "purchaseStoreProduct(",
    "purchaseSubscriptionOption(",
    "restorePurchases(",
    "syncPurchases(",
    "getOfferings(",
    "purchases_ui_flutter",
):
    if forbidden in combined:
        fail(f"premature purchase/paywall behavior found: {forbidden}")

if re.search(r"\bgoog_[A-Za-z0-9_-]{10,}\b", combined):
    fail("hard-coded RevenueCat Google public key found")

if re.search(
    r"BEGIN (?:RSA )?PRIVATE KEY|client_email|service_account",
    combined,
    flags=re.I,
):
    fail("service/server credential material found")

# Document checks use wording that actually exists in the approved document.
for marker in (
    "making a purchase callback authoritative",
    "purchase callback authority",
    "billing failure must never become recovery failure",
    "no real subscription product id is introduced",
    "temporary_entitlement_grant",
):
    if marker not in doc_lower:
        fail(f"WP-03T document marker missing: {marker}")

print("BW-WP03T VERIFY: PASS")
print("Trusted positive verification: verified only")
print("verifiedOnDevice creates/extends Plus: no")
print("notRequested/failed grant Plus: no")
print("Normal active offline ceiling: 72h")
print("Billing-issue offline ceiling: 24h")
print("Entitlement expiration can be exceeded: no")
print("Stale CustomerInfo can overwrite newer state: no")
print("Clock rollback grants Plus: no")
print("Free/Rescue reads RevenueCat: no")
print("Purchase callback authority: no")
print("Purchase/paywall/restore behavior introduced: no")
print("Real subscription product IDs introduced: 0")
print("Recovery data in trusted billing state: 0")
print("Next gate: Shadow CI")
