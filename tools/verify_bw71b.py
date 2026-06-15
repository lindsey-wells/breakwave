from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/widgets/remember_why_card.dart", [
        "BW-71B keeps Remember Why visible",
        "Your saved why will appear here during Rescue",
        "Add your why in Support",
        "widget.onOpenSupport",
        "Remember why",
        "hasAnyContent",
    ]),
    ("lib/features/rescue/presentation/widgets/calm_reset_card.dart", [
        "BW-71B guides Calm Reset through three automatic breathing rounds",
        "static const int _targetRounds = 3;",
        "Round ${_completedRounds + 1} of $_targetRounds",
        "Three calm reset rounds completed",
        "One calm reset round completed",
        "Stop reset",
        "_completedRounds = 0;",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "RememberWhyCard(onOpenSupport: widget.onOpenSupport)",
        "RedirectActionsCard(",
        "WaveTimerCard(",
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

rescue_text = Path("lib/features/rescue/presentation/rescue_screen.dart").read_text(encoding="utf-8")
why_index = rescue_text.find("RememberWhyCard(")
redirect_index = rescue_text.find("RedirectActionsCard(")

if why_index == -1 or redirect_index == -1 or why_index > redirect_index:
    print("FAIL RememberWhyCard should appear before RedirectActionsCard")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-71B visible why fallback and calm reset loop verified.")
