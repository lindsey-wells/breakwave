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

learn_text = Path(
    "lib/features/learn/presentation/educate_me_screen.dart"
).read_text(encoding="utf-8")

for forbidden in [
    "Guided learning and routines",
    "Premium guided learning is part of BreakWave Plus.",
]:
    if forbidden in learn_text:
        print(f"FAIL Educate Me still contains unavailable Plus feature: {forbidden}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-28 Educate Me learning surface verified.")
