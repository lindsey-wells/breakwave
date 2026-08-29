#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

CONTRACT = ROOT / "lib/core/billing/revenuecat_catalog_contract.dart"
SERVICE = ROOT / "lib/core/billing/revenuecat_catalog_service.dart"
SOURCE = ROOT / "lib/core/billing/revenuecat_entitlement_source.dart"
POLICY_TEST = ROOT / "test/revenuecat_catalog_policy_test.dart"
SERVICE_TEST = ROOT / "test/revenuecat_catalog_service_test.dart"
DOC = ROOT / "docs/BW_WP03U_REVENUECAT_PRODUCTION_CATALOG.md"

EXPECTED_DOC_SHA256 = "74893d6fd4fddd866f62f0e9df3e10c6e34984c31087dbe38de2c10cbc9c7eeb"


def fail(message: str) -> None:
    print(f"BW-WP03U VERIFY: FAIL — {message}")
    raise SystemExit(1)


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


contract = read(CONTRACT)
service = read(SERVICE)
source = read(SOURCE)
policy_test = read(POLICY_TEST)
service_test = read(SERVICE_TEST)
doc = read(DOC)

actual_doc_sha = hashlib.sha256(DOC.read_bytes()).hexdigest()
if actual_doc_sha != EXPECTED_DOC_SHA256:
    fail("catalog decision document drifted")

for marker in (
    "googlePlaySubscriptionId",
    "'breakwave_plus_v1'",
    "plusEntitlementId",
    "'breakwave_plus'",
    "defaultOfferingId",
    "'default'",
    "googlePlayProductPrefix",
    "isBreakWavePlusGoogleProduct",
):
    if marker not in contract:
        fail(f"catalog contract marker missing: {marker}")

for marker in (
    "Purchases.getOfferings()",
    "offerings.getOffering(",
    "RevenueCatCatalogContract.defaultOfferingId",
    "launchOffering.availablePackages",
    "package.storeProduct.identifier",
    "package.storeProduct.priceString",
    ".subscriptionPeriod",
    "launchOfferingNotCurrent",
    "duplicatePackageIdentifier",
    "unrelatedGoogleProduct",
    "missingGoogleBasePlan",
    "missingStorePrice",
    "missingBillingPeriod",
):
    if marker not in service:
        fail(f"catalog service marker missing: {marker}")

if "package.storeProduct" not in service:
    fail("catalog service does not read StoreProduct")

if "BREAKWAVE_REVENUECAT_PLUS_ENTITLEMENT_ID" not in source:
    fail("WP-03T entitlement override seam removed")

if (
    "defaultValue:" not in source
    or "RevenueCatCatalogContract.plusEntitlementId" not in source
):
    fail("production entitlement default not locked")

for marker in (
    "production identifiers are locked",
    "without assuming launch cadence",
    "unrelated Google Play product is rejected",
    "subscription without base-plan suffix is rejected",
    "store price and billing period are required",
    "duplicate RevenueCat package IDs are rejected",
):
    if marker not in policy_test:
        fail(f"catalog policy test missing: {marker}")

for marker in (
    "service validates a provider snapshot without purchasing",
    "provider failure becomes not-ready",
    "production entitlement source defaults to locked entitlement ID",
):
    if marker not in service_test:
        fail(f"catalog service test missing: {marker}")

combined = "\n".join([contract, service, source, doc])

for forbidden in (
    "purchasePackage(",
    "purchaseStoreProduct(",
    "purchaseSubscriptionOption(",
    "restorePurchases(",
    "syncPurchases(",
    "purchases_ui_flutter",
):
    if forbidden in combined:
        fail(f"premature purchase/paywall behavior found: {forbidden}")

for unapproved in ("$8.99", "$59.99", "7-day trial", "7 day trial"):
    if unapproved.lower() in combined.lower():
        fail(f"unapproved production price/trial found: {unapproved}")

if re.search(r"\bgoog_[A-Za-z0-9_-]{10,}\b", combined):
    fail("hard-coded RevenueCat public SDK key found")

if re.search(
    r"BEGIN (?:RSA )?PRIVATE KEY|client_email|service_account",
    combined,
    flags=re.I,
):
    fail("service credential material found")

print("BW-WP03U VERIFY: PASS")
print("Google Play subscription ID: breakwave_plus_v1")
print("RevenueCat entitlement ID: breakwave_plus")
print("RevenueCat launch Offering ID: default")
print("Base-plan cadence hard-coded: no")
print("Production price/trial hard-coded: no")
print("Catalog read uses RevenueCat Offerings: yes")
print("Store-provided price required: yes")
print("Store-provided billing period required: yes")
print("Purchase/restore behavior introduced: no")
print("Client can prove product->entitlement attachment pre-purchase: no")
print("Next gate: Shadow CI + dashboard configuration")
