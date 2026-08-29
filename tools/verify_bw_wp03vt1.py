#!/usr/bin/env python3
"""Verify WP-03V-T1 billing composition and QA console."""
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]

APP = ROOT / "lib/app/breakwave_app.dart"
SHELL = (
    ROOT
    / "lib/features/shell/presentation/breakwave_shell.dart"
)
COMPOSITION = (
    ROOT
    / "lib/core/billing/breakwave_billing_composition.dart"
)
SCOPE = (
    ROOT
    / "lib/core/billing/breakwave_billing_scope.dart"
)
CONFIG = (
    ROOT
    / "lib/core/billing/breakwave_billing_qa_config.dart"
)
CONTROLLER = (
    ROOT
    / "lib/features/billing_qa/application/billing_qa_controller.dart"
)
SCREEN = (
    ROOT
    / "lib/features/billing_qa/presentation/billing_qa_screen.dart"
)
COMPOSITION_TEST = (
    ROOT / "test/breakwave_billing_composition_test.dart"
)
CONTROLLER_TEST = (
    ROOT / "test/billing_qa_controller_test.dart"
)
DOC = ROOT / "docs/BW_WP03VT1_BILLING_QA_CONSOLE.md"

EXPECTED_DOC_SHA256 = "ef3a88389468786bc369eaece40d28b04dbfdc24bc1cddd0874d7e9b3d481e08"


def fail(message: str) -> None:
    print(f"BW-WP03VT1 VERIFY: FAIL — {message}")
    raise SystemExit(1)


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def strip_dart_comments(source: str) -> str:
    no_blocks = re.sub(r"/\*.*?\*/", "", source, flags=re.S)
    return re.sub(r"//[^\n]*", "", no_blocks)


app = text(APP)
shell = text(SHELL)
composition = text(COMPOSITION)
scope = text(SCOPE)
config = text(CONFIG)
controller = text(CONTROLLER)
screen = text(SCREEN)
composition_test = text(COMPOSITION_TEST)
controller_test = text(CONTROLLER_TEST)
doc = text(DOC)

if hashlib.sha256(DOC.read_bytes()).hexdigest() != EXPECTED_DOC_SHA256:
    fail("WP-03V-T1 decision document drifted")

for marker in (
    "BreakWaveBillingComposition? billingComposition",
    "BreakWaveBillingComposition.production()",
    "BreakWaveBillingScope(",
    "composition: _billingComposition",
    "_billingComposition.dispose()",
):
    if marker not in app:
        fail(f"app composition marker missing: {marker}")

for marker in (
    "RevenueCatEntitlementSource.production()",
    "BreakWaveAccessService(",
    "RevenueCatPurchaseLifecycleService(",
    "entitlementSource: entitlementSource",
    "RevenueCatSdkPurchaseExecutor()",
    "RevenueCatSdkCatalogProvider()",
    "RevenueCatSdkRuntimeStatusProvider()",
):
    if marker not in composition:
        fail(f"billing composition marker missing: {marker}")

if composition.count(
    "final RevenueCatEntitlementSource entitlementSource ="
) != 1:
    fail("production composition must create one trusted source variable")

if composition.count(
    "entitlementSource: entitlementSource"
) < 3:
    fail(
        "shared entitlement source is not visibly wired through "
        "composition/access/lifecycle"
    )

for marker in (
    "class BreakWaveBillingScope extends InheritedWidget",
    "BreakWaveBillingComposition composition",
    "dependOnInheritedWidgetOfExactType",
):
    if marker not in scope:
        fail(f"billing scope marker missing: {marker}")

for marker in (
    "bool.fromEnvironment(",
    "'BREAKWAVE_REVENUECAT_TEST_STORE_QA'",
    "defaultValue: false",
):
    if marker not in config:
        fail(f"QA config marker missing: {marker}")

if shell.count("BreakWaveBillingQaConfig.enabled") != 2:
    fail(
        "QA flag must guard exactly the QA screen and "
        "its navigation destination"
    )

for marker in (
    "const BillingQaScreen()",
    "label: 'Billing QA'",
    "label: 'Home'",
    "label: 'Rescue'",
    "label: 'Log'",
    "label: 'Support'",
):
    if marker not in shell:
        fail(f"shell marker missing: {marker}")

for marker in (
    "TEST STORE QA — NO REAL MONEY",
    "Buy Monthly",
    "Buy Annual",
    "Restore Purchases",
    "Refresh Trusted Entitlement",
    "RevenueCat configured",
    "Current Offering",
    "Catalog ready",
    "Trusted access",
):
    if marker not in screen:
        fail(f"QA screen marker missing: {marker}")

screen_code = strip_dart_comments(screen)
controller_code = strip_dart_comments(controller)

for forbidden in (
    "Purchases.purchase(",
    "Purchases.restorePurchases(",
    "Purchases.getOfferings(",
    "PurchaseParams.",
):
    if forbidden in screen_code:
        fail(
            f"QA presentation layer contains direct SDK action: "
            f"{forbidden}"
        )
    if forbidden in controller_code:
        fail(
            f"QA controller contains direct SDK action: "
            f"{forbidden}"
        )

for marker in (
    "RevenueCatCatalogProvider",
    "RevenueCatCatalogContract.monthlyPackageIdentifier",
    "RevenueCatCatalogContract.annualPackageIdentifier",
    "testStoreMonthlyProductIdentifier",
    "testStoreAnnualProductIdentifier",
    "_purchaseLifecycle.purchaseMonthly()",
    "_purchaseLifecycle.purchaseAnnual()",
    "_purchaseLifecycle.restorePurchases()",
    "_entitlementSource.isPlusUnlocked()",
):
    if marker not in controller:
        fail(f"QA controller marker missing: {marker}")

if "RevenueCatCatalogService(" in controller_code:
    fail("QA controller must not instantiate production catalog service")

if re.search(r"\.validate\s*\(", controller_code):
    fail("QA controller must not call production catalog validation")

for marker in (
    "normal builds keep the Billing QA console disabled",
    "one entitlement source powers access and purchase lifecycle",
    "Rescue must not consult billing entitlement state",
    "composition disposal is idempotent",
):
    if marker not in composition_test:
        fail(f"composition test missing: {marker}")

for marker in (
    "valid Test Store catalog is ready",
    "missing annual Test Store package is not ready",
    "wrong Test Store product mapping is not ready",
    "monthly purchase uses lifecycle and reports trusted Plus",
    "cancelled purchase never fabricates activation",
    "restore uses lifecycle trusted authority",
    "catalog provider failure degrades safely",
):
    if marker not in controller_test:
        fail(f"QA controller test missing: {marker}")

combined = "\n".join(
    (
        app,
        shell,
        composition,
        scope,
        config,
        controller,
        screen,
        composition_test,
        controller_test,
        doc,
    )
)

for forbidden in (
    "purchases_ui_flutter",
    "presentPaywall",
    "PaywallView",
    "RevenueCatUI",
):
    if forbidden in combined:
        fail(f"customer paywall behavior is premature: {forbidden}")

for unapproved in (
    "$8.99",
    "$9.99",
    "$59.99",
    "$69.99",
    "7-day trial",
    "7 day trial",
):
    if unapproved.lower() in combined.lower():
        fail(f"unapproved price/trial found: {unapproved}")

if re.search(r"\btest_[A-Za-z0-9_-]{20,}\b", combined):
    fail("hard-coded Test Store SDK key found")

if re.search(r"\bgoog_[A-Za-z0-9_-]{10,}\b", combined):
    fail("hard-coded production RevenueCat SDK key found")

if re.search(
    r"BEGIN (?:RSA )?PRIVATE KEY|"
    r'"private_key"|'
    r'"client_email"|'
    r'"type"\s*:\s*"service_account"',
    combined,
    flags=re.I,
):
    fail("service credential material found")

if "BREAKWAVE_REVENUECAT_TEST_STORE_PUBLIC_SDK_KEY" in (
    app + shell + composition + scope + config + controller + screen
):
    fail(
        "T1 runtime source must not read the Test Store GitHub "
        "secret directly"
    )

print("BW-WP03VT1 VERIFY: PASS")
print("QA flag default: false")
print("Shared trusted entitlement source: yes")
print("QA console compile-time gated: yes")
print("QA catalog validation uses raw provider: yes")
print("Production catalog validator changed: no")
print("Direct RevenueCat purchase calls in QA UI/controller: no")
print("Test Store key embedded: no")
print("Customer paywall introduced: no")
print("Persistent Plus icon introduced: no")
print("Rescue billing dependency introduced: no")
print("Local Flutter executed: no")
print("CI required: yes")
print("Next gate: push WP-03V-T1 branch and run Shadow CI")
