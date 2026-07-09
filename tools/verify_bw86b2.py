from pathlib import Path
import sys

path = Path("lib/features/support/presentation/widgets/support_contact_card.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-86B2 adds inline saved-state clarity for trusted contact.",
    "String? _savedStatusMessage;",
    "_nameController.addListener(_handleDraftChanged);",
    "_phoneController.addListener(_handleDraftChanged);",
    "_emailController.addListener(_handleDraftChanged);",
    "_nameController.removeListener(_handleDraftChanged);",
    "_phoneController.removeListener(_handleDraftChanged);",
    "_emailController.removeListener(_handleDraftChanged);",
    "void _handleDraftChanged()",
    "_savedStatusMessage = null;",
    "_savedStatusMessage = 'Trusted contact saved.';",
    "_savedStatusMessage = 'Trusted contact cleared.';",
    "Ready for ${_nameController.text.trim()} when you need support.",
    "Trusted contact cleared. Add a new person when you are ready.",
    "Icons.check_circle_outline",
    "Saved trusted contact",
    "Save trusted contact",
    "Clear trusted contact",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86B2 trusted contact saved-state missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-86B2 introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-86B2 trusted contact saved-state clarity verified.")
