from pathlib import Path
import sys

checks = [
    ("lib/features/home/presentation/home_screen.dart", [
        "BW-78A simplifies Home for launch and moves the user's why higher.",
        "'Today'",
        "'Start here'",
        "Check in each day. If the wave is rising, open Rescue. Afterward, use Log to honestly record what happened.",
        "title: 'Your why and risk signals'",
        "title: 'Check in'",
        "eyebrow: 'Progress'",
        "title: 'Your recent pattern'",
        "title: 'Learn the pattern'",
        "const ReasonsFocusCard()",
        "const DailyCheckInCard()",
    ]),
    ("lib/features/reasons/presentation/reasons_focus_card.dart", [
        "Your why right now",
        "This keeps Home anchored to something real.",
    ]),
    ("lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart", [
        "Learn the Wave Pattern",
        "Trigger → Urge → Pressure → Choice → Reset",
        "Tap to open the Recovery Cycle Wheel.",
    ]),
    ("lib/features/cycle/domain/recovery_cycle_stage.dart", [
        "The wave gets stronger and more persuasive.",
    ]),
]

forbidden = [
    "Home Current",
    "Steady water, clear direction.",
    "Check in and prepare for risk windows",
    "Keep your reasons and triggers visible",
    "See where you are right now",
    "Learn what keeps the wave going",
    "Recovery cycle wheel",
    "Trigger → Urge → Escalation → Action → Regret / Recovery",
    "Tap to see where to interrupt the wave earlier.",
    "The wave gets louder and more persuasive.",
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
if home_text.find("const ReasonsFocusCard()") > home_text.find("const DailyCheckInCard()"):
    print("FAIL Home why card should appear before daily check-in for launch clarity.")
    failed = True

for rel_path in [
    "lib/features/home/presentation/home_screen.dart",
    "lib/features/reasons/presentation/reasons_focus_card.dart",
    "lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart",
    "lib/features/cycle/domain/recovery_cycle_stage.dart",
]:
    text = Path(rel_path).read_text(encoding="utf-8")
    for bad in forbidden:
        if bad in text:
            print(f"FAIL stale Home launch copy remains in {rel_path}: {bad}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-78A/BW-81A Home simplification and launch polish verified.")
