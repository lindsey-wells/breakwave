from pathlib import Path
import re
import sys

notifications_path = Path(
    "lib/core/reminders/breakwave_notifications.dart"
)
learning_path = Path(
    "lib/features/learn/domain/learning_card_pack.dart"
)
catalog_path = Path(
    "lib/features/guided_routines/domain/"
    "recovery_routine_catalog.dart"
)
library_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routines_screen.dart"
)
player_path = Path(
    "lib/features/guided_routines/presentation/"
    "guided_routine_player_screen.dart"
)

paths = [
    notifications_path,
    learning_path,
    catalog_path,
    library_path,
    player_path,
]

for path in paths:
    if not path.exists():
        print(f"FAIL BW-87B4B1 missing file: {path}")
        sys.exit(1)

notifications = notifications_path.read_text(
    encoding="utf-8"
)
learning = learning_path.read_text(encoding="utf-8")
catalog = catalog_path.read_text(encoding="utf-8")
library = library_path.read_text(encoding="utf-8")
player = player_path.read_text(encoding="utf-8")

for needle in [
    (
        "Pause for 20 seconds. Open BreakWave and "
        "take one steady next step."
    ),
    (
        "Danger window. Pause now. Open BreakWave and "
        "take one steady next step."
    ),
]:
    if needle not in notifications:
        print(
            f"FAIL BW-87B4B1 notification copy missing: "
            f"{needle}"
        )
        sys.exit(1)

if (
    "take one steady next step instead of spiraling."
    not in learning
):
    print(
        "FAIL BW-87B4B1 learning-card copy was not updated."
    )
    sys.exit(1)

for needle in [
    "After waking up or before the day begins",
    "When stress, anger, pressure, or mental overload",
    "When loneliness, rejection, secrecy, or isolation",
    "After risky scrolling, private browsing",
    "Before bed, especially when tiredness",
    "After a slip or when one difficult moment",
]:
    if needle not in catalog:
        print(
            f"FAIL BW-87B4B1 routine timing copy missing: "
            f"{needle}"
        )
        sys.exit(1)

if re.search(
    r"whenToUse:\s*'Use\b",
    catalog,
):
    print(
        "FAIL BW-87B4B1 routine timing still begins "
        "with duplicated Use wording."
    )
    sys.exit(1)

if "Best used: ${routine.whenToUse}" not in library:
    print(
        "FAIL BW-87B4B1 library timing label missing."
    )
    sys.exit(1)

if (
    "Helpful when: ${widget.routine.whenToUse}"
    not in player
):
    print(
        "FAIL BW-87B4B1 player timing label missing."
    )
    sys.exit(1)

combined = (
    notifications
    + learning
    + catalog
    + library
    + player
).lower()

if "clean next step" in combined:
    print(
        "FAIL BW-87B4B1 old moralizing copy remains."
    )
    sys.exit(1)

print(
    "PASS: BW-87B4B1 notification and guided-routine "
    "copy polish verified."
)
