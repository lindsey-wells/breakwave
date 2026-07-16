from pathlib import Path
import re
import sys

gate_path = Path(
    "lib/core/onboarding/onboarding_launch_gate.dart"
)

flow_path = Path(
    "lib/features/onboarding/presentation/onboarding_flow_screen.dart"
)

loading_path = Path(
    "lib/features/onboarding/presentation/onboarding_launch_loading.dart"
)

rescue_path = Path(
    "lib/features/onboarding/presentation/onboarding_rescue_route.dart"
)

test_path = Path(
    "test/onboarding_launch_gate_test.dart"
)

contract_path = Path(
    "docs/BW_87B6P_ONBOARDING_DATA_CONTRACT.md"
)

for path in [
    gate_path,
    flow_path,
    loading_path,
    rescue_path,
    test_path,
    contract_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P3B1 missing file: {path}"
        )
        sys.exit(1)

gate = gate_path.read_text(
    encoding="utf-8"
)

flow = flow_path.read_text(
    encoding="utf-8"
)

loading = loading_path.read_text(
    encoding="utf-8"
)

rescue = rescue_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

contract = contract_path.read_text(
    encoding="utf-8"
)

semantic_contract = re.sub(
    r"\s+",
    " ",
    contract.replace("`", ""),
).strip()

for needle in [
    "_resolvePassiveMigration",
    "resolveForLaunch",
    "OnboardingStateStore.begin",
    "state.shouldShowOnboarding",
    "OnboardingLaunchLoading",
    "OnboardingFlowScreen",
    "initialStep: _initialStep",
    "return widget.child",
    "must never prevent",
]:
    if needle not in gate:
        print(
            "FAIL BW-87B6P3B1 launch gate "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "Step ${_step + 1}",
    "LinearProgressIndicator",
    "WillPopScope",
    "Skip setup",
    "Skip onboarding",
    "Need help now? Open Rescue",
    "OnboardingStateStore.saveProgress",
    "OnboardingCompletionService",
    "_completionService.complete",
    "_completionService.skip",
    "OnboardingStatus.completed",
    "OnboardingStatus.skipped",
    "Finish setup",
    "Back",
    "Continue",
]:
    if needle not in flow:
        print(
            "FAIL BW-87B6P3B1 flow "
            f"missing: {needle}"
        )
        sys.exit(1)

if flow.count(
    "_OnboardingShellStep("
) < 11:
    print(
        "FAIL BW-87B6P3B1 expected ten "
        "onboarding shell steps."
    )
    sys.exit(1)

for needle in [
    "Need help now? Open Rescue",
    "CircularProgressIndicator",
]:
    if needle not in loading:
        print(
            "FAIL BW-87B6P3B1 launch loading "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "openOnboardingRescue",
    "MaterialPageRoute",
    "RescueScreen",
    "onReturnHome",
    "onOpenSupport",
    "onOpenLog",
    "maybePop",
]:
    if needle not in rescue:
        print(
            "FAIL BW-87B6P3B1 Rescue route "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "PremiumStateStore",
    "setPlusUnlocked",
    "purchaseStream",
    "in_app_purchase",
]:
    combined = gate + flow + loading + rescue

    if forbidden in combined:
        print(
            "FAIL BW-87B6P3B1 billing or "
            f"entitlement behavior found: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "fresh user enters onboarding and begins at step one",
    "established user bypasses onboarding",
    "interrupted user resumes saved step",
    "continue and back persist exact progress",
    "skip exits onboarding without trapping the user",
    "Rescue opens and returns to the same step",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3B1 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "Fresh users enter the versioned onboarding flow",
    "Established users",
    "resumes at its last saved step",
    "Need help now? Open Rescue",
    "Closing Rescue returns the user to the same onboarding step",
    "System Back moves to the previous onboarding step",
    "must never prevent the existing recovery-mode gate",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P3B1 contract "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B1 resumable onboarding "
    "shell and Rescue escape route verified."
)
