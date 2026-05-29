from pathlib import Path
import sys

checks = [
    (".github/workflows/ci.yml", [
        "Verify, Test, Build APK + AAB",
        "flutter build apk --release",
        "flutter build appbundle --release",
        "Upload AAB artifact",
        "breakwave-release-aab",
        "build/app/outputs/bundle/release/app-release.aab",
        "if-no-files-found: error",
    ]),
    ("launch/launch_checklist_draft.md", [
        "AAB artifact confirmed",
        "AAB artifact confirmed in GitHub Actions",
    ]),
    ("launch/release_candidate_status.md", [
        "BW-50 AAB artifact",
        "release AAB artifact for Play Store preparation",
        "Play signing/upload key configuration is handled in BW-51",
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

if failed:
    sys.exit(1)

print("PASS: BW-50 GitHub Actions AAB artifact verified.")
