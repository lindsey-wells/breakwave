from pathlib import Path
import sys

checks = [
    ("lib/core/privacy/privacy_settings.dart", [
        "class PrivacySettings",
        "discreetNotifications",
        "hideHomeInsights",
        "hideLatestLoggedMoment",
        "preferRescueAsSafePath",
        "defaults",
        "copyWith",
    ]),
    ("lib/core/privacy/privacy_settings_store.dart", [
        "class PrivacySettingsStore",
        "bw_privacy_settings_v1",
        "ValueNotifier<int>",
        "changes",
        "load()",
        "save(",
    ]),
    ("lib/features/support/presentation/widgets/privacy_settings_card.dart", [
        "class PrivacySettingsCard",
        "Privacy controls",
        "Discreet notifications",
        "Hide Home insights",
        "Hide latest logged moment",
        "Prefer Rescue as safe visible path",
        "Save privacy settings",
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

support_path = Path("lib/features/support/presentation/support_screen.dart")
if not support_path.exists():
    print("FAIL missing file: lib/features/support/presentation/support_screen.dart")
    failed = True
else:
    support_text = support_path.read_text(encoding="utf-8")
    if "PrivacySettingsCard" not in support_text:
        print("FAIL lib/features/support/presentation/support_screen.dart missing: PrivacySettingsCard")
        failed = True

home_path = Path("lib/features/home/presentation/home_screen.dart")
if not home_path.exists():
    print("FAIL missing file: lib/features/home/presentation/home_screen.dart")
    failed = True
else:
    home_text = home_path.read_text(encoding="utf-8")
    if "PrivacySettingsStore" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: PrivacySettingsStore")
        failed = True

notifications_path = Path("lib/core/reminders/breakwave_notifications.dart")
if not notifications_path.exists():
    print("FAIL missing file: lib/core/reminders/breakwave_notifications.dart")
    failed = True
else:
    notifications_text = notifications_path.read_text(encoding="utf-8")
    if "PrivacySettingsStore.load()" not in notifications_text:
        print("FAIL lib/core/reminders/breakwave_notifications.dart missing: PrivacySettingsStore.load()")
        failed = True
    if "BreakWave check-in" not in notifications_text:
        print("FAIL lib/core/reminders/breakwave_notifications.dart missing: BreakWave check-in")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-24 privacy controls verified.")
