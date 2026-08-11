#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

STORE = ROOT / "lib/core/education/contextual_first_visit_education.dart"
RESCUE = ROOT / "lib/features/rescue/presentation/rescue_screen.dart"
LOG = ROOT / "lib/features/log/presentation/log_screen.dart"
SUPPORT = ROOT / "lib/features/support/presentation/support_screen.dart"
TEST = ROOT / "test/contextual_first_visit_education_test.dart"
CONTRACT = ROOT / "docs/BW_EDU_01A_CONTEXTUAL_FIRST_VISIT_CONTRACT.md"

failed = False


def require(text, needle, label):
    global failed
    if needle not in text:
        print(
            "FAIL BW-EDU-01A "
            + label
            + " missing: "
            + needle
        )
        failed = True


for path in [STORE, RESCUE, LOG, SUPPORT, TEST, CONTRACT]:
    if not path.is_file():
        print(
            "FAIL BW-EDU-01A missing file: "
            + str(path.relative_to(ROOT))
        )
        failed = True

if failed:
    raise SystemExit(1)

store = STORE.read_text(encoding="utf-8")
rescue = RESCUE.read_text(encoding="utf-8")
log = LOG.read_text(encoding="utf-8")
support = SUPPORT.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")
contract = CONTRACT.read_text(encoding="utf-8")

for needle in [
    "enum BreakWaveEducationSurface",
    "rescue,",
    "log,",
    "support,",
    "bw_contextual_first_visit_dismissed_v1",
    "class BreakWaveContextualEducationStore",
    "static Future<bool> shouldShow",
    "static Future<void> dismiss",
    "class ContextualFirstVisitEducationCard",
    "if (!_visible)",
    "onPressed: _dismiss",
    "child: const Text('Got it')",
]:
    require(store, needle, "education store/widget")

for forbidden in [
    "LogRepository",
    "BreakWaveAccessPolicy",
    "Navigator.",
    "BreakWave Plus",
]:
    if forbidden in store:
        print(
            "FAIL BW-EDU-01A education layer contains forbidden dependency: "
            + forbidden
        )
        failed = True

load_start = store.find("Future<void> _loadVisibility()")
dismiss_start = store.find("Future<void> _dismiss()")
if load_start == -1 or dismiss_start == -1:
    print("FAIL BW-EDU-01A visibility/dismiss methods missing")
    failed = True
else:
    load_body = store[load_start:dismiss_start]
    if "BreakWaveContextualEducationStore.dismiss(" in load_body:
        print("FAIL BW-EDU-01A automatically dismisses on widget load")
        failed = True

for text, label, required in [
    (
        rescue,
        "Rescue",
        [
            "contextual_first_visit_education.dart",
            "BreakWaveEducationSurface.rescue",
            "First visit • Interrupt + Redirect",
            "Use Rescue when the wave is rising",
            "You do not need to ",
            "Log anything before using Rescue.",
            "Rescue Tide",
            "Slow the surge. Ride the wave.",
        ],
    ),
    (
        log,
        "Log",
        [
            "contextual_first_visit_education.dart",
            "BreakWaveEducationSurface.log",
            "First visit • Recognize + Reinforce",
            "Use your Log to make patterns visible",
            "without grading yourself",
            "Pattern Log",
            "Turn blur into something visible.",
        ],
    ),
    (
        support,
        "Support",
        [
            "contextual_first_visit_education.dart",
            "BreakWaveEducationSurface.support",
            "First visit • Redirect",
            "Support is organized by what you need next",
            "Immediate help stays first.",
            "Support Harbor",
            "Find the right support for this moment.",
            "support-help-now-group",
        ],
    ),
]:
    for needle in required:
        require(text, needle, label)

rescue_intensity = rescue.find("UrgeIntensitySection(")
rescue_education = rescue.find("BreakWaveEducationSurface.rescue")
rescue_why = rescue.find("RememberWhyCard(")

if not (
    rescue_intensity != -1
    and rescue_education != -1
    and rescue_why != -1
    and rescue_intensity < rescue_education < rescue_why
):
    print(
        "FAIL BW-EDU-01A Rescue education must appear "
        "after intensity and before Personal Why"
    )
    failed = True

log_intro = log.find("'Pattern Log'")
log_education = log.find("BreakWaveEducationSurface.log")
log_count = log.find("Saved locally on this device:")

if not (
    log_intro != -1
    and log_education != -1
    and log_count != -1
    and log_intro < log_education < log_count
):
    print("FAIL BW-EDU-01A Log education placement mismatch")
    failed = True

support_intro = support.find("'Support Harbor'")
support_education = support.find("BreakWaveEducationSurface.support")
support_first_group = support.find("support-help-now-group")

if not (
    support_intro != -1
    and support_education != -1
    and support_first_group != -1
    and support_intro < support_education < support_first_group
):
    print("FAIL BW-EDU-01A Support education placement mismatch")
    failed = True

for needle in [
    "dismissal persists per surface",
    "building a card never dismisses it automatically",
    "BreakWaveEducationSurface.rescue",
    "BreakWaveEducationSurface.log",
    "BreakWaveEducationSurface.support",
    "contextual-first-visit-got-it-rescue",
    "tester.takeException()",
]:
    require(test, needle, "Flutter test")

for needle in [
    "BW-EDU-01A",
    "Got it",
    "not",
    "marked dismissed merely because its widget is built",
    "after the existing urge-intensity control",
    "is not recovery data",
    "does not change onboarding/tutorial progress",
    "does not change billing, entitlement, or Plus access",
    "automatically mark offscreen tabs dismissed",
]:
    require(contract, needle, "contract")

if failed:
    raise SystemExit(1)

print(
    "PASS: BW-EDU-01A Contextual First-Visit Education Foundation verified."
)
