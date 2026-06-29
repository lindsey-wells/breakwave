from pathlib import Path
import sys

checks = [
    ("lib/features/home/presentation/home_screen.dart", [
        "Open Rescue when the wave rises.",
        "FastUrgeEntryCard(",
        "DailyEncouragementCard()",
        "SectionHeader(",
        "title: 'Your why and risk signals'",
        "const ReasonsFocusCard()",
        "const TriggersWatchCard()",
        "title: 'Check in'",
        "const DailyCheckInCard()",
        "BedtimeDangerModeCard(",
        "eyebrow: 'Progress'",
        "title: 'Your recent pattern'",
        "RecoverySnapshotCard(",
        "LatestLoggedMomentCard(",
        "SimpleInsightsCard()",
        "title: 'Learn the pattern'",
        "RecoveryCyclePreviewCard()",
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

home_text = Path("lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
reasons_index = home_text.find("const ReasonsFocusCard()")
checkin_index = home_text.find("const DailyCheckInCard()")

if reasons_index == -1 or checkin_index == -1 or reasons_index > checkin_index:
    print("FAIL order issue: ReasonsFocusCard should appear before DailyCheckInCard")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-57 home dashboard cleanup verified.")
