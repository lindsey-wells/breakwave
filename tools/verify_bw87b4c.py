from pathlib import Path
import sys

shell_path = Path(
    "lib/features/shell/presentation/"
    "breakwave_shell.dart"
)
support_path = Path(
    "lib/features/support/presentation/"
    "support_screen.dart"
)
plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)
library_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routines_screen.dart"
)
player_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routine_player_screen.dart"
)
catalog_path = Path(
    "lib/features/guided_routines/domain/"
    "recovery_routine_catalog.dart"
)

for path in [
    shell_path,
    support_path,
    plus_path,
    library_path,
    player_path,
    catalog_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B4C missing file: {path}")
        sys.exit(1)

shell = shell_path.read_text(encoding="utf-8")
support = support_path.read_text(encoding="utf-8")
plus = plus_path.read_text(encoding="utf-8")
library = library_path.read_text(encoding="utf-8")
player = player_path.read_text(encoding="utf-8")
catalog = catalog_path.read_text(encoding="utf-8")

for needle in [
    "_handleRoutineActionRequested",
    "RoutineActionTarget.rescue",
    "RoutineActionTarget.log",
    "RoutineActionTarget.support",
    "RoutineActionTarget.personalPlan",
    "_onDestinationSelected(1)",
    "_onDestinationSelected(2)",
    "_onDestinationSelected(3)",
    "navigator.popUntil(",
    "route.isFirst",
    "PersonalRecoveryPlanScreen",
    "onRoutineActionRequested:",
]:
    if needle not in shell:
        print(
            f"FAIL BW-87B4C shell navigation missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "final ValueChanged<RoutineActionTarget>?",
    "onRoutineActionRequested",
    "_BreakWavePlusPreviewCard(",
    "BreakWavePlusScreen(",
]:
    if needle not in support:
        print(
            f"FAIL BW-87B4C Support callback missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "final ValueChanged<RoutineActionTarget>?",
    "onRoutineActionRequested",
    "GuidedRoutinesScreen(",
    "onActionRequested:",
]:
    if needle not in plus:
        print(
            f"FAIL BW-87B4C Plus callback missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "onActionRequested: widget.onActionRequested",
]:
    if needle not in library:
        print(
            "FAIL BW-87B4C library does not pass "
            "the callback into the routine player."
        )
        sys.exit(1)

for needle in [
    "currentStep.hasAction &&",
    "widget.onActionRequested !=",
    "_requestAction(",
    "currentStep.actionTarget!",
    "currentStep.actionLabel",
]:
    if needle not in player:
        print(
            f"FAIL BW-87B4C player action UI missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "actionLabel: 'Open Rescue'",
    "actionLabel: 'Open Log'",
    "actionLabel: 'Open Support'",
    "actionLabel: 'Open personal recovery plan'",
]:
    if needle not in catalog:
        print(
            f"FAIL BW-87B4C catalog action missing: "
            f"{needle}"
        )
        sys.exit(1)

if ".completeCurrentStep(" in shell + support + plus:
    print(
        "FAIL BW-87B4C navigation must not falsely "
        "complete a routine step."
    )
    sys.exit(1)

print(
    "PASS: BW-87B4C real Rescue, Log, Support, "
    "and Personal Plan routine actions verified."
)
