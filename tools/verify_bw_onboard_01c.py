#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "lib/features/tutorial/domain/breakwave_tutorial_step.dart"
SCREEN = ROOT / "lib/features/tutorial/presentation/teach_me_breakwave_screen.dart"
PRACTICE = ROOT / "lib/features/tutorial/presentation/practice_rescue_screen.dart"
SCREEN_TEST = ROOT / "test/teach_me_breakwave_screen_test.dart"
PRACTICE_TEST = ROOT / "test/practice_rescue_screen_test.dart"
CONTRACT = ROOT / "docs/BW_ONBOARD_01C_RECOVERY_MODEL_CONTRACT.md"

required = [CATALOG, SCREEN, PRACTICE, SCREEN_TEST, PRACTICE_TEST, CONTRACT]
failed = False

for path in required:
    if not path.is_file():
        print("FAIL BW-ONBOARD-01C missing: " + str(path.relative_to(ROOT)))
        failed = True

if failed:
    raise SystemExit(1)

catalog = CATALOG.read_text(encoding="utf-8")
screen = SCREEN.read_text(encoding="utf-8")
practice = PRACTICE.read_text(encoding="utf-8")
screen_test = SCREEN_TEST.read_text(encoding="utf-8")
practice_test = PRACTICE_TEST.read_text(encoding="utf-8")
contract = CONTRACT.read_text(encoding="utf-8")


def require(text, needle, label):
    global failed
    if needle not in text:
        print("FAIL BW-ONBOARD-01C " + label + " missing: " + needle)
        failed = True


for needle in [
    "Recognize → Interrupt → Redirect → Reinforce",
    "Notice it → Break it → Choose differently → Strengthen what works",
    "BreakWave helps you change what happens when an urge appears.",
    "Interrupt the pattern before momentum takes over.",
    "The private Log helps you recognize patterns",
    "Plus candidates:",
    "Rescue remains available regardless of onboarding or Plus status.",
]:
    require(catalog, needle, "catalog")

if catalog.count("topic: BreakWaveTutorialTopic.") != 6:
    print("FAIL BW-ONBOARD-01C tutorial must preserve exactly six sections")
    failed = True

for needle in [
    "teach-me-breakwave-recovery-model",
    "How BreakWave helps change what happens next",
    "Recognize → Interrupt → Redirect → Reinforce",
    "Notice it → Break it → Choose differently → Strengthen what works",
    "teach-me-breakwave-practice-rescue",
    "PracticeRescueScreen",
]:
    require(screen, needle, "Teach Me screen")

for needle in [
    "Practice Rescue — No Save",
    "PRACTICE MODE",
    "practice-rescue-recovery-model",
    "Recognize • Practice step 1",
    "Interrupt • Practice step 2",
    "Interrupt • Practice step 3",
    "Redirect • Practice step 4",
    "'Reinforce'",
    "response worth practicing",
    "No Log entry, insight, streak, plan, Personal Why, message, call, or emergency action",
    "Practice only. No message was opened.",
]:
    require(practice, needle, "Practice Rescue")

for forbidden in [
    "LogRepository",
    "saveEntry",
    "SupportContactActions",
    "launchUrl",
    "EmergencyHelpCard",
    "CustomWhyStore.save",
    "BreakWaveTutorialStateStore.saveProgress",
    "OnboardingStateStore",
    "PremiumStateStore",
]:
    if forbidden in practice:
        print(
            "FAIL BW-ONBOARD-01C Practice Rescue side effect dependency: "
            + forbidden
        )
        failed = True

for forbidden in [
    "You failed",
    "you failed",
    "back to zero",
    "streak reset",
    "Upgrade to continue",
]:
    if forbidden in "\n".join([catalog, screen, practice]):
        print("FAIL BW-ONBOARD-01C shame/paywall language: " + forbidden)
        failed = True

for needle in [
    "teach-me-breakwave-recovery-model",
    "Recognize → Interrupt → Redirect → Reinforce",
    "Notice it → Break it → Choose differently → Strengthen what works",
]:
    require(screen_test, needle, "Teach Me test")

for needle in [
    "practice-rescue-recovery-model",
    "Recognize • Practice step 1",
    "Redirect • Practice step 4",
    "response worth practicing",
]:
    require(practice_test, needle, "Practice Rescue test")

for needle in [
    "RECOGNIZE → INTERRUPT → REDIRECT → REINFORCE",
    "behavioral spine",
    "not four new",
    "Rescue remains immediately available",
    "Practice remains clearly labeled",
    "Core recovery remains genuinely useful without Plus",
    "How does this screen help the user Recognize, Interrupt, Redirect, or",
]:
    require(contract, needle, "contract")

if failed:
    raise SystemExit(1)

print("PASS: BW-ONBOARD-01C recovery model tutorial integration verified.")
