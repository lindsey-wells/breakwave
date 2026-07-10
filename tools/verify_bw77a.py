from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/support_screen.dart", [
        "Get support before the wave gets stronger.",
    ]),
    ("lib/core/clinical/cbt_recovery_foundation.dart", [
        "change unhelpful thoughts",
        "BreakWave is a support tool.",
        "it is not a replacement for a licensed professional.",
    ]),
    ("lib/features/support/presentation/widgets/professional_help_card.dart", [
        "If you feel like harming yourself or someone else",
        "seek emergency help immediately",
    ]),
    ("lib/features/support/presentation/widgets/privacy_settings_card.dart", [
        "Use neutral notification text so BreakWave does not reveal recovery details on your lock screen.",
        "Prevent screenshots while BreakWave is open",
        "Adds extra privacy by asking Android to block normal screenshots and screen recordings while BreakWave is open.",
        "Save privacy settings",
    ]),
    ("lib/features/support/presentation/widgets/email_app_handoff_card.dart", [
        "Open a prefilled email to",
        "Nothing leaves your device until you tap Send in your email app.",
        "Opened feedback email.",
        "Open email draft",
    ]),
    ("lib/features/support/presentation/widgets/email_capture_settings_card.dart", [
        "Optional. BreakWave works without email.",
        "Optional product interviews, surveys, beta testing, or feedback.",
        "Save email preferences",
    ]),
    ("lib/features/support/presentation/widgets/email_export_card.dart", [
        "Exports stay on your device unless you choose to share them.",
        "Create a CSV or JSON file from saved email-consent data when needed.",
        "Share export bundle",
    ]),
    ("tools/verify_bw05.py", [
        "Get support before the wave gets stronger.",
    ]),
    ("tools/verify_bw06.py", [
        "Get support before the wave gets stronger.",
    ]),
    ("tools/verify_bw42.py", [
        "BreakWave works without email.",
    ]),
    ("tools/verify_bw43.py", [
        "Exports stay on your device unless you choose to share them.",
    ]),
    ("tools/verify_bw70b.py", [
        "Prevent screenshots while BreakWave is open",
    ]),
]

forbidden = [
    "Get support before the wave gets louder.",
    "Manual only.",
    "BreakWave help works without email.",
    "beta feedback.",
    "Block screenshots and screen recording",
    "Use more neutral notification titles and body text.",
    "If you may harm yourself",
    "reframe thoughts",
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
    "lib/features/support/presentation/support_screen.dart",
    "lib/core/clinical/cbt_recovery_foundation.dart",
    "lib/features/support/presentation/widgets/professional_help_card.dart",
    "lib/features/support/presentation/widgets/privacy_settings_card.dart",
    "lib/features/support/presentation/widgets/email_app_handoff_card.dart",
    "lib/features/support/presentation/widgets/email_capture_settings_card.dart",
    "lib/features/support/presentation/widgets/email_export_card.dart",
]:
    text = Path(rel_path).read_text(encoding="utf-8")
    for bad in forbidden:
        if bad in text:
            print(f"FAIL stale trust-copy text remains in {rel_path}: {bad}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-77A Support copy/settings trust polish verified.")
