from pathlib import Path
import sys

checks = [
    ("lib/core/recovery/recovery_mode.dart", [
        "enum RecoveryMode",
        "secular",
        "christian",
        "fromStorage",
    ]),
    ("lib/core/recovery/recovery_mode_store.dart", [
        "class RecoveryModeStore",
        "bw_recovery_mode",
        "SharedPreferences",
        "saveMode",
        "loadMode",
    ]),
    ("lib/core/recovery/recovery_mode_gate.dart", [
        "class RecoveryModeGate",
        "RecoveryModeScreen",
        "loadMode",
    ]),
    ("lib/features/recovery_mode/recovery_mode_screen.dart", [
        "class RecoveryModeScreen",
        "Choose your recovery mode",
        "Secular recovery path",
        "Christian recovery path",
        "Continue",
    ]),
    ("lib/app/breakwave_app.dart", [
        "RecoveryModeGate",
        "BreakWaveShell",
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

print("BW-11 verify passed.")
