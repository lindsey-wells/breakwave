from pathlib import Path
import sys

checks = [
    ("launch/play_internal_testing_setup.md", [
        "Play Store Internal Testing Setup",
        "breakwave-release-aab",
        "com.cube23.breakwave",
        "BreakWaveapp@proton.me",
        "Data Safety answers are drafted",
        "Upload the signed AAB from GitHub Actions",
        "Copy the tester opt-in link",
        "Test install from Google Play",
        "privacy lock saves a 6-digit PIN",
        "Lock Log & Support keeps Home and Rescue reachable",
        "Known non-MVP deferrals",
        "Play Integrity / runtime licensing",
        "Internal test release notes draft",
    ]),
    ("launch/launch_checklist_draft.md", [
        "Internal testing setup doc reviewed",
        "Internal tester opt-in link created",
        "Signed AAB uploaded to internal testing",
    ]),
    ("launch/release_candidate_status.md", [
        "BW-52 Play internal testing setup",
        "Upload the signed AAB artifact to Google Play Console internal testing.",
        "Verify install through Google Play.",
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

print("PASS: BW-52 Play internal testing setup verified.")
