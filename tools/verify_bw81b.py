from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

home = (root / "lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
card = (root / "lib/features/home/presentation/widgets/fast_urge_entry_card.dart").read_text(encoding="utf-8")

home_required = [
    "BW-81B adds clear Start here actions for check-in, Rescue, and Log.",
    "final GlobalKey _checkInSectionKey = GlobalKey();",
    "void _scrollToDailyCheckIn()",
    "Scrollable.ensureVisible(",
    "FilledButton.tonalIcon(",
    "label: const Text('Check in')",
    "onPressed: widget.onOpenRescue",
    "label: const Text('Open Rescue')",
    "onPressed: widget.onOpenLog",
    "label: const Text('Open Log')",
    "KeyedSubtree(",
    "key: _checkInSectionKey",
    "const DailyCheckInCard()",
]

card_required = [
    "BW-81B simplifies quick rescue copy and strengthens the CTA label.",
    "Need help right now?",
    "Use when the wave is rising and you want a quick rescue.",
    "Break this wave now",
    "width: double.infinity",
    "minimumSize: const Size.fromHeight(56)",
    "const Icon(Icons.waves)",
    "'Other'",
    "Log urge and open Rescue",
]

for needle in home_required:
    if needle not in home:
        print(f"FAIL BW-81B home missing: {needle}")
        sys.exit(1)

for needle in card_required:
    if needle not in card:
        print(f"FAIL BW-81B fast urge missing: {needle}")
        sys.exit(1)

for forbidden in [
    "Color(0xFFFF8A3D)",
    "Colors.orange",
    "Colors.deepOrange",
    "backgroundColor:",
]:
    if forbidden in card:
        print(f"FAIL BW-81B forbidden non-BreakWave button styling found: {forbidden}")
        sys.exit(1)

print("PASS: BW-81B Home Start here actions and quick rescue CTA verified.")
