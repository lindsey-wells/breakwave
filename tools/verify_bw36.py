from pathlib import Path
import sys

checks = [
    ("launch/README_release_candidate.md", [
        "# BreakWave Release Candidate Sweep",
        "release_candidate_smoke_checklist.md",
        "release_candidate_blockers.md",
        "rescue flow reliability",
        "save flow reliability",
    ]),
    ("launch/release_candidate_smoke_checklist.md", [
        "# BreakWave — Release Candidate Smoke Checklist",
        "First-run and recovery mode",
        "Home → Rescue → Log core loop",
        "Daily check-in / bedtime / widget sync",
        "Reminders / privacy resilience",
        "Premium routing",
        "Christian / secular path sanity",
        "Support and learning surfaces",
    ]),
    ("launch/release_candidate_blockers.md", [
        "# BreakWave — Release Candidate Blockers",
        "Blocker: must be fixed before launch candidate",
        "Current blocker list",
        "None logged yet",
    ]),
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "_homeRefreshTick",
        "_logRefreshTick",
        "ValueKey<int>(_homeRefreshTick)",
        "ValueKey<int>(_logRefreshTick)",
    ]),
    ("lib/core/reminders/breakwave_notifications.dart", [
        "safeInitialize()",
        "safeRequestPermissions()",
        "safeRescheduleAll(",
    ]),
    ("lib/core/widget/home_widget_sync.dart", [
        "class BreakWaveHomeWidgetSync",
        "Widget sync is optional. Never let it block a core save flow.",
    ]),
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "BreakWave Plus",
        "$59.99/year",
        "$8.99/month",
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

print("PASS: BW-36 release candidate smoke sweep verified.")
