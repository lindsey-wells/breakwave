from pathlib import Path
import sys

checks = [
    ("lib/features/home/presentation/home_screen.dart", [
        "padding: const EdgeInsets.fromLTRB(16, 14, 16, 150)",
        "FastUrgeEntryCard",
        "DailyEncouragementCard",
        "BedtimeDangerModeCard",
        "ReasonsFocusCard",
        "TriggersWatchCard",
        "RecoveryCyclePreviewCard",
        "Learn the pattern",
    ]),
    ("lib/features/home/presentation/widgets/fast_urge_entry_card.dart", [
        "BW-81A keeps the urgent CTA prominent",
        "Break this wave now",
        "Log urge and open Rescue",
        "minimumSize: const Size.fromHeight(56)",
    ]),
    ("lib/features/home/presentation/widgets/daily_encouragement_card.dart", [
        "BW-70A tightens Home layout",
        "Daily Encouragement",
        "You only need to stay with the next honest decision.",
        "EdgeInsets.fromLTRB(16, 15, 16, 16)",
    ]),
    ("lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart", [
        "padding: const EdgeInsets.all(16)",
        "Open Rescue now",
        "EdgeInsets.symmetric(vertical: 12)",
    ]),
    ("lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart", [
        "BW-70A compacts the cycle preview",
        "Trigger → Urge → Pressure → Choice → Reset",
        "Tap to learn where to interrupt the wave sooner.",
        "EdgeInsets.fromLTRB(16, 15, 16, 16)",
    ]),
    ("launch/home_layout_polish.md", [
        "BW-70A Home Layout Polish",
        "without adding new features",
        "Break this wave now",
        "less oversized",
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

for path in Path("lib/features/home").rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    if "coming soon" in text.lower():
        print(f"FAIL Home contains coming-soon copy: {path}")
        failed = True
    if "onPressed: () {}" in text:
        print(f"FAIL Home contains dead button callback: {path}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-70A/BW-81A Home layout polish verified.")
