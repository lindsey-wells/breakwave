#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

required = {
    "lib/features/support/presentation/support_screen.dart": [
        "BW-SUPPORT-01B puts immediate support first",
        "eyebrow: 'Get help now'",
        "initiallyExpanded: true",
        "Immediate-danger guidance",
        "EmergencyHelpCard()",
        "SupportContactCard()",
        "SupportQuickActionsCard()",
    ],
    "lib/features/support/presentation/widgets/emergency_help_card.dart": [
        "Immediate danger",
        "Call 911 (U.S.)",
        "In the United States, this button calls 911.",
        "Outside the United States, use your local emergency number.",
        "not an immediate emergency",
    ],
    "lib/features/support/presentation/widgets/support_quick_actions_card.dart": [
        "phone saved",
        "email saved",
        "Ready for ${_contact!.name}",
    ],
    "lib/features/support/presentation/widgets/support_contact_card.dart": [
        "wave starts getting stronger",
    ],
    "lib/features/support/presentation/widgets/professional_help_card.dart": [
        "ExpansionTile(",
        "When to seek professional help",
        "seek emergency help immediately",
    ],
    "lib/features/support/presentation/widgets/cbt_informed_support_card.dart": [
        "ExpansionTile(",
        "CBT means cognitive behavioral tools.",
        "Important safety note",
    ],
    "test/support_clarity_safety_test.dart": [
        "emergency guidance clearly labels U.S. 911",
        "professional-help guidance opens independently",
        "CBT detail is progressively disclosed",
    ],
}

failed = False
for rel, needles in required.items():
    path = ROOT / rel
    if not path.is_file():
        print(f"FAIL BW-SUPPORT-01B missing file: {rel}")
        failed = True
        continue
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-SUPPORT-01B {rel} missing: {needle}")
            failed = True

support = (ROOT / "lib/features/support/presentation/support_screen.dart").read_text(encoding="utf-8")
if support.find("eyebrow: 'Get help now'") > support.find("eyebrow: 'Recovery model'"):
    print("FAIL BW-SUPPORT-01B immediate support is not first")
    failed = True

emergency = (ROOT / "lib/features/support/presentation/widgets/emergency_help_card.dart").read_text(encoding="utf-8")
for blocked in [
    "SupportContactStore",
    "Text trusted contact now",
    "Email trusted contact now",
]:
    if blocked in emergency:
        print(f"FAIL BW-SUPPORT-01B duplicate trusted-contact action remains: {blocked}")
        failed = True

quick = (ROOT / "lib/features/support/presentation/widgets/support_quick_actions_card.dart").read_text(encoding="utf-8")
for exposed in ["_contact!.phoneNumber", "_contact!.emailAddress"]:
    if exposed in quick:
        print(f"FAIL BW-SUPPORT-01B exposed contact detail remains: {exposed}")
        failed = True

contact = (ROOT / "lib/features/support/presentation/widgets/support_contact_card.dart").read_text(encoding="utf-8")
if "wave starts getting louder" in contact:
    print("FAIL BW-SUPPORT-01B stale louder terminology remains")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-SUPPORT-01B immediate-support clarity verified.")
