from pathlib import Path
import sys

checks = [
    ("launch/internal_testing_punch_list.md", [
        "Internal Testing Punch List",
        "P0 — Must fix before internal testing",
        "P1 — Fix during internal testing",
        "P2 — Post-MVP / v1.1",
        "Founder/SlimNation punch-list items",
        "After BW-74, do not add new features unless they are required to fix a P0 blocker.",
    ]),
    ("launch/release_candidate_freeze.md", [
        "BW-74 Release Candidate Freeze",
        "ready to move into internal testing once BW-74 CI is green",
        "MVP feature scope",
        "Bottom navigation structure",
        "Only P0 blockers should interrupt the internal testing handoff.",
    ]),
    ("android/app/src/main/AndroidManifest.xml", [
        'android:label="BreakWave"',
        'android:name=".MainActivity"',
    ]),
    ("android/app/build.gradle.kts", [
        'namespace = "com.cube23.breakwave"',
        'applicationId = "com.cube23.breakwave"',
        "signingConfigs",
        "release",
    ]),
    ("lib/app/breakwave_app.dart", [
        "RecoveryModeGate",
        "BreakWaveShell",
        "themeMode: ThemeMode.dark",
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

bad_user_facing_claims = [
    ("lib", "HIPAA compliant"),
    ("lib", "medical-grade security"),
    ("lib", "guaranteed anonymous"),
    ("lib", "cures addiction"),
    ("lib", "therapy replacement"),
]

for base, needle in bad_user_facing_claims:
    for path in Path(base).rglob("*"):
        if path.is_file() and path.suffix in {".dart", ".md", ".yaml", ".yml", ".txt"}:
            text = path.read_text(encoding="utf-8", errors="ignore")
            if needle.lower() in text.lower():
                print(f"FAIL risky user-facing claim in {path}: {needle}")
                failed = True

if failed:
    sys.exit(1)

print("PASS: BW-74 internal testing freeze verified.")
