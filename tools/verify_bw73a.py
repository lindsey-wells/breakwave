from pathlib import Path
import sys

path = Path("lib/features/support/presentation/support_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "BW-73A declutters Support with collapsible launch-ready groups.",
    "class _SupportGroup extends StatelessWidget",
    "ExpansionTile",
    "initiallyExpanded: true",
    "initiallyExpanded: false",
    "Recovery model",
    "Cognitive behavioral tools, not shame",
    "Understand the recovery approach behind BreakWave before the support tools.",
    "Icons.psychology_alt_outlined",
    "Get help now",
    "Reduce isolation fast",
    "Your recovery setup",
    "Personalize how BreakWave supports you",
    "Privacy and safety",
    "Protect sensitive recovery details",
    "Learn and resources",
    "Understand the pattern and choose next steps",
    "BreakWave Plus",
    "Go deeper than emergency interruption",
    "Contact BreakWave",
    "Send feedback or stay connected",
    "Advanced",
    "Data export tools",
    "EmergencyHelpCard",
    "SupportContactCard",
    "SupportQuickActionsCard",
    "TrustedAccountabilityCard",
    "RecoveryModeSettingsCard",
    "CustomWhySettingsCard",
    "ReminderSettingsCard",
    "PrivacyLockSettingsCard",
    "PrivacySettingsCard",
    "CbtInformedSupportCard",
    "ProfessionalHelpCard",
    "SupportCategoriesCard",
    "EducationResourcesCard",
    "EducateMeEntryCard",
    "_BreakWavePlusPreviewCard",
    "PremiumGateTile",
    "EmailCaptureSettingsCard",
    "EmailAppHandoffCard",
    "BreakWaveContactLinksCard",
    "EmailExportCard",
    "EdgeInsets.fromLTRB(20, 20, 20, 150)",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL {path} missing: {needle}")
        failed = True

order = [
    ("Recovery model", text.find("Recovery model")),
    ("Get help now", text.find("Get help now")),
    ("Your recovery setup", text.find("Your recovery setup")),
    ("BreakWave Plus", text.find("BreakWave Plus")),
    ("Privacy and safety", text.find("Privacy and safety")),
    ("Learn and resources", text.find("Learn and resources")),
    ("Contact BreakWave", text.find("Contact BreakWave")),
    ("Advanced", text.find("Advanced")),
]

for label, index in order:
    if index == -1:
        print(f"FAIL order anchor missing: {label}")
        failed = True

if not failed:
    for (left_label, left_index), (right_label, right_index) in zip(order, order[1:]):
        if left_index > right_index:
            print(f"FAIL order issue: {left_label} should appear before {right_label}")
            failed = True

launch = Path("launch/support_declutter_groups.md")
if not launch.exists():
    print("FAIL missing launch/support_declutter_groups.md")
    failed = True
else:
    launch_text = launch.read_text(encoding="utf-8")
    for needle in [
        "BW-73A Support Declutter Groups",
        "without adding a hamburger menu",
        "urgent support expanded by default",
        "organized harbor",
    ]:
        if needle not in launch_text:
            print(f"FAIL launch/support_declutter_groups.md missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-73A Support declutter groups verified.")
