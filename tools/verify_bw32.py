from pathlib import Path
import sys

checks = [
    ("launch/README.md", [
        "# BreakWave Launch Drafts",
        "store metadata",
        "screenshot copy",
        "launch checklist",
        "core help free forever",
        "BreakWave Plus",
    ]),
    ("launch/play_store_metadata_draft.md", [
        "# BreakWave — Play Store Metadata Draft",
        "BreakWave",
        "Ride the wave. Interrupt the pattern.",
        "BreakWave Plus",
        "Secular",
        "Christian",
    ]),
    ("launch/screenshot_copy_draft.md", [
        "# BreakWave — Screenshot Copy Draft",
        "Ride the wave. Interrupt the pattern.",
        "Fast help in hard moments",
        "Late night needs its own support",
        "Free immediate relief. Paid ongoing transformation.",
    ]),
    ("launch/launch_checklist_draft.md", [
        "# BreakWave — Launch Checklist Draft",
        "Product readiness",
        "Store assets",
        "Policy / trust",
        "Technical release prep",
        "Open decisions",
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

print("PASS: BW-32 launch prep drafts verified.")
