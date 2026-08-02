from pathlib import Path
import sys

path = Path("lib/features/support/presentation/support_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "key: Key('support-help-now-group')",
    "SupportContactCard",
    "SupportQuickActionsCard",
    "key: Key('support-learn-breakwave-group')",
    "title: 'Learn how BreakWave helps'",
    "CbtInformedSupportCard",
    "ProfessionalHelpCard",
    "SupportCategoriesCard",
    "EducationResourcesCard",
]

failed = False
for needle in checks:
    if needle not in text:
        print(f"FAIL support_screen.dart missing: {needle}")
        failed = True

start = text.find("key: Key('support-learn-breakwave-group')")
end = text.find("key: Key('support-privacy-safety-group')")
if start == -1 or end == -1 or start >= end:
    print("FAIL BW-62A could not locate compact learning group")
    failed = True
else:
    group = text[start:end]
    for needle in [
        "initiallyExpanded: false",
        "CbtInformedSupportCard()",
        "ProfessionalHelpCard()",
    ]:
        if needle not in group:
            print(f"FAIL BW-62A learning group missing: {needle}")
            failed = True

if text.count("CbtInformedSupportCard") != 1:
    print("FAIL CbtInformedSupportCard should appear exactly once")
    failed = True

if text.count("ProfessionalHelpCard") != 1:
    print("FAIL ProfessionalHelpCard should appear exactly once")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-62A CBT foundation placement verified in compact learning group.")
