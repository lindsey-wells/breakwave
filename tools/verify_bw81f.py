from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/home/presentation/widgets/fast_urge_entry_card.dart").read_text(encoding="utf-8")

required = [
    "BW-81F adds custom Other trigger capture to Fast Urge.",
    "final TextEditingController _otherTriggerController",
    "_otherTriggerController.dispose()",
    "static const String _otherLabel = 'Other';",
    "_otherLabel,",
    "void _setSelectedTrigger(String trigger, bool selected)",
    "String? _resolvedTrigger()",
    "final bool showOtherTriggerField = _selectedTrigger == _otherLabel;",
    "if (showOtherTriggerField) ...<Widget>[",
    "TextField(",
    "controller: _otherTriggerController",
    "labelText: 'Name the trigger'",
    "hintText: 'Example: Instagram, argument, hotel room'",
    "helperText: 'Optional. Blank saves as Other.'",
    "customTrigger.isEmpty ? _otherLabel : 'Other: $customTrigger'",
    "trigger: _resolvedTrigger()",
    "Log urge and open Rescue",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-81F Fast Urge Other input missing: {needle}")
        sys.exit(1)

for forbidden in [
    "trigger: _selectedTrigger",
]:
    if forbidden in card:
        print(f"FAIL BW-81F still saves raw selected trigger: {forbidden}")
        sys.exit(1)

print("PASS: BW-81F Fast Urge custom Other trigger input verified.")
