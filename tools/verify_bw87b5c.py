from pathlib import Path
import sys

plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

shell_path = Path(
    "lib/features/shell/presentation/"
    "breakwave_shell.dart"
)

library_path = Path(
    "lib/features/faith/presentation/"
    "christian_journeys_screen.dart"
)

player_path = Path(
    "lib/features/faith/presentation/"
    "christian_journey_player_screen.dart"
)

catalog_path = Path(
    "lib/features/faith/domain/"
    "christian_recovery_journey_catalog.dart"
)

for path in [
    plus_path,
    shell_path,
    library_path,
    player_path,
    catalog_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B5C missing file: {path}"
        )
        sys.exit(1)

plus = plus_path.read_text(
    encoding="utf-8"
)

shell = shell_path.read_text(
    encoding="utf-8"
)

library = library_path.read_text(
    encoding="utf-8"
)

player = player_path.read_text(
    encoding="utf-8"
)

catalog = catalog_path.read_text(
    encoding="utf-8"
)

for needle in [
    "christian_recovery_journey.dart",
    "_handleChristianJourneyActionRequested",
    "ChristianJourneyActionTarget.rescue",
    "ChristianJourneyActionTarget.personalPlan",
    "handler(RoutineActionTarget.rescue)",
    "handler(RoutineActionTarget.personalPlan)",
    "ChristianJourneysScreen(",
    "onActionRequested:",
    "onRoutineActionRequested == null",
    "_handleChristianJourneyActionRequested",
]:
    if needle not in plus:
        print(
            "FAIL BW-87B5C Plus action mapping "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "_handleRoutineActionRequested",
    "RoutineActionTarget.rescue",
    "navigator.popUntil(",
    "route.isFirst",
    "_onDestinationSelected(1)",
    "RoutineActionTarget.personalPlan",
    "PersonalRecoveryPlanScreen",
]:
    if needle not in shell:
        print(
            "FAIL BW-87B5C shell destination "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "onActionRequested: widget.onActionRequested",
]:
    if needle not in library:
        print(
            "FAIL BW-87B5C journey library does not "
            "pass the action callback to the player."
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
            "FAIL BW-87B5C journey player action "
            f"UI missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "actionLabel: 'Open Rescue'",
    "actionLabel: 'Open personal recovery plan'",
]:
    if needle not in catalog:
        print(
            "FAIL BW-87B5C catalog action "
            f"missing: {needle}"
        )
        sys.exit(1)

handler_start = plus.find(
    "_handleChristianJourneyActionRequested"
)

handler_end = plus.find(
    "@override",
    handler_start,
)

handler_slice = plus[
    handler_start:handler_end
]

if ".completeCurrentStep(" in handler_slice:
    print(
        "FAIL BW-87B5C opening an action must not "
        "automatically complete the journey step."
    )
    sys.exit(1)

if (
    "onRoutineActionRequested == null"
    not in plus
):
    print(
        "FAIL BW-87B5C action buttons could become "
        "dead when shell navigation is unavailable."
    )
    sys.exit(1)

print(
    "PASS: BW-87B5C Christian journey Rescue "
    "and Personal Plan navigation verified."
)
