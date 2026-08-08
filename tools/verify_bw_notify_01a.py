#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent

MODEL = ROOT / "lib/core/reminders/notification_readiness.dart"
SERVICE = ROOT / "lib/core/reminders/breakwave_notifications.dart"
CARD = ROOT / "lib/features/support/presentation/widgets/reminder_settings_card.dart"
MODEL_TEST = ROOT / "test/notification_readiness_test.dart"
WIDGET_TEST = ROOT / "test/reminder_settings_card_notification_test.dart"

required = [MODEL, SERVICE, CARD, MODEL_TEST, WIDGET_TEST]
missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
if missing:
    print("FAIL BW-NOTIFY-01A missing: " + ", ".join(missing))
    sys.exit(1)

model = MODEL.read_text(encoding="utf-8")
service = SERVICE.read_text(encoding="utf-8")
card = CARD.read_text(encoding="utf-8")
tests = (
    MODEL_TEST.read_text(encoding="utf-8")
    + "\n"
    + WIDGET_TEST.read_text(encoding="utf-8")
)

failed = False

for needle in [
    "enum NotificationPermissionStatus",
    "enum TestNotificationOutcome",
    "class NotificationReadiness",
    "class TestNotificationResult",
    "class TestNotificationCopy",
    "Your test notification is working.",
]:
    if needle not in model:
        print(f"FAIL BW-NOTIFY-01A model missing: {needle}")
        failed = True

for needle in [
    "static const int dailyReminderId = 2201;",
    "static const int riskyNudgeId = 2202;",
    "static const int testNotificationId = 2203;",
    "Future<NotificationReadiness> readReadiness()",
    "Future<TestNotificationResult> sendTestNotification()",
    "areNotificationsEnabled()",
    "PrivacySettingsStore.load()",
    "_showNowWithIconFallback",
    "_plugin.show(",
    "AndroidScheduleMode.inexactAllowWhileIdle",
]:
    if needle not in service:
        print(f"FAIL BW-NOTIFY-01A service missing: {needle}")
        failed = True

for needle in [
    "Notification readiness",
    "Send test notification",
    "A test checks immediate delivery only.",
    "notification-readiness-refresh",
    "notification-test-send",
    "notification-test-status",
    "Last schedule refresh",
]:
    if needle not in card:
        print(f"FAIL BW-NOTIFY-01A card missing: {needle}")
        failed = True

for needle in [
    "test notification uses a dedicated notification id",
    "discreet test notification copy remains neutral",
    "without changing saved settings",
    "notification-test-send",
]:
    if needle not in tests:
        print(f"FAIL BW-NOTIFY-01A tests missing: {needle}")
        failed = True

ids = {
    name: int(value)
    for name, value in re.findall(
        r"static const int (dailyReminderId|riskyNudgeId|testNotificationId) = (\d+);",
        service,
    )
}
if len(ids) != 3 or len(set(ids.values())) != 3:
    print("FAIL BW-NOTIFY-01A notification IDs must be present and distinct.")
    failed = True

send_start = service.find(
    "static Future<TestNotificationResult> sendTestNotification()"
)
send_end = service.find(
    "static Future<void> _showNowWithIconFallback",
    send_start,
)
send_block = service[send_start:send_end]
for forbidden in [
    "ReminderSettingsStore.save",
    "rescheduleAll(",
    "_plugin.cancel",
    "zonedSchedule",
]:
    if forbidden in send_block:
        print(
            "FAIL BW-NOTIFY-01A test notification mutates schedules: "
            + forbidden
        )
        failed = True

# BW-NOTIFY-01A intentionally introduced no exact-alarm scope.
# BW-NOTIFY-01B owns later optional, user-granted precise scheduling,
# so this historical verifier no longer forbids that later-stage capability.

if failed:
    sys.exit(1)

print("PASS: BW-NOTIFY-01A test notification and readiness verified.")
