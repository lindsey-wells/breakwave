from pathlib import Path
import sys

text = Path(
    "lib/features/support/presentation/widgets/email_capture_settings_card.dart"
).read_text(encoding="utf-8")

required = [
    "Notes: BW-86D5 clarifies that saving does not send email.",
    "Saving stores these preferences on this device.",
    "It does not send an email or contact BreakWave.",
    "Save preferences on this device",
    "Saved email preferences",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86D5 local-save clarity missing: {needle}")
        sys.exit(1)

print("PASS: BW-86D5 email local-save clarity verified.")
