from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart").read_text(encoding="utf-8")

required = [
    "BW-81E reframes the teaser as Learn the Wave Pattern.",
    "RecoveryCycleWheelScreen",
    "Learn the Wave Pattern",
    "Trigger → Urge → Pressure → Choice → Reset",
    "Recovery gets easier when you can spot the wave before it takes over.",
    "What it feels like",
    "What to watch for",
    "What BreakWave helps you do",
    "Next right action",
    "Tap to open the Recovery Cycle Wheel.",
    "class _WavePatternRow",
    "class _WavePatternStep",
    "Icons.waves",
    "Icons.chevron_right",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-81E wave pattern teaser missing: {needle}")
        sys.exit(1)

if card.count("_WavePatternStep(") < 4:
    print("FAIL BW-81E expected four wave pattern learning steps")
    sys.exit(1)

for forbidden in [
    "The recovery pattern",
    "Tap to learn where to interrupt the wave sooner.",
]:
    if forbidden in card:
        print(f"FAIL BW-81E old vague teaser copy still present: {forbidden}")
        sys.exit(1)

print("PASS: BW-81E Learn the Wave Pattern teaser verified.")
