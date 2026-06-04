from pathlib import Path
import sys

checks = [
    ("lib/features/home/presentation/widgets/home_hero_card.dart", [
        "Purpose: BW-60B Home action card polish.",
        "Use the next right step.",
        "When an urge hits, open Rescue. When something happens, log it fast. Keep the next move simple.",
        "Open Rescue",
        "Quick Log",
    ]),
    ("lib/features/home/presentation/home_screen.dart", [
        "HomeHeroCard",
        "DailyEncouragementCard",
        "eyebrow: 'Today'",
        "DailyCheckInCard",
        "RecoveryCyclePreviewCard",
    ]),
]

blocked = [
    ("lib/features/home/presentation/widgets/home_hero_card.dart", "being shaped into"),
    ("lib/features/home/presentation/widgets/home_hero_card.dart", "calm, practical recovery tool"),
    ("lib/features/home/presentation/widgets/home_hero_card.dart", "When When"),
    ("lib/features/home/presentation/widgets/home_hero_card.dart", "go straight to Rescue"),
    ("lib/features/home/presentation/widgets/home_hero_card.dart", "Ride the urge. Regain control."),
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

for rel_path, needle in blocked:
    path = Path(rel_path)
    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")
    if needle in text:
        print(f"FAIL {rel_path} still contains bad copy: {needle}")
        failed = True

home_text = Path("lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
order = [
    "FastUrgeEntryCard",
    "HomeHeroCard",
    "DailyEncouragementCard",
    "eyebrow: 'Today'",
    "DailyCheckInCard",
    "BedtimeDangerModeCard",
    "eyebrow: 'Your setup'",
    "RecoveryCyclePreviewCard",
]

positions = {}
for marker in order:
    index = home_text.find(marker)
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

print("PASS: BW-60B Home hero copy and encouragement placement verified.")
