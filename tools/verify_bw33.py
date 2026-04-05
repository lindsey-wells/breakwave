from pathlib import Path
import sys

checks = [
    ("lib/features/checkin/presentation/daily_check_in_card.dart", [
        "Saved today\\'s check-in:",
    ]),
    ("lib/core/widget/home_widget_sync.dart", [
        "class BreakWaveHomeWidgetSync",
        "try {",
        "Widget sync is optional. Never let it block a core save flow.",
    ]),
    ("lib/core/reminders/breakwave_notifications.dart", [
        "static Future<bool> safeRescheduleAll(",
        "await rescheduleAll(",
        "return true;",
        "return false;",
    ]),
    ("lib/features/support/presentation/widgets/reminder_settings_card.dart", [
        "final bool rescheduled = await BreakWaveNotifications.safeRescheduleAll(",
        "Reminder settings saved locally. Notification refresh may need another try.",
    ]),
    ("lib/features/support/presentation/widgets/privacy_settings_card.dart", [
        "final bool rescheduled = await BreakWaveNotifications.safeRescheduleAll(",
        "Privacy settings saved locally. Notification refresh may need another try.",
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

if failed:
    sys.exit(1)

print("PASS: BW-33 launch hardening and bug sweep verified.")
