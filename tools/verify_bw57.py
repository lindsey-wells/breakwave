from pathlib import Path
import sys

path = Path("lib/features/home/presentation/home_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "If the wave is rising, open Rescue.",
    "FastUrgeEntryCard(",
    "title: 'Your why and risk signals'",
    "const ReasonsFocusCard()",
    "const TriggersWatchCard()",
    "DailyEncouragementCard()",
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
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL {path} missing: {needle}")
        failed = True

reasons_index = text.find("const ReasonsFocusCard()")
checkin_index = text.find("const DailyCheckInCard()")
bedtime_index = text.find("BedtimeDangerModeCard(")

if reasons_index == -1 or checkin_index == -1 or reasons_index > checkin_index:
    print("FAIL order issue: ReasonsFocusCard should appear before DailyCheckInCard")
    failed = True

if checkin_index == -1 or bedtime_index == -1 or checkin_index > bedtime_index:
    print("FAIL order issue: DailyCheckInCard should appear before BedtimeDangerModeCard")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-57 home dashboard cleanup verified.")
