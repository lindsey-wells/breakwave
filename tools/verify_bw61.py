from pathlib import Path
import sys

path = Path("lib/features/home/presentation/home_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "FastUrgeEntryCard",
    "DailyEncouragementCard",
    "eyebrow: 'Today'",
    "DailyCheckInCard",
    "BedtimeDangerModeCard",
    "eyebrow: 'Your setup'",
    "RecoverySnapshotCard",
    "SimpleInsightsCard",
    "RecoveryCyclePreviewCard",
]

blocked = [
    "HomeHeroCard(",
    "home_hero_card.dart",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL home_screen.dart missing: {needle}")
        failed = True

for needle in blocked:
    if needle in text:
        print(f"FAIL home_screen.dart still contains duplicate action card marker: {needle}")
        failed = True

order = [
    "FastUrgeEntryCard",
    "DailyEncouragementCard",
    "eyebrow: 'Today'",
    "DailyCheckInCard",
    "BedtimeDangerModeCard",
    "eyebrow: 'Your setup'",
    "if (hasRecoveryData) ...<Widget>",
    "RecoverySnapshotCard",
    "Pattern awareness",
    "RecoveryCyclePreviewCard",
]

positions = {}
for marker in order:
    index = text.find(marker)
    if index == -1:
        print(f"FAIL missing order marker: {marker}")
        failed = True
    else:
        positions[marker] = index

if len(positions) == len(order):
    for before, after in zip(order, order[1:]):
        if positions[before] >= positions[after]:
            print(f"FAIL order issue: {before} should appear before {after}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-61 Home screenshot polish verified.")
