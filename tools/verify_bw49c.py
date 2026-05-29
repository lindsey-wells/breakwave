from pathlib import Path
import sys

checks = [
    ("lib/core/privacy_lock/privacy_lock_settings.dart", [
        "passcode.length == 6",
    ]),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", [
        "6-digit PIN",
        "maxLength: 6",
        "Enter and confirm a 6-digit PIN.",
        "Set 6-digit PIN",
        "Confirm 6-digit PIN",
    ]),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", [
        "import 'dart:async';",
        "_failedAttemptCooldownThreshold = 10",
        "_failedAttemptCooldownDuration = Duration(minutes: 5)",
        "DateTime? _cooldownUntil",
        "Timer? _cooldownTimer",
        "Too many failed attempts. Try again in 5 minutes.",
        "tries left before cooldown",
        "labelText: '6-digit PIN'",
        "maxLength: 6",
        "onPressed: (_unlocking || _isCoolingDown) ? null : _unlock",
    ]),
    ("tools/verify_bw41.py", [
        "6-digit PIN",
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

# Guard against old 4-digit implementation.
blocked = [
    ("lib/core/privacy_lock/privacy_lock_settings.dart", "passcode.length == 4"),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", "maxLength: 4"),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", "maxLength: 4"),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", "4-digit passcode"),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", "4-digit passcode"),
]

for rel_path, needle in blocked:
    text = Path(rel_path).read_text(encoding="utf-8")
    if needle in text:
        print(f"FAIL {rel_path} still contains old implementation: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-49C 6-digit PIN and failed-attempt cooldown verified.")
