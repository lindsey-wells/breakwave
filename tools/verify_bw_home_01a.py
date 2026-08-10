#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

HOME = ROOT / "lib/features/home/presentation/home_screen.dart"
MODEL = (
    ROOT
    / "lib/features/home/presentation/widgets/home_recovery_model_card.dart"
)
TEST = ROOT / "test/home_recovery_model_card_test.dart"
CONTRACT = ROOT / "docs/BW_HOME_01A_RECOVERY_MODEL_CONTRACT.md"

required_files = [HOME, MODEL, TEST, CONTRACT]
failed = False

for path in required_files:
    if not path.is_file():
        print(
            "FAIL BW-HOME-01A missing: "
            + str(path.relative_to(ROOT))
        )
        failed = True

if failed:
    raise SystemExit(1)

home = HOME.read_text(encoding="utf-8")
model = MODEL.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")
contract = CONTRACT.read_text(encoding="utf-8")


def require(text, needle, label):
    global failed
    if needle not in text:
        print(
            "FAIL BW-HOME-01A "
            + label
            + " missing: "
            + needle
        )
        failed = True


for needle in [
    "BW-HOME-01A makes Rescue visually primary",
    "home_recovery_model_card.dart",
    "home-primary-rescue",
    "FilledButton.icon(",
    "label: const Text('Open Rescue')",
    "Interrupt the wave before momentum takes over.",
    "Then choose one next right action.",
    "const HomeRecoveryModelCard()",
    "eyebrow: 'Your setup'",
    "eyebrow: 'Today'",
    "eyebrow: 'Pattern awareness'",
    "FastUrgeEntryCard(",
    "title: 'Your focus and risk signals'",
    "const ReasonsFocusCard()",
    "const TriggersWatchCard()",
    "title: 'Check in'",
    "const DailyCheckInCard()",
    "BedtimeDangerModeCard(",
    "eyebrow: 'Progress'",
    "title: 'Your recent pattern'",
    "RecoverySnapshotCard(",
    "LatestLoggedMomentCard(",
    "SimpleInsightsCard()",
    "title: 'Learn the pattern'",
    "RecoveryCyclePreviewCard()",
]:
    require(home, needle, "Home")

for historical_label in ["Today", "Pattern awareness"]:
    if historical_label not in home:
        print(
            "FAIL BW-HOME-01A historical Home label missing: "
            + historical_label
        )
        failed = True

rescue_index = home.find("home-primary-rescue")
model_index = home.find("const HomeRecoveryModelCard()")
fast_urge_index = home.find("FastUrgeEntryCard(")
reasons_index = home.find("const ReasonsFocusCard()")
checkin_index = home.find("const DailyCheckInCard()")
bedtime_index = home.find("BedtimeDangerModeCard(")

if not (
    rescue_index != -1
    and model_index != -1
    and fast_urge_index != -1
    and rescue_index < model_index < fast_urge_index
):
    print(
        "FAIL BW-HOME-01A expected primary Rescue, then model card, "
        "then Fast Urge"
    )
    failed = True

if not (
    reasons_index != -1
    and checkin_index != -1
    and bedtime_index != -1
    and reasons_index < checkin_index < bedtime_index
):
    print(
        "FAIL BW-HOME-01A changed protected Home recovery order"
    )
    failed = True

for needle in [
    "home-recovery-model-card",
    "Your recovery",
    "Recognize → Interrupt → Redirect → Reinforce",
    "Notice it → Break it → Choose differently → Strengthen what works",
    "Notice It",
    "Home helps you notice patterns and prepare.",
    "Break It → Choose Differently",
    "Rescue helps you interrupt the wave and choose one next right action.",
    "Strengthen What Works",
    "Your Log helps you remember what helped and learn the pattern.",
    "class _RecoveryModelLink",
]:
    require(model, needle, "model card")

for forbidden in [
    "Upgrade",
    "BreakWave Plus",
    "paywall",
    "You failed",
    "you failed",
    "back to zero",
    "streak reset",
    "remember what worked",
]:
    if forbidden in model:
        print(
            "FAIL BW-HOME-01A model card forbidden language: "
            + forbidden
        )
        failed = True

for needle in [
    "home-recovery-model-card",
    "Recognize → Interrupt → Redirect → Reinforce",
    "Notice it → Break it → Choose differently → Strengthen what works",
    "Notice It",
    "Break It → Choose Differently",
    "Strengthen What Works",
    "remember what helped",
    "find.textContaining('remember what worked'), findsNothing",
    "tester.takeException()",
]:
    require(test, needle, "Flutter test")

for needle in [
    "RECOGNIZE → INTERRUPT → REDIRECT → REINFORCE",
    "Do I need help right now?",
    "Rescue remains the clearest immediate action.",
    "direct **Open Rescue** action",
    "Fast Urge remains available",
    "**Notice It**",
    "**Break It → Choose Differently**",
    "**Strengthen What Works**",
    "what helped",
    "card is orientation, not a curriculum",
    "must not:",
    "gate Rescue behind Plus",
    "does not:",
    "add a new analytics engine",
    "`home_screen.dart` remains unchanged",
]:
    require(contract, needle, "contract")

if failed:
    raise SystemExit(1)

print(
    "PASS: BW-HOME-01A Recovery Model Home Foundation verified."
)
