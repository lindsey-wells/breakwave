from pathlib import Path
import sys

checks = [
    ("pubspec.yaml", [
        "flutter_local_notifications:",
        "flutter_timezone:",
        "timezone:",
    ]),
    ("lib/core/reminders/reminder_settings.dart", [
        "class ReminderSettings",
        "dailyReminderEnabled",
        "riskyNudgeEnabled",
        "defaults",
        "copyWith",
    ]),
    ("lib/core/reminders/reminder_settings_store.dart", [
        "class ReminderSettingsStore",
        "bw_reminder_settings_v1",
        "load()",
        "save(",
    ]),
    ("lib/core/reminders/breakwave_notifications.dart", [
        "class BreakWaveNotifications",
        "FlutterLocalNotificationsPlugin",
        "FlutterTimezone.getLocalTimezone()",
        "currentTimeZone.identifier",
        "zonedSchedule(",
        "dailyReminderId",
        "riskyNudgeId",
    ]),
    ("lib/features/support/presentation/widgets/reminder_settings_card.dart", [
        "class ReminderSettingsCard",
        "Reminders and nudges",
        "Daily check-in reminder",
        "Risky-time nudge",
        "Save reminder settings",
        "Watch-for preview:",
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

for rel_path in [
    "lib/main.dart",
    "lib/features/support/presentation/support_screen.dart",
    "android/app/src/main/AndroidManifest.xml",
]:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True

main_path = Path("lib/main.dart")
if main_path.exists():
    main_text = main_path.read_text(encoding="utf-8")
    if "BreakWaveNotifications.initialize()" not in main_text:
        print("FAIL lib/main.dart missing: BreakWaveNotifications.initialize()")
        failed = True

support_path = Path("lib/features/support/presentation/support_screen.dart")
if support_path.exists():
    support_text = support_path.read_text(encoding="utf-8")
    if "ReminderSettingsCard" not in support_text:
        print("FAIL lib/features/support/presentation/support_screen.dart missing: ReminderSettingsCard")
        failed = True

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
if manifest_path.exists():
    manifest_text = manifest_path.read_text(encoding="utf-8")
    for needle in [
        "android.permission.RECEIVE_BOOT_COMPLETED",
        "com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver",
        "com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver",
    ]:
        if needle not in manifest_text:
            print(f"FAIL android/app/src/main/AndroidManifest.xml missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-22 local reminders and risky-time nudges verified.")
