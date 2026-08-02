from pathlib import Path
import sys

support = Path(
    "lib/features/support/presentation/support_screen.dart"
).read_text(encoding="utf-8")

cycle = Path(
    "lib/features/support/presentation/widgets/education_resources_card.dart"
).read_text(encoding="utf-8")

educate = Path(
    "lib/features/support/presentation/widgets/educate_me_entry_card.dart"
).read_text(encoding="utf-8")

start = support.find("key: Key('support-learn-breakwave-group')")
end = support.find("key: Key('support-privacy-safety-group')")

if start == -1 or end == -1 or start >= end:
    print("FAIL BW-86C1 could not locate Learn how BreakWave helps group")
    sys.exit(1)

group = support[start:end]
for needle in [
    "initiallyExpanded: false",
    "CbtInformedSupportCard()",
    "ProfessionalHelpCard()",
    "SupportCategoriesCard()",
    "EducationResourcesCard()",
    "EducateMeEntryCard()",
]:
    if needle not in group:
        print(f"FAIL BW-86C1 learning group missing: {needle}")
        sys.exit(1)

for name, text, label, destination in [
    (
        "Recovery Cycle Wheel",
        cycle,
        "Open Recovery Cycle Wheel",
        "RecoveryCycleWheelScreen",
    ),
    (
        "Educate Me",
        educate,
        "Open Educate Me",
        "EducateMeScreen",
    ),
]:
    required = [
        "Container(",
        "SizedBox(",
        "width: double.infinity",
        "FilledButton(",
        label,
        destination,
        "padding: EdgeInsets.symmetric(vertical: 14)",
    ]

    for needle in required:
        if needle not in text:
            print(f"FAIL BW-86C1 {name} card missing: {needle}")
            sys.exit(1)

    if "InkWell(" in text:
        print(f"FAIL BW-86C1 {name} still uses whole-card InkWell")
        sys.exit(1)

print("PASS: BW-86C1 Support learning cards and buttons verified.")
