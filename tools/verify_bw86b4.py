from pathlib import Path
import sys

path = Path("lib/features/support/presentation/widgets/reminder_settings_card.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-86B4 improves reminder time picker contrast and timing clarity.",
    "Future<TimeOfDay?> _showBreakWaveTimePicker",
    "initialEntryMode: TimePickerEntryMode.dial",
    "helpText: helpText",
    "cursorColor: colorScheme.primary",
    "selectionColor: colorScheme.primaryContainer",
    "selectionHandleColor: colorScheme.primary",
    "Choose daily check-in time",
    "Choose watch-for nudge time",
    "Android may delay scheduled reminders slightly when Battery Saver or background limits are active.",
    "Saved reminder settings",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86B4 reminder picker UX missing: {needle}")
        sys.exit(1)

if "showTimePicker(" in text and "await showTimePicker(" in text:
    print("FAIL BW-86B4 direct showTimePicker call still present")
    sys.exit(1)

print("PASS: BW-86B4 reminder picker UX and timing clarity verified.")
