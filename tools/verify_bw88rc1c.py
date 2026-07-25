#!/usr/bin/env python3
"""Verify BW-88RC1C access taxonomy coverage and guardrails."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

FEATURE_FILE = ROOT / "lib/core/access/breakwave_feature.dart"
CLASS_FILE = ROOT / "lib/core/access/breakwave_access_class.dart"
POLICY_FILE = ROOT / "lib/core/access/breakwave_access_policy.dart"
TEST_FILE = ROOT / "test/breakwave_access_policy_test.dart"

EXPECTED = {
    "rescueNow": "neverPaywalled",
    "rescueActions": "neverPaywalled",
    "onboarding": "neverPaywalled",
    "basicLogging": "neverPaywalled",
    "logHistory": "neverPaywalled",
    "editAndDeleteLogs": "neverPaywalled",
    "privacySettings": "neverPaywalled",
    "privacyLock": "neverPaywalled",
    "privacyPolicy": "neverPaywalled",
    "emergencyHelp": "neverPaywalled",
    "humanSupportActions": "neverPaywalled",
    "trustedContactTools": "neverPaywalled",
    "recoveryMode": "neverPaywalled",
    "basicSecularSupport": "neverPaywalled",
    "basicChristianSupport": "neverPaywalled",
    "personalWhy": "neverPaywalled",
    "personalDataControl": "neverPaywalled",
    "reasonsAndTriggers": "protectedFreeCore",
    "dailyCheckIn": "protectedFreeCore",
    "bedtimeRiskSupport": "protectedFreeCore",
    "starterRecoveryPlan": "protectedFreeCore",
    "reminders": "freeSupport",
    "recoveryCycleEducation": "freeSupport",
    "recoveryEducationResources": "freeSupport",
    "basicRecoverySnapshot": "freeSupport",
    "advancedRecoveryInsights": "plusCandidate",
    "savedPersonalRecoveryPlan": "plusCandidate",
    "guidedRoutines": "plusCandidate",
    "christianJourneys": "plusCandidate",
    "enhancedRecoveryReports": "plusCandidate",
    "extendedChristianDepth": "plusCandidate",
}

OLD_AMBIGUOUS_IDENTIFIERS = {
    "recoveryInsights",
    "personalRecoveryPlan",
    "recoveryReports",
    "faithDepthPack",
}


def fail(message: str) -> None:
    print(f"BW-88RC1C VERIFY: FAIL — {message}")
    raise SystemExit(1)


for path in (FEATURE_FILE, CLASS_FILE, POLICY_FILE, TEST_FILE):
    if not path.is_file():
        fail(f"missing required file: {path.relative_to(ROOT)}")

feature_text = FEATURE_FILE.read_text(encoding="utf-8")
class_text = CLASS_FILE.read_text(encoding="utf-8")
policy_text = POLICY_FILE.read_text(encoding="utf-8")
test_text = TEST_FILE.read_text(encoding="utf-8")

feature_match = re.search(
    r"enum\s+BreakWaveFeature\s*\{(.*?);",
    feature_text,
    flags=re.DOTALL,
)
if feature_match is None:
    fail("could not parse BreakWaveFeature enum")

feature_names = re.findall(
    r"^\s{2}([A-Za-z][A-Za-z0-9_]*)[,]?\s*$",
    feature_match.group(1),
    flags=re.MULTILINE,
)

if len(feature_names) != len(set(feature_names)):
    fail("duplicate BreakWaveFeature identifier found")

if set(feature_names) != set(EXPECTED):
    missing = sorted(set(EXPECTED) - set(feature_names))
    extra = sorted(set(feature_names) - set(EXPECTED))
    fail(f"feature inventory mismatch; missing={missing}, extra={extra}")

mapping_pairs = re.findall(
    r"BreakWaveFeature\.([A-Za-z][A-Za-z0-9_]*)"
    r":\s*BreakWaveAccessClass\.([A-Za-z][A-Za-z0-9_]*),",
    policy_text,
)

mapping_names = [name for name, _ in mapping_pairs]
if len(mapping_names) != len(set(mapping_names)):
    fail("duplicate feature classification found")

actual = dict(mapping_pairs)
if actual != EXPECTED:
    mismatches = {
        name: (EXPECTED.get(name), actual.get(name))
        for name in sorted(set(EXPECTED) | set(actual))
        if EXPECTED.get(name) != actual.get(name)
    }
    fail(f"classification mismatch: {mismatches}")

required_classes = (
    "neverPaywalled",
    "protectedFreeCore",
    "freeSupport",
    "plusCandidate",
)
for access_class in required_classes:
    if access_class not in class_text:
        fail(f"missing access class: {access_class}")

for feature_name in EXPECTED:
    label_case = f"case BreakWaveFeature.{feature_name}:"
    if label_case not in feature_text:
        fail(f"missing label case for {feature_name}")

combined_current_files = "\n".join(
    (feature_text, policy_text, test_text)
)
for old_identifier in OLD_AMBIGUOUS_IDENTIFIERS:
    old_reference = f"BreakWaveFeature.{old_identifier}"
    if old_reference in combined_current_files:
        fail(f"ambiguous legacy identifier remains: {old_reference}")

required_test_evidence = (
    "every feature has exactly one classification",
    "required protections are explicitly never paywalled",
    "Rescue screen and Rescue actions are separately protected",
    "starter plan is Free and saved deeper plan is Plus",
    "personal-data control is Free and reports are Plus",
    "basic Christian support is Free and depth is Plus",
    "approved Plus candidates require entitlement",
)
for evidence in required_test_evidence:
    if evidence not in test_text:
        fail(f"missing test evidence: {evidence}")

for forbidden_dependency in (
    "PremiumStateStore",
    "SharedPreferences",
    "in_app_purchase",
    "purchases_flutter",
):
    if forbidden_dependency in policy_text:
        fail(
            "access policy must not depend on "
            f"{forbidden_dependency}"
        )

print("BW-88RC1C VERIFY: PASS")
print(f"Classified features: {len(EXPECTED)}")
print(
    "Never paywalled: "
    f"{sum(value == 'neverPaywalled' for value in EXPECTED.values())}"
)
print(
    "Protected Free core: "
    f"{sum(value == 'protectedFreeCore' for value in EXPECTED.values())}"
)
print(
    "Free support: "
    f"{sum(value == 'freeSupport' for value in EXPECTED.values())}"
)
print(
    "Plus candidates: "
    f"{sum(value == 'plusCandidate' for value in EXPECTED.values())}"
)
