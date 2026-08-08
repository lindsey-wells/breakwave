#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent

SERVICE = ROOT / "lib/core/reminders/breakwave_notifications.dart"
MODEL = ROOT / "lib/core/reminders/notification_reliability.dart"
BRIDGE = ROOT / "lib/core/reminders/android_notification_settings.dart"
CARD = ROOT / "lib/features/support/presentation/widgets/reminder_settings_card.dart"
MAIN = ROOT / "android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt"
MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
MODEL_TEST = ROOT / "test/notification_reliability_test.dart"
WIDGET_TEST = ROOT / "test/reminder_settings_card_reliability_test.dart"

required = [
    SERVICE, MODEL, BRIDGE, CARD, MAIN, MANIFEST, MODEL_TEST, WIDGET_TEST
]
missing = [str(p.relative_to(ROOT)) for p in required if not p.is_file()]
if missing:
    print("FAIL BW-NOTIFY-01B missing: " + ", ".join(missing))
    sys.exit(1)

service = SERVICE.read_text(encoding="utf-8")
model = MODEL.read_text(encoding="utf-8")
bridge = BRIDGE.read_text(encoding="utf-8")
card = CARD.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
manifest = MANIFEST.read_text(encoding="utf-8")
tests = (
    MODEL_TEST.read_text(encoding="utf-8")
    + "\n"
    + WIDGET_TEST.read_text(encoding="utf-8")
)

failed = False

for needle in [
    "enum ScheduledProofOutcome",
    "class ScheduledProofResult",
    "class ScheduledProofCopy",
    "Your scheduled check is ready.",
    "Android may still delay future reminders.",
]:
    if needle not in model:
        print(f"FAIL BW-NOTIFY-01B model missing: {needle}")
        failed = True

for needle in [
    "static const int reliabilityProofId = 2204;",
    "Future<ScheduledProofResult> scheduleReliabilityProof(",
    "Duration delay = const Duration(minutes: 5)",
    "_plugin.cancel(id: reliabilityProofId)",
    "_scheduleOneShotWithIconFallback",
    "AndroidScheduleMode.exactAllowWhileIdle",
    "AndroidScheduleMode.inexactAllowWhileIdle",
    "canScheduleExactNotifications()",
    "requestExactAlarmsPermission()",
]:
    if needle not in service:
        print(f"FAIL BW-NOTIFY-01B service missing: {needle}")
        failed = True

ids = {
    name: int(value)
    for name, value in re.findall(
        r"static const int (dailyReminderId|riskyNudgeId|testNotificationId|reliabilityProofId) = (\d+);",
        service,
    )
}
if len(ids) != 4 or len(set(ids.values())) != 4:
    print("FAIL BW-NOTIFY-01B notification IDs must be present and distinct.")
    failed = True

start = service.find(
    "static Future<ScheduledProofResult> scheduleReliabilityProof("
)
end = service.find(
    "static Future<void> _scheduleOneShotWithIconFallback",
    start,
)
proof_block = service[start:end]
for forbidden in [
    "ReminderSettingsStore.save",
    "dailyReminderId",
    "riskyNudgeId",
    "rescheduleAll(",
]:
    if forbidden in proof_block:
        print(
            "FAIL BW-NOTIFY-01B proof mutates saved reminder schedules: "
            + forbidden
        )
        failed = True

one_shot_start = service.find(
    "static Future<void> _scheduleOneShot(",
)
one_shot_end = service.find(
    "static Future<bool> safeRescheduleAll",
    one_shot_start,
)
one_shot_block = service[one_shot_start:one_shot_end]
if "matchDateTimeComponents" in one_shot_block:
    print("FAIL BW-NOTIFY-01B reliability proof must remain one-shot.")
    failed = True

for needle in [
    "MethodChannel('breakwave/notification_settings')",
    "openNotificationSettings",
    "openAppSettings",
]:
    if needle not in bridge:
        print(f"FAIL BW-NOTIFY-01B Dart settings bridge missing: {needle}")
        failed = True

for needle in [
    "Settings.ACTION_APP_NOTIFICATION_SETTINGS",
    "Settings.EXTRA_APP_PACKAGE",
    "Settings.ACTION_APPLICATION_DETAILS_SETTINGS",
    'NOTIFICATION_SETTINGS_CHANNEL = "breakwave/notification_settings"',
]:
    if needle not in main:
        print(
            f"FAIL BW-NOTIFY-01B Android settings handoff missing: {needle}"
        )
        failed = True

if "android.permission.SCHEDULE_EXACT_ALARM" not in manifest:
    print("FAIL BW-NOTIFY-01B exact alarm special access permission missing.")
    failed = True

for needle in [
    "android.permission.RECEIVE_BOOT_COMPLETED",
    "ScheduledNotificationBootReceiver",
    "android.intent.action.BOOT_COMPLETED",
    "android.intent.action.MY_PACKAGE_REPLACED",
]:
    if needle not in manifest:
        print(
            f"FAIL BW-NOTIFY-01B reboot/update receiver contract missing: {needle}"
        )
        failed = True

for needle in [
    "Scheduled delivery proof",
    "Schedule 5-minute check",
    "notification-proof-schedule",
    "notification-settings-open",
    "app-settings-open",
    "Restart/update proof",
    "Allow precise timing",
    "notification-exact-alarm-request",
    "notification-exact-alarm-status",
]:
    if needle not in card:
        print(f"FAIL BW-NOTIFY-01B card missing: {needle}")
        failed = True

for needle in [
    "scheduled proof copy remains neutral in discreet mode",
    "scheduled proof and Android handoffs do not change saved settings",
    "notification-proof-schedule",
    "notification-settings-open",
    "app-settings-open",
]:
    if needle not in tests:
        print(f"FAIL BW-NOTIFY-01B tests missing: {needle}")
        failed = True

for forbidden in [
    "USE_EXACT_ALARM",
    "REQUEST_IGNORE_BATTERY_OPTIMIZATIONS",
]:
    if forbidden in service + card + model + main + manifest:
        print(
            f"FAIL BW-NOTIFY-01B invasive/exact-alarm scope added: {forbidden}"
        )
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: BW-NOTIFY-01B scheduled reliability and Android settings handoff verified."
)
