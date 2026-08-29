#!/usr/bin/env python3
"""Verify WP-03V-T2 isolated RevenueCat Test Store QA build contract."""
from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

GRADLE = ROOT / "android/app/build.gradle.kts"
MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
MAIN = ROOT / "lib/main.dart"
QA_CONFIG = ROOT / "lib/core/billing/breakwave_billing_qa_config.dart"
QA_SCREEN = ROOT / "lib/features/billing_qa/presentation/billing_qa_screen.dart"
QA_WORKFLOW = ROOT / ".github/workflows/breakwave-test-store-qa.yml"
SHADOW_WORKFLOW = ROOT / ".github/workflows/breakwave-shadow-ci.yml"
DOC = ROOT / "docs/BW_WP03VT2_TEST_STORE_QA_APK.md"

PRODUCTION_ID = "com.cube23.breakwave"
QA_ID = "com.cube23.breakwave.teststoreqa"
QA_LABEL = "BreakWave Test Store"
SECRET_NAME = "BREAKWAVE_REVENUECAT_TEST_STORE_PUBLIC_SDK_KEY"


def fail(message: str) -> None:
    print(f"BW-WP03VT2 VERIFY: FAIL — {message}")
    raise SystemExit(1)


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


gradle = text(GRADLE)
manifest = text(MANIFEST)
main = text(MAIN)
qa_config = text(QA_CONFIG)
qa_screen = text(QA_SCREEN)
qa_workflow = text(QA_WORKFLOW)
shadow_workflow = text(SHADOW_WORKFLOW)
doc = text(DOC)

for marker in (
    'providers.gradleProperty("breakwaveTestStoreQa")',
    f'"{QA_ID}"',
    f'"{PRODUCTION_ID}"',
    '"BreakWave Test Store"',
    '"BreakWave"',
    'applicationId = breakWaveApplicationId',
    'manifestPlaceholders["breakWaveAppLabel"] = breakWaveAppLabel',
):
    if marker not in gradle:
        fail(f"Gradle isolation marker missing: {marker}")

if gradle.count(QA_ID) != 1:
    fail("QA application ID must be declared exactly once in Gradle")

if gradle.count(PRODUCTION_ID) < 2:
    fail("production namespace/application ID contract missing")

if "applicationIdSuffix" in gradle:
    fail("T2 uses explicit isolated application ID; suffix path is unexpected")

for marker in (
    'android:label="${breakWaveAppLabel}"',
    'android:name="com.cube23.breakwave.MainActivity"',
    'android:name="com.cube23.breakwave.BreakWaveHomeWidgetProvider"',
):
    if marker not in manifest:
        fail(f"manifest isolation marker missing: {marker}")

for forbidden in (
    'android:name=".MainActivity"',
    'android:name=".BreakWaveHomeWidgetProvider"',
    'android:label="BreakWave"',
):
    if forbidden in manifest:
        fail(f"manifest retains unsafe/non-isolated marker: {forbidden}")

for marker in (
    "import 'core/billing/breakwave_billing_qa_config.dart';",
    "if (BreakWaveBillingQaConfig.enabled) {",
    "await RevenueCatBootstrap.initialize();",
    "if (!BreakWaveBillingQaConfig.enabled) {",
    "unawaited(RevenueCatBootstrap.initialize());",
):
    if marker not in main:
        fail(f"QA startup marker missing: {marker}")

if "defaultValue: false" not in qa_config:
    fail("normal builds must keep Billing QA disabled by default")

for marker in (
    "TEST STORE QA — NO REAL MONEY",
    "Buy Monthly",
    "Buy Annual",
    "Restore Purchases",
    "Refresh Trusted Entitlement",
):
    if marker not in qa_screen:
        fail(f"T1 Billing QA surface missing: {marker}")

for marker in (
    "name: BreakWave Test Store QA",
    "workflow_dispatch:",
    SECRET_NAME,
    "ORG_GRADLE_PROJECT_breakwaveTestStoreQa: 'true'",
    '"BREAKWAVE_REVENUECAT_TEST_STORE_QA": "true"',
    '"BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY": key',
    '--dart-define-from-file="$DEFINE_FILE"',
    "flutter build apk",
    f"package: name='{QA_ID}'",
    f"application-label:'{QA_LABEL}'",
    "breakwave-test-store-qa-evidence",
    "breakwave-test-store-qa-apk",
    "test_store_key_value_recorded",
):
    if marker not in qa_workflow:
        fail(f"QA workflow marker missing: {marker}")

if "flutter build appbundle" in qa_workflow:
    fail("Test Store QA workflow must not build an AAB")

for forbidden in (
    "ANDROID_KEYSTORE_BASE64",
    "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS",
    "ANDROID_KEY_PASSWORD",
):
    if forbidden in qa_workflow:
        fail(f"QA workflow must not consume production signing secret: {forbidden}")

if "echo \"$TEST_STORE_PUBLIC_SDK_KEY\"" in qa_workflow:
    fail("QA workflow must never echo the Test Store key")

if "set -x" in qa_workflow:
    fail("QA workflow must not enable shell xtrace around secret handling")

if SECRET_NAME in shadow_workflow:
    fail("normal Shadow workflow must not reference the Test Store secret")

if "breakwaveTestStoreQa" in shadow_workflow:
    fail("normal Shadow workflow must not opt into the QA Android identity")

if "BREAKWAVE_REVENUECAT_TEST_STORE_QA=true" in shadow_workflow:
    fail("normal Shadow workflow must not enable Billing QA")

# Prevent an actual Test Store SDK key literal from being committed without
# mistaking ordinary QA identifiers such as test_store_qa_evidence for keys.
changed_text = "\n".join(
    (gradle, manifest, main, qa_workflow, doc)
)
hard_coded_test_store_key_patterns = (
    r"""BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY\s*[:=]\s*['\"]test_[A-Za-z0-9_-]{16,}['\"]""",
    r"""PurchasesConfiguration\(\s*['\"]test_[A-Za-z0-9_-]{16,}['\"]\s*\)""",
    r"""--dart-define(?:=|\s+)BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY=test_[A-Za-z0-9_-]{16,}""",
)

for pattern in hard_coded_test_store_key_patterns:
    if re.search(pattern, changed_text):
        fail("hard-coded Test Store public SDK key literal found")

doc_compact = " ".join(doc.split())

for marker in (
    "application ID: `com.cube23.breakwave.teststoreqa`",
    "application ID: `com.cube23.breakwave`",
    "must never be distributed as the production Play build",
    "standard `breakwave-shadow-ci.yml`",
    "`breakwave-test-store-qa.yml`",
):
    if marker not in doc_compact:
        fail(f"T2 decision document marker missing: {marker}")

print("BW-WP03VT2 VERIFY: PASS")
print(f"Production application ID: {PRODUCTION_ID}")
print(f"Test Store QA application ID: {QA_ID}")
print(f"Test Store QA application label: {QA_LABEL}")
print("Billing QA default in normal builds: OFF")
print("QA workflow: manual-only")
print("Test Store key in tracked source: no")
print("Test Store key in evidence by design: no")
print("Production signing secrets in QA workflow: no")
print("QA AAB build: no")
print("Customer paywall introduced: no")
print("Plus shell icon introduced: no")
print("Next gates: standard Shadow CI + dedicated Test Store QA CI")
