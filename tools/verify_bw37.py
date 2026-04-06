from pathlib import Path
import sys

checks = [
    ("pubspec.yaml", [
        "url_launcher:",
    ]),
    ("lib/core/support/support_contact.dart", [
        "class SupportContact",
        "phoneNumber",
        "emailAddress",
        "String get contactLine => phoneNumber;",
        "hasPhone",
        "hasEmail",
    ]),
    ("lib/core/support/support_contact_actions.dart", [
        "class SupportContactActions",
        "scheme: 'sms'",
        "scheme: 'mailto'",
        "launchUrl(",
        "sendStrugglingText",
        "sendSupportEmail",
    ]),
    ("lib/features/support/presentation/widgets/support_contact_card.dart", [
        "Phone number",
        "Email address",
        "Save trusted contact",
        "Clear trusted contact",
    ]),
    ("lib/features/support/presentation/widgets/support_quick_actions_card.dart", [
        "Text ${_contact!.name}: I’m struggling",
        "Email ${_contact!.name} now",
        "Clipboard.setData",
        "Copy \"I’m struggling\"",
        "Copy \"Please check on me\"",
        "Copy \"Can you call me?\"",
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

for rel_path in [
    "lib/features/rescue/presentation/widgets/redirect_actions_card.dart",
    "lib/features/support/presentation/widgets/emergency_help_card.dart",
    "lib/features/support/presentation/widgets/trusted_accountability_card.dart",
    "lib/features/support/presentation/widgets/education_resources_card.dart",
]:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue
    text = path.read_text(encoding="utf-8")
    if "placeholder" in text.lower():
        print(f"FAIL {rel_path} still contains placeholder copy")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-37 blocker fixes verified.")
