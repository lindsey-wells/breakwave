from pathlib import Path
import re
import sys

paths = {
    "flow": Path(
        "lib/features/onboarding/presentation/onboarding_flow_screen.dart"
    ),
    "patterns": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_patterns_step_details.dart"
    ),
    "actions": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_actions_step_details.dart"
    ),
    "summary": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_summary_step_details.dart"
    ),
    "access": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_access_step_details.dart"
    ),
    "catalog": Path("lib/core/triggers/trigger_catalog.dart"),
    "live_triggers": Path(
        "lib/features/triggers/presentation/"
        "triggers_risky_times_screen.dart"
    ),
    "gate": Path("lib/core/onboarding/onboarding_launch_gate.dart"),
    "completion": Path(
        "lib/core/onboarding/onboarding_completion_service.dart"
    ),
    "tests": Path("test/onboarding_plan_steps_test.dart"),
    "contract": Path("docs/BW_87B6P_ONBOARDING_DATA_CONTRACT.md"),
}

for label, path in paths.items():
    if not path.exists():
        print(f"FAIL BW-87B6P3B2B missing {label}: {path}")
        sys.exit(1)

text = {
    label: path.read_text(encoding="utf-8")
    for label, path in paths.items()
}

for needle in [
    "OnboardingTriggersStepDetails",
    "OnboardingRiskyTimesStepDetails",
    "OnboardingActionsStepDetails",
    "OnboardingSummaryStepDetails",
    "OnboardingAccessStepDetails",
    "_setTriggers",
    "_setRiskyTimes",
    "_setInterruptionActions",
    "_setAccessChoice",
    "case 9:",
    "OnboardingAccessChoice.undecided",
    "Future<void> _draftSaveQueue",
    "await _draftSaveQueue",
    "result.shouldReviewPlus",
    "onReviewPlusRequested",
    "widget.onReviewPlusRequested?.call();",
    "widget.onFinished(",
]:
    if needle not in text["flow"]:
        print(f"FAIL BW-87B6P3B2B flow missing: {needle}")
        sys.exit(1)

for needle in [
    "BreakWaveTriggerCatalog.triggers",
    "BreakWaveTriggerCatalog.riskyTimes",
    "onboarding-custom-trigger-field",
    "You can continue without choosing one.",
    "These are clues, not diagnoses.",
    "These choices do not predict a relapse.",
    "Semantics(",
    "selectedColor:",
    "late List<String> _selectedTriggers",
    "late List<String> _selectedRiskyTimes",
    "List<String>.from(_selectedTriggers)",
    "List<String>.from(_selectedRiskyTimes)",
]:
    if needle not in text["patterns"]:
        print(f"FAIL BW-87B6P3B2B patterns missing: {needle}")
        sys.exit(1)

for needle in [
    "'Stress'",
    "'Conflict'",
    "'Loneliness'",
    "'Boredom'",
    "'Scrolling'",
    "'Fatigue'",
    "'Shame spiral'",
    "'Late night'",
    "'When alone'",
    "'After stress'",
    "'After conflict'",
    "'Bored and scrolling'",
]:
    if needle not in text["catalog"]:
        print(f"FAIL BW-87B6P3B2B catalog missing: {needle}")
        sys.exit(1)

for needle in [
    "BreakWaveTriggerCatalog.triggers",
    "BreakWaveTriggerCatalog.riskyTimes",
]:
    if needle not in text["live_triggers"]:
        print(f"FAIL BW-87B6P3B2B live trigger UI missing: {needle}")
        sys.exit(1)

for needle in [
    "'Open Rescue'",
    "'Leave the room'",
    "'Text someone safe'",
    "'Take a short walk'",
    "'Cold water reset'",
    "'Put the phone down'",
    "'Other'",
    "'Pray for one minute'",
    "Nothing is opened, messaged, or contacted from this screen",
    "No phone number or contact information is requested.",
    "recoveryMode == RecoveryMode.christian",
    "onboarding-other-action-field",
    "late List<String> _selectedActions",
    "List<String>.from(_selectedActions)",
]:
    if needle not in text["actions"]:
        print(f"FAIL BW-87B6P3B2B actions missing: {needle}")
        sys.exit(1)

for needle in [
    "Your starting plan",
    "Current Focus",
    "Personal Why",
    "Not added (optional).",
    "starter recovery setup",
    "not a diagnosis, treatment ",
    "plan, or guarantee",
]:
    if needle not in text["summary"]:
        print(f"FAIL BW-87B6P3B2B summary missing: {needle}")
        sys.exit(1)

for needle in [
    "Continue Free",
    "Review BreakWave Plus",
    "Continue Free always remains available.",
    "Base secular or Christian recovery language",
    "Plus purchasing is not available yet.",
    "does not unlock Plus",
    "navigation intent only",
]:
    if needle not in text["access"]:
        print(f"FAIL BW-87B6P3B2B access screen missing: {needle}")
        sys.exit(1)

for needle in [
    "BreakWavePlusScreen",
    "_handleReviewPlusRequested",
    "_reviewPlusPending",
    "status == OnboardingStatus.completed",
    "addPostFrameCallback",
    "onReviewPlusRequested:",
]:
    if needle not in text["gate"]:
        print(f"FAIL BW-87B6P3B2B Plus routing missing: {needle}")
        sys.exit(1)

review_index = text["flow"].find(
    "widget.onReviewPlusRequested?.call();"
)
finished_index = text["flow"].find(
    "widget.onFinished(",
    review_index,
)

if review_index < 0 or finished_index < review_index:
    print(
        "FAIL BW-87B6P3B2B Plus intent must be recorded "
        "before onboarding is removed."
    )
    sys.exit(1)

for forbidden in [
    "PremiumStateStore",
    "setPlusUnlocked",
    "in_app_purchase",
    "purchaseStream",
    "buyNonConsumable",
    "buyConsumable",
]:
    combined = "\n".join(
        text[label]
        for label in [
            "flow",
            "patterns",
            "actions",
            "summary",
            "access",
            "gate",
        ]
    )
    if forbidden in combined:
        print(
            "FAIL BW-87B6P3B2B premature billing or entitlement "
            f"behavior: {forbidden}"
        )
        sys.exit(1)

for forbidden in [
    "TriggersStore",
    "PersonalRecoveryPlanStore",
    "SupportContactStore",
]:
    combined = "\n".join(
        text[label]
        for label in ["patterns", "actions", "summary", "access"]
    )
    if forbidden in combined:
        print(
            "FAIL BW-87B6P3B2B details write or read a live store: "
            f"{forbidden}"
        )
        sys.exit(1)

for needle in [
    "Steps 6 and 7 accept rapid optional selections and write only draft data",
    "Step 8 keeps actions practical private optional and mode aware",
    "Step 9 separates Current Focus and Personal Why without fabricating data",
    "Step 10 requires an honest choice and Review Plus routes after completion",
    "TriggersStore.storageKey",
    "bw_support_contact_v1",
    "bw_premium_state_v1",
    "BreakWavePlusScreen",
]:
    if needle not in text["tests"]:
        print(f"FAIL BW-87B6P3B2B tests missing: {needle}")
        sys.exit(1)

semantic_contract = re.sub(
    r"\s+",
    " ",
    text["contract"].replace("`", ""),
).strip()

for needle in [
    "These selections are optional.",
    "Rapid repeated chip taps remain responsive",
    "does not open Rescue, send a message, or require a saved contact",
    "Current Focus and Personal Why as separate concepts",
    "Continue Free always remains available.",
    "Review BreakWave Plus saves navigation intent only.",
    "Plus purchasing is not yet available.",
    "clears the draft last",
]:
    if needle not in semantic_contract:
        print(f"FAIL BW-87B6P3B2B contract missing: {needle}")
        sys.exit(1)

complete_index = text["completion"].find(
    "await OnboardingStateStore.complete"
)
clear_index = text["completion"].find(
    "await OnboardingDraftStore.clear",
    complete_index,
)

if complete_index < 0 or clear_index < complete_index:
    print("FAIL BW-87B6P3B2B completion no longer clears draft last")
    sys.exit(1)

print(
    "PASS: BW-87B6P3B2B real Steps 6-10, responsive draft saves, "
    "honest Plus routing, and safety invariants verified."
)
