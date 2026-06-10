from pathlib import Path
import sys

checks = [
    (".github/workflows/ci.yml", [
        "FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true",
        "uses: actions/checkout@v4",
        "uses: actions/setup-java@v5",
        "uses: subosito/flutter-action@v2",
        "Run BreakWave verification scripts",
        "run: flutter test",
        "Prepare Android release signing",
        "flutter build apk --release",
        "name: breakwave-release-apk",
        "flutter build appbundle --release",
        "name: breakwave-release-aab",
    ]),
    (".github/workflows/bootstrap.yml", [
        "FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true",
        "uses: actions/checkout@v4",
        "uses: actions/setup-java@v5",
        "uses: subosito/flutter-action@v2",
    ]),
    ("launch/github_actions_node24_readiness.md", [
        "BW-68 GitHub Actions Node 24 Readiness",
        "FORCE_JAVASCRIPT_ACTIONS_TO_NODE24",
        "actions/setup-java@v5",
        "APK build",
        "AAB build",
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

    if "ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION" in text:
        print(f"FAIL {rel_path} should not opt out to insecure Node runtime")
        failed = True

ci_text = Path(".github/workflows/ci.yml").read_text(encoding="utf-8")

if "actions/setup-java@v4" in ci_text:
    print("FAIL ci.yml still uses actions/setup-java@v4")
    failed = True

for artifact_name in [
    "build/app/outputs/flutter-apk/app-release.apk",
    "build/app/outputs/bundle/release/app-release.aab",
]:
    if artifact_name not in ci_text:
        print(f"FAIL ci.yml missing artifact path: {artifact_name}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-68 GitHub Actions Node 24 readiness verified.")
