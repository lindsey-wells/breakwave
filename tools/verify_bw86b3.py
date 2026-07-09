from pathlib import Path
import sys

reminder = Path("lib/features/support/presentation/widgets/reminder_settings_card.dart").read_text(encoding="utf-8")
notifications = Path("lib/core/reminders/breakwave_notifications.dart").read_text(encoding="utf-8")

required_reminder = [
    "Notes: BW-86B3 adds saved-state clarity and stronger reminder copy.",
    "String? _savedStatusMessage;",
    "void _clearSavedStatus()",
    "_savedStatusMessage = null;",
    "_clearSavedStatus();",
    "Reminder settings saved. Daily check-ins and watch-for nudges will use the times you chose.",
    "Android may still delay delivery if battery saver is active.",
    "Icons.check_circle_outline",
    "Saved reminder settings",
    "Save reminder settings",
]

required_notifications = [
    "Notes: BW-86B3 strengthens check-in and danger-window nudge copy.",
    "Pause for 20 seconds. Open BreakWave and choose one clean next step.",
    "Danger window. Pause now. Open BreakWave and choose one clean next step.",
    "Pause now.",
    "AndroidScheduleMode.inexactAllowWhileIdle",
]

for needle in required_reminder:
    if needle not in reminder:
        print(f"FAIL BW-86B3 reminder saved-state missing: {needle}")
        sys.exit(1)

for needle in required_notifications:
    if needle not in notifications:
        print(f"FAIL BW-86B3 notification copy missing: {needle}")
        sys.exit(1)

for old_copy in [
    "Pause for 20 seconds and choose one clean next step.",
    "Pause early and choose one clean next step.",
    "Pause early.",
]:
    if old_copy in notifications:
        print(f"FAIL BW-86B3 old notification copy still present: {old_copy}")
        sys.exit(1)

if "onPressed: () {}" in reminder:
    print("FAIL BW-86B3 introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-86B3 reminder trust polish verified.")
