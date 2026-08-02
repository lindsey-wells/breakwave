from pathlib import Path
import re
import sys

path = Path("lib/features/support/presentation/support_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "BW-73A declutters Support with collapsible launch-ready groups.",
    "BW-SUPPORT-01C creates a compact task-based Support structure.",
    "class _SupportGroup extends StatelessWidget",
    "ExpansionTile",
    "initiallyExpanded: true",
    "initiallyExpanded: false",
    "maintainState: true",
    "dense: true",
    "visualDensity: VisualDensity.compact",
    "Get help now",
    "Set up your recovery",
    "Learn how BreakWave helps",
    "Privacy and safety",
    "Explore BreakWave Plus",
    "About and contact",
    "More tools",
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
    "WhoWeAreCard",
    "EmailCaptureSettingsCard",
    "EmailAppHandoffCard",
    "BreakWaveContactLinksCard",
    "EmailExportCard",
    "EdgeInsets.fromLTRB(16, 16, 16, 150)",
]

failed = False
for needle in checks:
    if needle not in text:
        print(f"FAIL {path} missing: {needle}")
        failed = True

order = [
    "support-help-now-group",
    "support-recovery-setup-group",
    "support-learn-breakwave-group",
    "support-privacy-safety-group",
    "support-plus-group",
    "support-about-contact-group",
    "support-more-tools-group",
]
positions = []
for marker in order:
    index = text.find(marker)
    if index == -1:
        print(f"FAIL order anchor missing: {marker}")
        failed = True
    positions.append(index)

if not failed and positions != sorted(positions):
    print("FAIL BW-73A compact Support groups are out of order")
    failed = True

group_invocations = re.findall(
    r"(?:const\s+)?_SupportGroup\(\s*"
    r"key:\s*(?:const\s+)?Key\('support-[^']+-group'\)",
    text,
)
if len(group_invocations) != 7:
    print(
        "FAIL BW-SUPPORT-01C expected exactly seven "
        f"task-based group invocations, found {len(group_invocations)}"
    )
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

print("PASS: BW-73A Support declutter contract preserved in BW-SUPPORT-01C.")
