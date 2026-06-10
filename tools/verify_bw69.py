from pathlib import Path
import sys

checks = [
    ("android/app/src/main/AndroidManifest.xml", [
        'android:label="BreakWave"',
        'android:icon="@mipmap/ic_launcher"',
        'android:name=".BreakWaveHomeWidgetProvider"',
    ]),
    ("android/app/build.gradle.kts", [
        'namespace = "com.cube23.breakwave"',
        'applicationId = "com.cube23.breakwave"',
        "BreakWave Play package ID.",
        "versionCode = flutter.versionCode",
        "versionName = flutter.versionName",
        'signingConfigs.getByName("release")',
        'signingConfigs.getByName("debug")',
    ]),
    (".github/workflows/ci.yml", [
        "Build release APK",
        "build/app/outputs/flutter-apk/app-release.apk",
        "Build release AAB",
        "build/app/outputs/bundle/release/app-release.aab",
        "Prepare Android release signing",
    ]),
    ("launch/release_candidate_verdict.md", [
        "ready for Play Store internal testing",
        "Android package ID: com.cube23.breakwave",
        "Android app label: BreakWave",
        "Not ready for public paid subscription launch",
        "Google Play Billing setup",
        "Proceed to internal testing",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

gradle_text = Path("android/app/build.gradle.kts").read_text(encoding="utf-8").lower()
if "todo" in gradle_text or "fixme" in gradle_text:
    print("FAIL android/app/build.gradle.kts still contains TODO/FIXME")
    failed = True

manifest_text = Path("android/app/src/main/AndroidManifest.xml").read_text(encoding="utf-8")
if 'android:label="breakwave"' in manifest_text:
    print("FAIL Android app label is still lowercase")
    failed = True

verdict_text = Path("launch/release_candidate_verdict.md").read_text(encoding="utf-8").lower()
unsafe_claims = [
    "hipaa compliant",
    "guaranteed anonymous",
    "cures addiction",
    "medical-grade security",
]
for claim in unsafe_claims:
    if claim in verdict_text:
        print(f"FAIL release verdict contains unsafe claim: {claim}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-69 release candidate blocker audit verified.")
