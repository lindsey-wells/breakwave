from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

rescue = (root / "lib/features/rescue/presentation/rescue_screen.dart").read_text(encoding="utf-8")
card = (root / "lib/features/rescue/presentation/widgets/redirect_actions_card.dart").read_text(encoding="utf-8")

rescue_required = [
    "final GlobalKey _rememberWhyKey = GlobalKey();",
    "key: _rememberWhyKey",
    "child: RememberWhyCard(onOpenSupport: widget.onOpenSupport)",
    "onOpenWhy: () => _scrollTo(_rememberWhyKey)",
    "selectedAction: _selectedNextAction",
    "onActionSelected: _setNextAction",
    "replacementAction: nextAction ?? ''",
]

card_required = [
    "BW-82C makes Open your why actionable and adds Other capture.",
    "required this.onOpenWhy",
    "final VoidCallback onOpenWhy;",
    "final TextEditingController _otherActionController = TextEditingController();",
    "_otherActionController.dispose();",
    "static const String _otherLabel = 'Other';",
    "_otherLabel,",
    "bool _isOtherAction(String? action)",
    "bool get _isOtherSelected",
    "String get _customOtherAction",
    "void _syncOtherActionController()",
    "void _setOtherActionText(String value)",
    "Other: $customAction",
    "widget.onOpenWhy();",
    "case 'Open your why':",
    "case _otherLabel:",
    "TextField(",
    "controller: _otherActionController",
    "onChanged: _setOtherActionText",
    "labelText: 'Name the next right action'",
    "helperText: 'Optional. Blank saves as Other.'",
]

for needle in rescue_required:
    if needle not in rescue:
        print(f"FAIL BW-82C Rescue screen missing: {needle}")
        sys.exit(1)

for needle in card_required:
    if needle not in card:
        print(f"FAIL BW-82C RedirectActionsCard missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in rescue or "onPressed: () {}" in card:
    print("FAIL BW-82C introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-82C Next Right Action scroll-to-why and Other capture verified.")
