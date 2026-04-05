from pathlib import Path
import sys

checks = [
    ("lib/core/support/support_contact.dart", [
        "class SupportContact",
        "name",
        "contactLine",
        "isComplete",
        "toMap()",
        "fromMap",
    ]),
    ("lib/core/support/support_contact_store.dart", [
        "class SupportContactStore",
        "bw_support_contact_v1",
        "ValueNotifier<int>",
        "changes",
        "loadContact",
        "saveContact",
        "clearContact",
    ]),
    ("lib/features/support/presentation/widgets/support_contact_card.dart", [
        "class SupportContactCard",
        "Trusted contact",
        "Save trusted contact",
        "Clear trusted contact",
        "SupportContactStore.saveContact",
    ]),
    ("lib/features/support/presentation/widgets/support_quick_actions_card.dart", [
        "class SupportQuickActionsCard",
        "Quick actions",
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

support_path = Path("lib/features/support/presentation/support_screen.dart")
if not support_path.exists():
    print("FAIL missing file: lib/features/support/presentation/support_screen.dart")
    failed = True
else:
    support_text = support_path.read_text(encoding="utf-8")
    if "SupportContactCard" not in support_text:
        print("FAIL lib/features/support/presentation/support_screen.dart missing: SupportContactCard")
        failed = True
    if "SupportQuickActionsCard" not in support_text:
        print("FAIL lib/features/support/presentation/support_screen.dart missing: SupportQuickActionsCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-21 support contact and quick actions verified.")
