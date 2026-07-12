from pathlib import Path
import sys

screen_path = Path("lib/features/learn/presentation/educate_me_screen.dart")
text = screen_path.read_text(encoding="utf-8")

checks = [
    "BW-77B replaces wrapping lesson chips with stable full-width lesson rows.",
    "class _LessonSelectorList extends StatelessWidget",
    "class _LessonSelectorTile extends StatelessWidget",
    "width: double.infinity",
    "Icons.check_circle_outline",
    "Icons.radio_button_unchecked",
    "ValueChanged<int> onSelected",
    "onTap: () => onSelected(index)",
    "LearningCardPack.starter[index].title",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL educate_me_screen.dart missing: {needle}")
        failed = True

for forbidden in [
    "ChoiceChip(",
    "Wrap(",
]:
    if forbidden in text:
        print(f"FAIL Educate Me still uses unstable lesson selector layout: {forbidden}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-77B Educate Me lesson selector layout stability verified.")
