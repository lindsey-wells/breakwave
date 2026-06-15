from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "BW-71A makes Rescue more active",
        "Use one immediate redirect",
        "RedirectActionsCard",
        "WaveCompletionCard(",
        "onStillStrong: _logStillStrong",
        "onSlipped: _logSlip",
        "entryType: 'Victory'",
        "entryType: 'Urge'",
        "entryType: 'Slip'",
        "widget.onOpenSupport();",
        "EdgeInsets.fromLTRB(20, 20, 20, 150)",
    ]),
    ("lib/features/rescue/presentation/widgets/wave_completion_card.dart", [
        "BW-71A adds honest Rescue outcomes",
        "I made it through this wave",
        "Still strong",
        "I slipped",
        "onStillStrong",
        "onSlipped",
    ]),
    ("lib/features/rescue/presentation/widgets/calm_reset_card.dart", [
        "BW-71A makes Calm Reset interactive",
        "class CalmResetCard extends StatefulWidget",
        "Timer.periodic",
        "String get verb",
        "return 'Inhale';",
        "return 'Hold';",
        "return 'Exhale';",
        "One calm reset round completed",
        "Start reset",
    ]),
    ("lib/features/rescue/presentation/widgets/wave_timer_card.dart", [
        "with SingleTickerProviderStateMixin",
        "AnimationController",
        "_WaveProgressPainter",
        "CustomPaint",
        "_WaveProgressPainter",
        "Start 90-second timer",
        "Lower now",
        "Still strong",
        "I slipped",
    ]),
    ("launch/rescue_interaction_polish.md", [
        "BW-71A Rescue Interaction Polish",
        "Moves Next Right Action higher",
        "animated wave progress visual",
        "guided breathing stepper",
        "Victory, Urge, and Slip outcomes",
        "without shame",
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
redirect_index = rescue_text.find("RedirectActionsCard(")
timer_index = rescue_text.find("WaveTimerCard(")
if redirect_index == -1 or timer_index == -1 or redirect_index > timer_index:
    print("FAIL RedirectActionsCard should appear before WaveTimerCard in Rescue flow")
    failed = True

calm_text = Path("lib/features/rescue/presentation/widgets/calm_reset_card.dart").read_text(encoding="utf-8")
if "onPressed: () {}" in calm_text:
    print("FAIL Calm Reset contains a dead button callback")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-71A Rescue interaction polish verified.")
