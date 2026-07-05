from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "final VoidCallback onOpenLog;",
        "final GlobalKey _rememberWhyKey = GlobalKey();",
        "key: _rememberWhyKey",
        "onOpenWhy: () => _scrollTo(_rememberWhyKey)",
        "snackBarText: 'Wave saved. You made it through this wave.'",
        "returnHome: false",
        "Widget _buildWaveSavedFollowUpCard(BuildContext context)",
        "Open Log",
        "Return Home",
        "Stay in Rescue",
        "The wave is still here",
        "Open Support",
    ]),
    ("lib/features/rescue/presentation/widgets/remember_why_card.dart", [
        "Notes: BW-82A lets the user add or edit their why directly in Rescue.",
        "Add your why here",
        "Save why for Rescue",
        "Edit why",
    ]),
    ("lib/features/rescue/presentation/widgets/redirect_actions_card.dart", [
        "Notes: BW-82C makes Open your why actionable and adds Other capture.",
        "final VoidCallback onOpenWhy;",
        "static const String _otherLabel = 'Other';",
        "Name the next right action",
        "Other: $customAction",
    ]),
    ("lib/features/rescue/presentation/widgets/calm_reset_card.dart", [
        "Notes: BW-82D adds a short settle pause after the exhale step.",
        "Notes: BW-82D1 clears the settle-pause flag before the next round starts.",
        "Let it settle",
        "_isPostStepPause = false;",
    ]),
    ("lib/features/rescue/presentation/widgets/rescue_card_engine.dart", [
        "Notes: BW-82E adds horizontal swipe navigation while keeping button fallback.",
        "GestureDetector",
        "onHorizontalDragEnd: _handleCardSwipe",
        "Swipe left or right for another rescue card.",
        "Show another Christian rescue card",
        "Show another secular rescue card",
    ]),
    ("launch/rescue_final_qa.md", [
        "BW-83A Rescue Final QA",
        "Remember Why can be added or edited directly inside Rescue.",
        "Calm Reset clears the settle state before returning to inhale.",
        "Wave saved follow-up offers Open Log, Return Home, and Stay in Rescue.",
        "Slip saves without shame language and opens Support.",
    ]),
]

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL BW-83A missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-83A {rel_path} missing: {needle}")
            sys.exit(1)

rescue_text = Path("lib/features/rescue").read_text(encoding="utf-8") if Path("lib/features/rescue").is_file() else ""

for rel_path in Path("lib/features/rescue").rglob("*.dart"):
    text = rel_path.read_text(encoding="utf-8")
    lower = text.lower()

    if "onPressed: () {}" in text:
        print(f"FAIL BW-83A dead button callback in {rel_path}")
        sys.exit(1)

    if "todo" in lower or "fixme" in lower or "coming soon" in lower:
        print(f"FAIL BW-83A unfinished marker in {rel_path}")
        sys.exit(1)

if "Nice work. Wave saved with your next right action." in Path("lib/features/rescue/presentation/rescue_screen.dart").read_text(encoding="utf-8"):
    print("FAIL BW-83A stale wave saved snackbar copy remains")
    sys.exit(1)

print("PASS: BW-83A Rescue final QA marker verified.")
