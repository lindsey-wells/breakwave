from pathlib import Path
import sys

state_path = Path(
    "lib/core/onboarding/onboarding_state.dart"
)

store_path = Path(
    "lib/core/onboarding/onboarding_state_store.dart"
)

gate_path = Path(
    "lib/core/onboarding/onboarding_launch_gate.dart"
)

app_path = Path(
    "lib/app/breakwave_app.dart"
)

test_path = Path(
    "test/onboarding_state_store_test.dart"
)

for path in [
    state_path,
    store_path,
    gate_path,
    app_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P2 missing file: {path}"
        )
        sys.exit(1)

state = state_path.read_text(
    encoding="utf-8"
)

store = store_path.read_text(
    encoding="utf-8"
)

gate = gate_path.read_text(
    encoding="utf-8"
)

app = app_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "enum OnboardingStatus",
    "notStarted",
    "inProgress",
    "completed",
    "skipped",
    "currentSchemaVersion = 1",
    "totalSteps = 10",
    "shouldShowOnboarding",
    "migratedLegacyUser",
    "currentStep",
    "fromMap",
    "toMap",
]:
    if needle not in state:
        print(
            "FAIL BW-87B6P2 state model "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "bw_onboarding_state_v1",
    "legacyEvidenceKeys",
    "bw_recovery_mode_v1",
    "BreakWaveStorageKeys.logEntries",
    "resolveForLaunch",
    "OnboardingState.completed",
    "migratedLegacyUser: true",
    "OnboardingState.initial",
    "Future<OnboardingState> begin",
    "saveProgress",
    "Future<OnboardingState> complete",
    "Future<OnboardingState> skip",
    "Do not persist notStarted",
]:
    if needle not in store:
        print(
            "FAIL BW-87B6P2 state store "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "'bw_premium_state_v1'",
    "'bw_privacy_settings_v1'",
    "in_app_purchase",
    "purchaseStream",
]:
    if forbidden in store:
        print(
            "FAIL BW-87B6P2 unsafe legacy or "
            f"billing marker: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "class OnboardingLaunchGate",
    "_resolvePassiveMigration",
    "resolveForLaunch",
    "return widget.child",
    "must never prevent",
]:
    if needle not in gate:
        print(
            "FAIL BW-87B6P2 launch gate "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "Scaffold(",
    "CircularProgressIndicator",
    "Navigator.",
    "MaterialPageRoute",
    "OnboardingScreen",
]:
    if forbidden in gate:
        print(
            "FAIL BW-87B6P2 passive gate adds "
            f"visible routing: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "onboarding_launch_gate.dart",
    "home: const OnboardingLaunchGate(",
    "child: RecoveryModeGate(",
    "child: BreakWaveShell()",
]:
    if needle not in app:
        print(
            "FAIL BW-87B6P2 active app root "
            f"missing: {needle}"
        )
        sys.exit(1)

gate_index = app.find(
    "home: const OnboardingLaunchGate("
)

mode_index = app.find(
    "child: RecoveryModeGate("
)

shell_index = app.find(
    "child: BreakWaveShell()"
)

if not (
    gate_index >= 0
    and mode_index > gate_index
    and shell_index > mode_index
):
    print(
        "FAIL BW-87B6P2 launch wrapper order "
        "must be onboarding, mode, then shell."
    )
    sys.exit(1)

for needle in [
    "fresh install remains not started without persistence",
    "established recovery-mode user migrates as completed",
    "existing log data also counts as established use",
    "saved in-progress onboarding resumes exact step",
    "active onboarding steps are clamped safely",
    "completed and skipped states are terminal",
    "corrupt saved state falls back to legacy migration",
    "older saved schema upgrades without losing status",
    "technical settings alone do not imply legacy use",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P2 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P2 versioned onboarding "
    "state and passive legacy migration verified."
)
