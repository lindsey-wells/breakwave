from pathlib import Path
import sys

checks = [
    (
        "lib/core/ui/breakwave_app_bar.dart",
        [
            "class BreakWaveAppBar",
            "BreakWaveWordmark",
            "sectionTitle",
        ],
    ),
    (
        "lib/core/branding/breakwave_wordmark.dart",
        [
            "class BreakWaveWordmark",
            "assetPath",
            "assets/branding/breakwave_in_app_header.png",
            "Image.asset(",
            "BreakWave brand wordmark",
            "fontWeight: FontWeight.w900",
            "letterSpacing: -0.8",
            "errorBuilder:",
        ],
    ),
    (
        "lib/features/home/presentation/home_screen.dart",
        [
            "BreakWaveAppBar",
            "sectionTitle: 'Home'",
        ],
    ),
    (
        "lib/features/rescue/presentation/rescue_screen.dart",
        [
            "BreakWaveAppBar",
            "sectionTitle: 'Rescue'",
        ],
    ),
    (
        "lib/features/log/presentation/log_screen.dart",
        [
            "BreakWaveAppBar",
            "sectionTitle: 'Log'",
        ],
    ),
    (
        "lib/features/support/presentation/support_screen.dart",
        [
            "BreakWaveAppBar",
            "sectionTitle: 'Support'",
        ],
    ),
    (
        "lib/features/home/presentation/widgets/home_hero_card.dart",
        [
            "Use the next right step.",
            "When an urge hits, open Rescue.",
            "Keep the next move simple.",
        ],
    ),
    (
        "launch/screenshot_visual_qa_checklist.md",
        [
            "BreakWave — Screenshot Visual QA Checklist",
            "Branded BreakWave header appears at the top.",
            "Prototype copy such as",
            "BreakWave Plus explains free versus paid clearly.",
            (
                "calm, organized, private, and "
                "intentionally branded"
            ),
        ],
    ),
]

blocked = [
    (
        "lib/features/home/presentation/widgets/"
        "home_hero_card.dart",
        "being shaped into",
    ),
    (
        "lib/features/rescue/presentation/widgets/"
        "support_escalation_card.dart",
        "Support tools expanding soon",
    ),
    (
        "lib/features/support/presentation/widgets/"
        "email_app_handoff_card.dart",
        "BreakWave team email override",
    ),
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
            print(
                f"FAIL {rel_path} missing: {needle}"
            )
            failed = True

for rel_path, needle in blocked:
    path = Path(rel_path)

    if not path.exists():
        continue

    text = path.read_text(encoding="utf-8")

    if needle in text:
        print(
            "FAIL "
            f"{rel_path} still contains "
            f"old/prototype copy: {needle}"
        )
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: BW-58/59/60 brand-header intent, "
    "Home copy, and screenshot QA verified "
    "through the isolated approved wordmark helper."
)
