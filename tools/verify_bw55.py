from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/support_screen.dart", [
        "Purpose: BW-55 grouped Support tab cleanup.",
        "Get help now",
        "Your recovery setup",
        "BreakWave Plus",
        "Privacy and safety",
        "Learn and resources",
        "Contact BreakWave",
        "Advanced",
        "Data export tools",
        "BreakWavePlusScreen",
        "_BreakWavePlusPreviewCard",
        "Preview Plus roadmap",
        "SupportContactCard",
        "SupportQuickActionsCard",
        "EmergencyHelpCard",
        "RecoveryModeSettingsCard",
        "CustomWhySettingsCard",
        "PrivacyLockSettingsCard",
        "EmailExportCard",
    ]),
    ("lib/features/rescue/presentation/widgets/support_escalation_card.dart", [
        "Open Support",
    ]),
    ("lib/features/support/presentation/widgets/email_app_handoff_card.dart", [
        "Send feedback to BreakWave",
        "BreakWave recipient email",
        "Nothing leaves your device until you tap Send in your email app.",
        "Save recipient email",
        "Use default email",
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

blocked = [
    ("lib/features/rescue/presentation/widgets/support_escalation_card.dart", "Support tools expanding soon"),
    ("lib/features/support/presentation/widgets/email_app_handoff_card.dart", "BreakWave team email override"),
]

for rel_path, needle in blocked:
    text = Path(rel_path).read_text(encoding="utf-8")
    if needle in text:
        print(f"FAIL {rel_path} still contains old copy: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-55 Support grouping and cleanup verified.")
