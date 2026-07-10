from pathlib import Path
import sys

support = Path("lib/features/support/presentation/support_screen.dart").read_text(encoding="utf-8")
cbt = Path("lib/features/support/presentation/widgets/cbt_informed_support_card.dart").read_text(encoding="utf-8")
edu = Path("lib/features/support/presentation/widgets/education_resources_card.dart").read_text(encoding="utf-8")
entry = Path("lib/features/support/presentation/widgets/educate_me_entry_card.dart").read_text(encoding="utf-8")

required_support = [
    "Cognitive behavioral tools, not shame",
]

required_cbt = [
    "Notes: BW-86C clarifies CBT as cognitive behavioral tools, not CBD or therapy.",
    "Cognitive behavioral tools",
    "CBT means cognitive behavioral tools.",
    "noticing triggers, thoughts, urges, actions, and consequences",
    "It is not CBD, medication, therapy, a diagnosis, or medical treatment.",
    "Important safety note",
]

required_edu = [
    "Notes: BW-86C removes duplicate Educate Me CTA; dedicated Educate Me card remains.",
    "See how triggers, thoughts, urges, actions, and consequences connect so you can interrupt the cycle earlier.",
    "Open Recovery Cycle Wheel",
]

required_entry = [
    "Notes: BW-86C makes this the single Educate Me entry point on Support.",
    "Educate Me",
    "Open Educate Me",
    "practice a cleaner next step",
]

for needle in required_support:
    if needle not in support:
        print(f"FAIL BW-86C support screen missing: {needle}")
        sys.exit(1)

for needle in required_cbt:
    if needle not in cbt:
        print(f"FAIL BW-86C CBT copy missing: {needle}")
        sys.exit(1)

for needle in required_edu:
    if needle not in edu:
        print(f"FAIL BW-86C education resources missing: {needle}")
        sys.exit(1)

for needle in required_entry:
    if needle not in entry:
        print(f"FAIL BW-86C Educate Me entry missing: {needle}")
        sys.exit(1)

if "Open Educate Me" in edu:
    print("FAIL BW-86C duplicate Open Educate Me button still present in EducationResourcesCard")
    sys.exit(1)

if "EducateMeScreen" in edu:
    print("FAIL BW-86C EducationResourcesCard still directly opens EducateMeScreen")
    sys.exit(1)

if "onPressed: () {}" in support + cbt + edu + entry:
    print("FAIL BW-86C introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-86C Support readiness copy cleanup verified.")
