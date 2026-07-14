from pathlib import Path
import sys

library_path = Path(
    "lib/features/faith/presentation/"
    "christian_journeys_screen.dart"
)

player_path = Path(
    "lib/features/faith/presentation/"
    "christian_journey_player_screen.dart"
)

for path in [
    library_path,
    player_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B5B1 missing file: {path}"
        )
        sys.exit(1)

library = library_path.read_text(
    encoding="utf-8"
)

player = player_path.read_text(
    encoding="utf-8"
)

for needle in [
    "class ChristianJourneysScreen",
    "RecoveryMode.christian",
    "Christian mode required",
    "ChristianRecoveryJourneyCatalog.journeys",
    "ChristianRecoveryJourneyCatalog.contentNote",
    "ChristianJourneyProgressStore.loadAll",
    "Start journey",
    "Resume journey",
    "View completed journey",
    "There are no streak penalties here.",
    "onActionRequested:",
]:
    if needle not in library:
        print(
            "FAIL BW-87B5B1 library missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "class ChristianJourneyPlayerScreen",
    ".loadFor(",
    "ChristianJourneyProgressStore",
    ".saveProgress(",
    "Journey started.",
    "Step completed. Your progress is saved.",
    "Journey completed",
    "Start journey again",
    "Earlier completion history will remain saved.",
    "Scripture",
    "Context",
    "Reflection",
    "Action",
    "Prayer",
    "scriptureReference",
    "currentStep.hasAction",
    "widget.onActionRequested !=",
    "Complete journey",
]:
    if needle not in player:
        print(
            "FAIL BW-87B5B1 player missing: "
            f"{needle}"
        )
        sys.exit(1)

if player.count(".toInt();") < 2:
    print(
        "FAIL BW-87B5B1 safe integer clamp "
        "conversions are missing."
    )
    sys.exit(1)

combined = (library + player).lower()

for forbidden in [
    "streak broken",
    "you failed god",
    "a real christian would",
    "guaranteed freedom",
    "professional help is unnecessary",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B5B1 unsafe or shaming "
            f"wording found: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B5B1 Christian journey library, "
    "mode gate, player, resume, completion, and "
    "restart UI verified."
)
