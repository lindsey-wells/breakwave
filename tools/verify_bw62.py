from pathlib import Path
import sys

checks = [
    ("lib/core/clinical/cbt_recovery_foundation.dart", [
        "class CbtRecoveryFoundation",
        "CBT-informed recovery tools",
        "Trigger → Thought → Urge → Action → Consequence → Better Plan",
        "interrupt urges, understand your triggers",
        "does not provide therapy, diagnosis, medical advice, emergency care, or a cure",
        "replacing porn with another harmful habit",
        "seekProfessionalHelpSignals",
    ]),
    ("lib/features/support/presentation/widgets/cbt_informed_support_card.dart", [
        "class CbtInformedSupportCard",
        "CBT-informed recovery",
        "CbtRecoveryFoundation.safeDescription",
        "CbtRecoveryFoundation.coreLoop",
        "CbtRecoveryFoundation.replacementHabitWarning",
        "CbtRecoveryFoundation.notTherapyDisclaimer",
    ]),
    ("lib/features/support/presentation/widgets/professional_help_card.dart", [
        "class ProfessionalHelpCard",
        "When to seek professional help",
        "qualified professional",
        "local emergency resource",
        "seekProfessionalHelpSignals",
        "local emergency services",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "CbtInformedSupportCard",
        "ProfessionalHelpCard",
        "Learn and resources",
    ]),
    ("launch/cbt_informed_recovery_foundation.md", [
        "CBT-Informed Recovery Foundation v1",
        "Safe product description",
        "User-facing promise",
        "Trigger → Thought → Urge → Action → Consequence → Better Plan",
        "not a replacement for therapy",
        "Free versus Plus direction",
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

blocked_claims = [
    "cure addiction",
    "provides therapy",
    "replaces therapy",
]

for rel_path in [
    "lib/core/clinical/cbt_recovery_foundation.dart",
    "launch/cbt_informed_recovery_foundation.md",
]:
    text = Path(rel_path).read_text(encoding="utf-8").lower()
    for claim in blocked_claims:
        if claim in text:
            print(f"FAIL unsafe claim found in {rel_path}: {claim}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-62 CBT-informed recovery foundation verified.")
