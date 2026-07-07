from pathlib import Path
import sys

path = Path("lib/features/log/presentation/log_screen.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-84C adds a top-of-page Update Mode banner for edit clarity.",
    "Widget _buildEditingStatusBanner(BuildContext context)",
    "'Update Mode'",
    "Changes will update this saved log entry instead of creating a new one.",
    "_buildEditingStatusBanner(context)",
    "Cancel edit",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-84C Log update mode banner missing: {needle}")
        sys.exit(1)

if "'Editing a saved entry'" in text:
    print("FAIL BW-84C plain top edit text remains instead of banner")
    sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-84C introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-84C Log Update Mode top banner verified.")
