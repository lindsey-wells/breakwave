#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(rel: str) -> str:
    path = ROOT / rel
    if not path.is_file():
        raise SystemExit(f"FAIL WP-03W missing: {rel}")
    return path.read_text(encoding="utf-8")


def require(haystack: str, marker: str, label: str) -> None:
    if marker not in haystack:
        raise SystemExit(f"FAIL WP-03W {label}: {marker}")


def forbid(haystack: str, marker: str, label: str) -> None:
    if marker in haystack:
        raise SystemExit(f"FAIL WP-03W {label}: {marker}")


app = text("lib/app/breakwave_app.dart")
app_scope_test = text("test/breakwave_app_billing_scope_test.dart")
controller = text("lib/features/premium/application/breakwave_plus_controller.dart")
screen = text("lib/features/premium/presentation/breakwave_plus_screen.dart")
button = text("lib/features/premium/presentation/breakwave_plus_access_button.dart")
shell = text("lib/features/shell/presentation/breakwave_shell.dart")
rescue = text("lib/features/rescue/presentation/rescue_screen.dart")
access_policy = text("lib/core/access/breakwave_access_policy.dart")
catalog_service = text("lib/core/billing/revenuecat_catalog_service.dart")
workflow = text(".github/workflows/breakwave-test-store-qa.yml")
onboarding = text("lib/features/onboarding/presentation/onboarding_access_step_details.dart")

# BreakWaveBillingScope must wrap MaterialApp itself. MaterialApp owns the
# Navigator, so a scope limited to home does not cover pushed routes.
scope_index = app.find("return BreakWaveBillingScope(")
material_index = app.find("child: MaterialApp(")
if scope_index < 0 or material_index < 0 or scope_index > material_index:
    raise SystemExit(
        "FAIL WP-03W billing scope must wrap MaterialApp/Navigator"
    )

require(
    app,
    "composition: _billingComposition",
    "shared app-root billing composition missing",
)
forbid(
    app,
    "home: BreakWaveBillingScope(",
    "billing scope is incorrectly limited to MaterialApp.home",
)

for marker in (
    "pushed Navigator route inherits the one shared billing composition",
    "tester.state<NavigatorState>",
    "BreakWaveBillingScope.of(routeContext)",
    "same(composition)",
):
    require(
        app_scope_test,
        marker,
        "app-root Navigator billing-scope regression test missing",
    )

for marker in (
    "BreakWavePlusController.fromComposition",
    "RevenueCatCatalogPolicy().validate(snapshot)",
    "BreakWaveBillingQaConfig.enabled",
    "RevenueCatCatalogContract.monthlyPackageIdentifier",
    "RevenueCatCatalogContract.annualPackageIdentifier",
    "_purchaseLifecycle.purchaseMonthly()",
    "_purchaseLifecycle.purchaseAnnual()",
    "_purchaseLifecycle.restorePurchases",
    "_entitlementSource.isPlusUnlocked()",
):
    require(controller, marker, "controller invariant missing")

for marker in (
    "Prices below come directly from the connected store.",
    "snapshot.monthly!",
    "snapshot.annual!",
    "Restore purchases",
    "Refresh access",
    "BreakWaveFeature.advancedRecoveryInsights",
    "BreakWaveFeature.savedPersonalRecoveryPlan",
    "BreakWaveFeature.guidedRoutines",
    "BreakWaveFeature.enhancedRecoveryReports",
    "BreakWaveFeature.christianJourneys",
):
    require(screen, marker, "customer Plus surface missing")

for forbidden_price in (
    "$9.99",
    "$79.98",
    "free trial",
    "7-day trial",
    "14-day trial",
):
    forbid(screen, forbidden_price, "hard-coded customer price/trial claim")
    forbid(controller, forbidden_price, "hard-coded customer price/trial claim")

for marker in (
    "Colors.blue",
    "Colors.grey",
    "BreakWave Plus active",
    "Review BreakWave Plus",
):
    require(button, marker, "persistent Plus state missing")

for marker in (
    "BreakWavePlusAccessButton",
    "_selectedIndex != 1",
    "BreakWavePlusScreen(",
):
    require(shell, marker, "shell Plus access invariant missing")

for marker in (
    "if (BreakWaveBillingQaConfig.enabled)",
    "BillingQaScreen",
):
    require(shell, marker, "Billing QA compile-time gate missing")

rescue_lower = rescue.lower()
for forbidden_rescue in (
    "breakwave_billing",
    "revenuecat",
    "breakwaveplus",
    "premium/",
):
    forbid(rescue_lower, forbidden_rescue, "Rescue billing dependency introduced")

for marker in (
    "BreakWaveFeature.rescueNow:",
    "BreakWaveAccessClass.neverPaywalled",
    "BreakWaveFeature.rescueActions:",
):
    require(access_policy, marker, "Rescue access policy changed")

for marker in (
    "googlePlayProductPrefix",
    "RevenueCatCatalogIssue.missingGoogleBasePlan",
    "RevenueCatCatalogIssue.missingStorePrice",
    "RevenueCatCatalogIssue.missingBillingPeriod",
):
    require(catalog_service, marker, "production catalog guard missing")

for marker in (
    "- billing/wp-03vt2-test-store-qa-apk",
    "- billing/wp-03w-customer-plus",
    "python3 tools/verify_bw_wp03w.py",
    "flutter build apk",
    "--debug",
):
    require(workflow, marker, "Test Store QA branch/verification lane missing")

require(
    onboarding,
    "still does not unlock Plus.",
    "onboarding entitlement wording missing",
)
forbid(
    onboarding,
    "Plus purchasing is not available yet.",
    "stale onboarding purchasing claim remains",
)

for marker in (
    "Purchases.purchase",
    "Purchases.restorePurchases",
    "Purchases.getOfferings",
    "Purchases.getCustomerInfo",
    "purchases_flutter",
):
    forbid(screen, marker, "direct RevenueCat call/import in Plus screen")
    forbid(controller, marker, "direct RevenueCat call/import in Plus controller")

for marker in ("purchaseMonthly", "purchaseAnnual", "restorePurchases"):
    forbid(button, marker, "persistent Plus icon became billing transport")

forbid(button, "Colors.red", "red Plus state introduced")
forbid(button, "Icons.block", "red-slash style state introduced")

print("BW-WP03W VERIFY: PASS")
print("Customer Plus pricing: store-owned")
print("Purchase/restore transport: existing lifecycle only")
print("Trusted access authority: shared entitlement source")
print("Production catalog policy weakened: no")
print("Test Store customer UX available on QA branch: yes")
print("Plus active indicator: blue")
print("Plus inactive indicator: gray")
print("Red/slash state: no")
print("Plus feature entry points: yes")
print("Rescue billing dependency: no")
print("Billing QA remains compile-time gated: yes")
print("Billing scope wraps MaterialApp/Navigator: yes")
print("Pushed-route billing-scope regression test: yes")
print("Local Flutter executed: no")
print("CI required: yes")
