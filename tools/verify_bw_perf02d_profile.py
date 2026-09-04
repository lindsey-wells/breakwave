from pathlib import Path
import sys

workflow = Path(".github/workflows/breakwave-performance-profile-qa.yml")
failed = False

if not workflow.is_file():
    print("FAIL missing PERF-02D profile workflow")
    sys.exit(1)

text = workflow.read_text(encoding="utf-8")

required = [
    "name: BreakWave Performance Profile QA",
    "- perf/perf02d-first-frame-investigation",
    "BREAKWAVE_REVENUECAT_TEST_STORE_PUBLIC_SDK_KEY",
    "ORG_GRADLE_PROJECT_breakwaveTestStoreQa: 'true'",
    '"BREAKWAVE_REVENUECAT_TEST_STORE_QA": "true"',
    "flutter build apk",
    "--profile",
    "build/app/outputs/flutter-apk/app-profile.apk",
    "com.cube23.breakwave.teststoreqa",
    "BreakWave Test Store",
    '"build_mode": "profile"',
    '"release_build": False',
    '"production_signing_secrets_used": False',
    "breakwave-performance-profile-qa-evidence",
    "breakwave-performance-profile-qa-apk",
]

for needle in required:
    if needle not in text:
        print(f"FAIL PERF-02D profile contract missing: {needle}")
        failed = True

for forbidden in [
    "flutter build apk --release",
    "flutter build appbundle",
    "BREAKWAVE_ANDROID_KEYSTORE",
    "BREAKWAVE_KEY_ALIAS",
    "BREAKWAVE_STORE_PASSWORD",
    "BREAKWAVE_KEY_PASSWORD",
]:
    if forbidden in text:
        print(f"FAIL PERF-02D profile lane contains forbidden production token: {forbidden}")
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: PERF-02D profile lane is isolated, profile-mode, "
    "Test Store QA only, and does not use production signing."
)
