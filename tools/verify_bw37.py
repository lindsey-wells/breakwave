from pathlib import Path
import sys

checks = [
    ("launch/release_candidate_status.md", [
        "# BreakWave — Release Candidate Status",
        "release candidate baseline",
        "No new feature scope unless a true launch blocker is found",
        "save reliability",
        "rescue flow",
        "refresh correctness",
        "premium routing",
        "privacy/reminder safety",
        "No launch blockers logged",
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

print("PASS: BW-37 release candidate baseline verified.")
