from pathlib import Path
import sys

path = Path("lib/features/home/presentation/home_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "Purpose: BW-57 home dashboard cleanup",
    "final bool hasRecoveryData = summary.totalEntries > 0;",
    "EdgeInsets.fromLTRB(16, 14, 16, 150)",
    "When the wave rises, start with Rescue.",
        "eyebrow: 'Today'",
    "Check in and prepare for risk windows",
    "eyebrow: 'Your setup'",
    "Keep your reasons and triggers visible",
    "if (hasRecoveryData) ...<Widget>",
    "RecoverySnapshotCard",
    "LatestLoggedMomentCard",
    "SimpleInsightsCard",
    "Pattern awareness",
    "DailyEncouragementCard",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL home_screen.dart missing: {needle}")
        failed = True

order = [
    "FastUrgeEntryCard",
        "DailyEncouragementCard",
    "eyebrow: 'Today'",
    "DailyCheckInCard",
    "BedtimeDangerModeCard",
    "eyebrow: 'Your setup'",
    "ReasonsFocusCard",
    "TriggersWatchCard",
    "if (hasRecoveryData) ...<Widget>",
    "RecoverySnapshotCard",
    "Pattern awareness",
    "RecoveryCyclePreviewCard",
]

positions = {}
for needle in order:
    index = text.find(needle)
    if index == -1:
        print(f"FAIL cannot find order marker: {needle}")
        failed = True
    else:
        positions[needle] = index

if len(positions) == len(order):
    for before, after in zip(order, order[1:]):
        if positions[before] >= positions[after]:
            print(f"FAIL order issue: {before} should appear before {after}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-57 Home cleanup and empty-state reduction verified.")
