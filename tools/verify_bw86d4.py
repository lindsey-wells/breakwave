from pathlib import Path
import sys

text = Path(
    "lib/features/support/presentation/widgets/email_capture_settings_card.dart"
).read_text(encoding="utf-8")

required = [
    "Notes: BW-86D4 adds inline saved-state clarity for email preferences.",
    "String? _savedStatusMessage;",
    "_emailController.addListener(_handleDraftChanged);",
    "_emailController.removeListener(_handleDraftChanged);",
    "void _handleDraftChanged()",
    "_savedStatusMessage = null;",
    "_savedStatusMessage = 'Email preferences saved on this device.';",
    "_savedStatusMessage = 'Email preferences cleared from this device.';",
    "Icons.check_circle_outline",
    "Saved email preferences",
    "Save email preferences",
    "Clear email preferences",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86D4 email saved-state missing: {needle}")
        sys.exit(1)

if text.count("_savedStatusMessage = null;") < 3:
    print("FAIL BW-86D4 email and both consent toggles must clear saved state")
    sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-86D4 introduced a dead callback")
    sys.exit(1)

print("PASS: BW-86D4 email preference saved-state clarity verified.")
