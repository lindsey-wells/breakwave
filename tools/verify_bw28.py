from pathlib import Path
import sys

checks = [
    ("lib/features/learn/domain/learning_card_content.dart", [
        "class LearningCardContent",
        "meaning",
        "whyItMatters",
        "nextMove",
    ]),
    ("lib/features/learn/domain/learning_card_pack.dart", [
        "class LearningCardPack",
        "Urges rise and fall",
        "Secrecy strengthens loops",
        "Changing environment matters",
        "Shame makes relapse worse",
        "Interruption beats negotiation",
    ]),
    ("lib/features/learn/presentation/educate_me_screen.dart", [
        "class EducateMeScreen",
        "Educate Me",
        "Learn what the wave is doing",
        "What it means",
        "Why it matters",
        "Next move",
        "PremiumGateTile",
        "Guided learning and routines",
    ]),
    ("lib/features/support/presentation/widgets/educate_me_entry_card.dart", [
        "class EducateMeEntryCard",
        "Educate Me",
        "EducateMeScreen",
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
    if "EducateMeEntryCard" not in support_text:
        print("FAIL lib/features/support/presentation/support_screen.dart missing: EducateMeEntryCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-28 Educate Me learning surface verified.")
