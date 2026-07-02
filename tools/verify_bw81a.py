from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

home = (root / "lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
card = (root / "lib/features/home/presentation/widgets/fast_urge_entry_card.dart").read_text(encoding="utf-8")

home_required = [
    "Start here",
    "Check in each day. If the wave is rising, open Rescue. Afterward, use Log to honestly record what happened.",
    "FastUrgeEntryCard(",
]

card_required = [
    "BW-81A keeps the urgent CTA prominent with Home theme styling.",
    "Use when the wave is rising and you want a quick rescue.",
    "Use when the wave is rising and you want a quick rescue.",
    "width: double.infinity",
    "FilledButton.styleFrom(",
    "minimumSize: const Size.fromHeight(56)",
    "const Icon(Icons.waves)",
    "Break this wave now",
    "'Other'",
    "Fast urge entry",
    "Log urge and open Rescue",
    "Quick urge entry from Home.",
]

for needle in home_required:
    if needle not in home:
        print(f"FAIL BW-81A home missing: {needle}")
        sys.exit(1)

for needle in card_required:
    if needle not in card:
        print(f"FAIL BW-81A fast urge missing: {needle}")
        sys.exit(1)

for forbidden in [
    "Color(0xFFFF8A3D)",
    "Colors.orange",
    "Colors.deepOrange",
    "backgroundColor:",
]:
    if forbidden in card:
        print(f"FAIL BW-81A forbidden non-BreakWave button styling found: {forbidden}")
        sys.exit(1)

print("PASS: BW-81A Home copy, Other trigger, and theme-styled full-width urgent CTA verified.")
