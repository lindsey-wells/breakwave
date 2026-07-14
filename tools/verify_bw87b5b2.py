from pathlib import Path
import sys

plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

library_path = Path(
    "lib/features/faith/presentation/"
    "christian_journeys_screen.dart"
)

player_path = Path(
    "lib/features/faith/presentation/"
    "christian_journey_player_screen.dart"
)

for path in [
    plus_path,
    library_path,
    player_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B5B2 missing file: {path}"
        )
        sys.exit(1)

plus = plus_path.read_text(
    encoding="utf-8"
)

library = library_path.read_text(
    encoding="utf-8"
)

player = player_path.read_text(
    encoding="utf-8"
)

for needle in [
    "christian_journeys_screen.dart",
    "_openChristianJourneys",
    "const ChristianJourneysScreen()",
    "Preview Christian journeys",
    "Substantial Christian depth",
    "Subscriptions and purchases are not enabled.",
    "No charge can occur from this screen.",
]:
    if needle not in plus:
        print(
            "FAIL BW-87B5B2 Plus integration "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "Christian mode required",
    "RecoveryMode.christian",
    "ChristianRecoveryJourneyCatalog.journeys",
    "Start journey",
    "Resume journey",
    "View completed journey",
]:
    if needle not in library:
        print(
            "FAIL BW-87B5B2 journey library "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "What this journey includes",
    "Journey completed",
    "Start journey again",
    "currentStep.hasAction",
    "widget.onActionRequested !=",
]:
    if needle not in player:
        print(
            "FAIL BW-87B5B2 journey player "
            f"missing: {needle}"
        )
        sys.exit(1)

if "onActionRequested:" in plus[
    plus.find("_openChristianJourneys"):
    plus.find(
        "@override",
        plus.find("_openChristianJourneys"),
    )
]:
    print(
        "FAIL BW-87B5B2 Christian journey actions "
        "must remain unwired until BW-87B5C."
    )
    sys.exit(1)

print(
    "PASS: BW-87B5B2 Christian journey "
    "Plus launch and visible mode gate verified."
)
