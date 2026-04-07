from pathlib import Path
import sys

checks = [
    ("lib/core/recovery/recovery_mode_store.dart", [
        "class RecoveryModeStore",
        "bw_recovery_mode_v1",
        "ValueNotifier<int>",
        "changes",
        "saveMode(RecoveryMode mode)",
        "changes.value += 1;",
    ]),
    ("lib/features/support/presentation/widgets/recovery_mode_settings_card.dart", [
        "class RecoveryModeSettingsCard",
        "Recovery mode",
        "Current mode:",
        "Change recovery mode",
        "RecoveryModeScreen(",
        "Recovery mode updated to",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "RecoveryModeSettingsCard",
    ]),
    ("lib/features/rescue/presentation/widgets/rescue_card_engine.dart", [
        "RecoveryModeStore.changes.addListener",
        "RecoveryModeStore.changes.removeListener",
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

print("PASS: BW-38 recovery mode can be changed anytime verified.")
