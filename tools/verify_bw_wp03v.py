#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
LOCK = ROOT / "pubspec.lock"
MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
CONTRACT = ROOT / "lib/core/billing/revenuecat_catalog_contract.dart"
EXECUTOR = ROOT / "lib/core/billing/revenuecat_purchase_executor.dart"
LIFECYCLE = ROOT / "lib/core/billing/revenuecat_purchase_lifecycle.dart"
TEST = ROOT / "test/revenuecat_purchase_lifecycle_test.dart"
WORKFLOW = ROOT / ".github/workflows/breakwave-shadow-ci.yml"
DOC = ROOT / "docs/BW_WP03V_REVENUECAT_PURCHASE_RESTORE.md"

EXPECTED_DOC_SHA256 = "d8e312be05648a607bd47a00a2cb8ec47e48788208646010124f9a7a9e5bd15d"

def fail(msg):
    print(f"BW-WP03V VERIFY: FAIL — {msg}")
    raise SystemExit(1)

def text(path):
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")

pubspec = text(PUBSPEC)
lock = text(LOCK)
manifest = text(MANIFEST)
contract = text(CONTRACT)
executor = text(EXECUTOR)
lifecycle = text(LIFECYCLE)
tests = text(TEST)
workflow = text(WORKFLOW)
doc = text(DOC)

if hashlib.sha256(DOC.read_bytes()).hexdigest() != EXPECTED_DOC_SHA256:
    fail("WP-03V document drifted")

if not re.search(r"(?m)^\s*purchases_flutter:\s*10\.10\.1\s*$", pubspec):
    fail("purchases_flutter is not exactly pinned to 10.10.1")

for marker in (
    "monthlyPackageIdentifier", r"r'$rc_monthly'",
    "annualPackageIdentifier", r"r'$rc_annual'",
    "testStoreMonthlyProductIdentifier", "'monthly'",
    "testStoreAnnualProductIdentifier", "'yearly'",
    "isSupportedPurchasePackage",
):
    if marker not in contract:
        fail(f"package contract marker missing: {marker}")

for marker in (
    "Purchases.getOfferings()",
    "RevenueCatCatalogContract.defaultOfferingId",
    "offering.availablePackages",
    "Purchases.purchase(",
    "PurchaseParams.package(package)",
    "Purchases.restorePurchases()",
    "PurchasesErrorHelper.getErrorCode(error)",
    "PurchasesErrorCode.purchaseCancelledError",
    "Intentionally ignore PurchaseResult.customerInfo",
    "Restore completion is not BreakWave Plus authority",
):
    if marker not in executor:
        fail(f"executor marker missing: {marker}")

for marker in (
    "BreakWaveEntitlementSource entitlementSource",
    "await _executor.purchasePackage(packageIdentifier)",
    "await _executor.restorePurchases()",
    "await _entitlementSource.isPlusUnlocked()",
    "completedButNotVerified",
    "purchaseActivated",
    "restoreActivated",
):
    if marker not in lifecycle:
        fail(f"lifecycle marker missing: {marker}")

# Security invariant: lifecycle orchestration must remain SDK-object agnostic.
# Strip comments first so explanatory text such as "trusted CustomerInfo path"
# cannot trigger a false positive.
def strip_dart_comments(source: str) -> str:
    no_blocks = re.sub(r"/\*.*?\*/", "", source, flags=re.S)
    return re.sub(r"//[^\n]*", "", no_blocks)


lifecycle_code = strip_dart_comments(lifecycle)

if "package:purchases_flutter/" in lifecycle_code:
    fail("lifecycle layer must not import RevenueCat SDK types")

for forbidden_type in ("CustomerInfo", "PurchaseResult"):
    if re.search(rf"\b{forbidden_type}\b", lifecycle_code):
        fail(
            "lifecycle layer must not authorize from "
            f"SDK callback type: {forbidden_type}"
        )

for marker in (
    "successful purchase requires separate trusted entitlement read",
    "completed purchase stays locked when trusted source denies Plus",
    "purchase cancellation does not fabricate or read Plus",
    "missing package fails without trusted entitlement read",
    "transport failure fails closed without entitlement read",
    "trusted entitlement exception after purchase fails closed",
    "successful restore still requires trusted entitlement verification",
    "restore completion cannot unlock without trusted state",
    "restore transport failure fails closed",
):
    if marker not in tests:
        fail(f"required test missing: {marker}")

if 'android:launchMode="singleTop"' not in manifest:
    fail("MainActivity must remain singleTop")

for marker in (
    "- name: Capture resolved dependency lock",
    "cp pubspec.lock shadow_evidence/pubspec.lock.resolved",
    "sha256sum pubspec.lock > shadow_evidence/pubspec.lock.resolved.sha256",
    "- name: Upload Shadow evidence",
):
    if marker not in workflow:
        fail(f"lock capture marker missing: {marker}")

if workflow.index("- name: Capture resolved dependency lock") > workflow.index(
    "- name: Upload Shadow evidence"
):
    fail("lock must be captured before evidence upload")

combined = "\n".join((contract, executor, lifecycle, doc))
for forbidden in ("purchases_ui_flutter", "presentPaywall", "PaywallView"):
    if forbidden in combined:
        fail(f"premature paywall behavior: {forbidden}")

if re.search(r"\btest_[A-Za-z0-9_-]{20,}\b", combined):
    fail("hard-coded Test Store SDK key found")
if re.search(r"\bgoog_[A-Za-z0-9_-]{10,}\b", combined):
    fail("hard-coded production SDK key found")

lock_has_rc = bool(re.search(
    r'(?ms)^  purchases_flutter:\n.*?version: "10\.10\.1"',
    lock,
))
if "purchases_flutter:" in lock and not lock_has_rc:
    fail("unexpected purchases_flutter version in lockfile")

print("BW-WP03V VERIFY: PASS")
print("RevenueCat purchase API: PurchaseParams.package")
print("Restore API: restorePurchases")
print("Purchase callback grants Plus directly: no")
print("Restore callback grants Plus directly: no")
print("Trusted entitlement reread required after completion: yes")
print("Monthly package: $rc_monthly")
print("Annual package: $rc_annual")
print("Test Store key hard-coded: no")
print("Paywall/Plus icon introduced: no")
print("Android launchMode: singleTop")
print("Resolved lockfile committed: " + ("yes" if lock_has_rc else "no — CI artifact required"))
print("Next gate: Shadow CI")
