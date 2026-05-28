from pathlib import Path
import sys

checks = [
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "Purpose: Bottom-tab shell for BreakWave.",
        "static const Duration _privacyRelockGracePeriod = Duration(minutes: 2);",
        "DateTime? _privacyLockBackgroundedAt;",
        "state == AppLifecycleState.resumed",
        "_handleAppResumedForPrivacyLock",
        "state == AppLifecycleState.paused",
        "state == AppLifecycleState.detached",
        "awayFor < _privacyRelockGracePeriod",
        "_sessionUnlocked = false;",
    ]),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", [
        "Lock Log & Support keeps Home and Rescue reachable while protecting the most sensitive screens.",
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

# Guard against the old bad behavior.
shell = Path("lib/features/shell/presentation/breakwave_shell.dart").read_text(encoding="utf-8")
if "state == AppLifecycleState.inactive ||" in shell:
    print("FAIL shell still relocks on inactive lifecycle state")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-49A privacy lock grace timer verified.")
