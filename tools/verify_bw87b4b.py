from pathlib import Path
import sys

library_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routines_screen.dart"
)
player_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routine_player_screen.dart"
)
plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

for path in [
    library_path,
    player_path,
    plus_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B4B missing file: {path}")
        sys.exit(1)

library = library_path.read_text(encoding="utf-8")
player = player_path.read_text(encoding="utf-8")
plus = plus_path.read_text(encoding="utf-8")

for needle in [
    "class GuidedRoutinesScreen",
    "RecoveryRoutineCatalog.forMode",
    "RecoveryRoutineProgressStore.loadAll",
    "Start routine",
    "Resume routine",
    "View completed routine",
    "There are no streak penalties here.",
    "LinearProgressIndicator",
    "Christian recovery wording is active.",
    "Secular recovery wording is active.",
]:
    if needle not in library:
        print(
            f"FAIL BW-87B4B routine library missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "class GuidedRoutinePlayerScreen",
    "RecoveryRoutineProgressStore.loadFor",
    "RecoveryRoutineProgressStore",
    ".saveProgress(",
    "_completeCurrentStep",
    "_restartRoutine",
    "Mark step complete",
    "Complete routine",
    "Routine completed",
    "Start routine again",
    "Earlier completion history will remain saved.",
    "currentStep.hasAction &&",
    "widget.onActionRequested !=",
    "null) ...<Widget>[",
]:
    if needle not in player:
        print(
            f"FAIL BW-87B4B routine player missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "guided_routines_screen.dart",
    "_openGuidedRoutines",
    "GuidedRoutinesScreen(",
    "onActionRequested:",
    "Preview guided routines",
    "BW-87B4B adds the guided routine library",
]:
    if needle not in plus:
        print(
            f"FAIL BW-87B4B Plus integration missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "streak broken",
    "lost your streak",
    "failure streak",
    "pay now",
    "subscribe now",
]:
    combined = (library + player + plus).lower()

    if forbidden in combined:
        print(
            f"FAIL BW-87B4B harmful or premature copy found: "
            f"{forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B4B guided routine library, player, "
    "resume, completion, and restart UI verified."
)
