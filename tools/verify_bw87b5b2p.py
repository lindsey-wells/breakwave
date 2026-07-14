from pathlib import Path
import re
import sys

catalog_path = Path(
    "lib/features/faith/domain/"
    "christian_recovery_journey_catalog.dart"
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
    catalog_path,
    library_path,
    player_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B5B2P missing file: {path}"
        )
        sys.exit(1)

catalog = catalog_path.read_text(
    encoding="utf-8"
)

library = library_path.read_text(
    encoding="utf-8"
)

player = player_path.read_text(
    encoding="utf-8"
)

expected_phrases = [
    "after a slip, or when condemnation is pushing you toward hiding.",
    "fantasy, bargaining, or repetitive thoughts begin pulling your attention.",
    "isolation or secrecy makes the habit feel easier to protect.",
    "you feel lonely, rejected, bored, or disconnected.",
    "you feel pressure to fix everything at once or prove yourself through perfection.",
    "before bedtime, late-night scrolling, travel, or another predictable risk window.",
]

for phrase in expected_phrases:
    if phrase not in catalog:
        print(
            "FAIL BW-87B5B2P normalized phrase "
            f"missing: {phrase}"
        )
        sys.exit(1)

when_values = re.findall(
    r"whenToUse:\s*'([^']+)'",
    catalog,
)

if len(when_values) != 6:
    print(
        "FAIL BW-87B5B2P expected 6 "
        f"whenToUse values, found {len(when_values)}"
    )
    sys.exit(1)

for value in when_values:
    if value.startswith(
        ("When ", "After ", "Before ")
    ):
        print(
            "FAIL BW-87B5B2P condition is not "
            f"normalized after the label: {value}"
        )
        sys.exit(1)

if "Helpful when: ${journey.whenToUse}" not in library:
    print(
        "FAIL BW-87B5B2P Helpful-when label "
        "missing from library"
    )
    sys.exit(1)

for needle in [
    "'Helpful when: '",
    "widget.journey.whenToUse",
]:
    if needle not in player:
        print(
            "FAIL BW-87B5B2P Helpful-when player "
            f"wiring missing: {needle}"
        )
        sys.exit(1)

combined = catalog + library + player

if "Helpful when: When " in combined:
    print(
        "FAIL BW-87B5B2P duplicate "
        "'Helpful when: When' remains."
    )
    sys.exit(1)

print(
    "PASS: BW-87B5B2P Christian journey "
    "Helpful-when copy polish verified."
)
