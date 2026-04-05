from pathlib import Path
import sys

checks = [
    ("lib/main.dart", [
        "try {",
        "await BreakWaveNotifications.initialize();",
        "Notification init is optional. Never let it block app launch.",
    ]),
    ("lib/core/reminders/breakwave_notifications.dart", [
        "static Future<bool> safeInitialize()",
        "static Future<bool> safeRequestPermissions()",
        "static Future<bool> safeRescheduleAll(",
    ]),
    ("lib/features/support/presentation/widgets/reminder_settings_card.dart", [
        "final bool wantsNotifications =",
        "await BreakWaveNotifications.safeRequestPermissions()",
        "final bool rescheduled = await BreakWaveNotifications.safeRescheduleAll(",
        "Reminder settings saved locally. Notification permission may still be needed.",
        "Reminder settings saved locally. Notification refresh may need another try.",
        "Reminder settings saved locally. Notification permission or refresh may need another try.",
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

print("PASS: BW-34 release-readiness sweep verified.")
