from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/widgets/redirect_actions_card.dart", [
        "Purpose: BW-65 Rescue next right action selector.",
        "class RedirectActionsCard",
        "required this.selectedAction",
        "required this.onActionSelected",
        "RecoveryModeStore.changes.addListener",
        "Next Right Action",
        "Choose one immediate action",
        "Do not replace the urge with another harmful habit",
        "ChoiceChip",
        "Put the phone down",
        "Leave the room",
        "Open your why",
        "Text someone safe",
        "Cold water reset",
        "Take a short walk",
        "Pray for one minute",
        "SupportContactActions.sendStrugglingText",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "String? _selectedNextAction;",
        "void _setNextAction(String? value)",
        "final String? nextAction = _selectedNextAction;",
        "actionTaken: nextAction == null",
        "betterPlan: nextAction == null",
        "replacementAction: nextAction ?? ''",
        "Made it through this wave from Rescue using:",
        "RedirectActionsCard(",
        "selectedAction: _selectedNextAction",
        "onActionSelected: _setNextAction",
    ]),
    ("launch/rescue_next_right_action.md", [
        "BW-65 Rescue Next Right Action",
        "choose one clear next right action",
        "single-select",
        "not replace the urge with another harmful habit",
        "Pray for one minute",
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
if "const RedirectActionsCard()" in rescue_text:
    print("FAIL Rescue still uses old const RedirectActionsCard")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-65 Rescue next right action verified.")
