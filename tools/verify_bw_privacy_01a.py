#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

required = {
    "lib/core/support/support_contact_masking.dart": [
        "class SupportContactMasking",
        "static String phone",
        "static String email",
        "hiddenDigits",
        "maskedLocal",
    ],
    "lib/features/support/presentation/widgets/trusted_accountability_card.dart": [
        "BW-PRIVACY-01A masks trusted contact details by default",
        "SupportContactMasking.phone",
        "SupportContactMasking.email",
        "trusted-contact-detail-toggle",
        "Show details",
        "Hide details",
        "Contact details are masked here",
        "Support actions still use the saved information",
        "SupportContactActions.sendCheckOnMeText(contact)",
        "SupportContactActions.sendSupportEmail(contact)",
    ],
    "test/trusted_contact_masking_test.dart": [
        "phone masking preserves formatting",
        "email masking hides the local part",
        "trusted contact details are masked until deliberately revealed",
        "Phone: (•••) •••-1212",
        "Email: a•••@example.com",
        "Text trusted contact",
        "Email trusted contact",
    ],
}

failed = False
for relative_path, needles in required.items():
    path = ROOT / relative_path
    if not path.is_file():
        print(f"FAIL BW-PRIVACY-01A missing file: {relative_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(
                f"FAIL BW-PRIVACY-01A {relative_path} missing: {needle}"
            )
            failed = True

card = (
    ROOT
    / "lib/features/support/presentation/widgets/trusted_accountability_card.dart"
).read_text(encoding="utf-8")

for exposed in [
    "'Phone: ${contact.phoneNumber}'",
    "'Email: ${contact.emailAddress}'",
]:
    if exposed in card:
        print(
            "FAIL BW-PRIVACY-01A unconditionally exposed detail remains: "
            f"{exposed}"
        )
        failed = True

actions = (
    ROOT / "lib/core/support/support_contact_actions.dart"
).read_text(encoding="utf-8")
for required_action_value in [
    "phoneNumber: contact.phoneNumber",
    "emailAddress: contact.emailAddress",
]:
    if required_action_value not in actions:
        print(
            "FAIL BW-PRIVACY-01A direct contact action lost saved detail: "
            f"{required_action_value}"
        )
        failed = True

edit_card = (
    ROOT
    / "lib/features/support/presentation/widgets/support_contact_card.dart"
).read_text(encoding="utf-8")
for editing_contract in [
    "_phoneController.text = contact?.phoneNumber ?? ''",
    "_emailController.text = contact?.emailAddress ?? ''",
    "Save trusted contact",
    "Clear trusted contact",
]:
    if editing_contract not in edit_card:
        print(
            "FAIL BW-PRIVACY-01A editing contract changed unexpectedly: "
            f"{editing_contract}"
        )
        failed = True

quick_actions = (
    ROOT
    / "lib/features/support/presentation/widgets/support_quick_actions_card.dart"
).read_text(encoding="utf-8")
for exposed in ["_contact!.phoneNumber", "_contact!.emailAddress"]:
    if exposed in quick_actions:
        print(
            "FAIL BW-PRIVACY-01A quick actions expose detail: "
            f"{exposed}"
        )
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: BW-PRIVACY-01A trusted-contact masking and action preservation verified."
)
