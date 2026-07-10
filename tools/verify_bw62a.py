from pathlib import Path
import sys

path = Path("lib/features/support/presentation/support_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "eyebrow: 'Recovery model'",
    "title: 'Cognitive behavioral tools, not shame'",
    "CbtInformedSupportCard",
    "ProfessionalHelpCard",
    "eyebrow: 'Get help now'",
    "SupportContactCard",
    "eyebrow: 'Learn and resources'",
    "SupportCategoriesCard",
    "EducationResourcesCard",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL support_screen.dart missing: {needle}")
        failed = True

order = [
    "Support Harbor",
    "eyebrow: 'Recovery model'",
    "CbtInformedSupportCard",
    "ProfessionalHelpCard",
    "eyebrow: 'Get help now'",
    "SupportContactCard",
    "eyebrow: 'Your recovery setup'",
    "eyebrow: 'BreakWave Plus'",
    "eyebrow: 'Privacy and safety'",
    "eyebrow: 'Learn and resources'",
    "eyebrow: 'Contact BreakWave'",
    "eyebrow: 'Advanced'",
]

positions = {}
for marker in order:
    index = text.find(marker)
    if index == -1:
        print(f"FAIL missing order marker: {marker}")
        failed = True
    else:
        positions[marker] = index

if len(positions) == len(order):
    for before, after in zip(order, order[1:]):
        if positions[before] >= positions[after]:
            print(f"FAIL order issue: {before} should appear before {after}")
            failed = True

if text.count("CbtInformedSupportCard") != 1:
    print("FAIL CbtInformedSupportCard should appear exactly once")
    failed = True

if text.count("ProfessionalHelpCard") != 1:
    print("FAIL ProfessionalHelpCard should appear exactly once")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-62A CBT foundation placement verified.")
