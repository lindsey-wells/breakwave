from pathlib import Path
import sys

checks = [
    ("lib/core/privacy_lock/privacy_lock_mode.dart", [
        "enum PrivacyLockMode",
        "none",
        "fullApp",
        "sensitiveSections",
        "Lock full app",
        "Lock sensitive sections",
    ]),
    ("lib/core/privacy_lock/privacy_lock_settings.dart", [
        "class PrivacyLockSettings",
        "mode",
        "passcode",
        "isEnabled",
    ]),
    ("lib/core/privacy_lock/privacy_lock_store.dart", [
        "class PrivacyLockStore",
        "bw_privacy_lock_v1",
        "ValueNotifier<int>",
        "changes",
        "save(PrivacyLockSettings settings)",
    ]),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", [
        "class PrivacyUnlockScreen",
        "Privacy lock",
        "4-digit passcode",
        "Unlock",
    ]),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", [
        "class PrivacyLockSettingsCard",
        "Privacy lock",
        "Set 4-digit passcode",
        "Confirm 4-digit passcode",
        "Save privacy lock",
        "Clear privacy lock",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "PrivacyLockSettingsCard",
    ]),
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "PrivacyLockStore",
        "PrivacyUnlockScreen",
        "_lockSettings",
        "_sessionUnlocked",
        "didChangeAppLifecycleState",
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

print("PASS: BW-41 privacy lock mode verified.")
