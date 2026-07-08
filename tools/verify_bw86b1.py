from pathlib import Path
import sys

path = Path("lib/features/support/presentation/widgets/custom_why_settings_card.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-86B1 adds inline saved-state clarity for Custom Why.",
    "String? _savedStatusMessage;",
    "_whyController.addListener(_handleDraftChanged);",
    "_whyController.removeListener(_handleDraftChanged);",
    "void _handleDraftChanged()",
    "_savedStatusMessage = null;",
    "_savedStatusMessage = 'Custom why saved for Rescue.';",
    "_savedStatusMessage = 'Why image saved for Rescue.';",
    "_savedStatusMessage = 'Why image removed from Rescue.';",
    "This will appear in Rescue when the wave rises.",
    "Icons.check_circle_outline",
    "Saved custom why",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86B1 Custom Why saved-state missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-86B1 introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-86B1 Custom Why saved-state clarity verified.")
