from pathlib import Path
import sys

path = Path(
    "lib/features/faith/presentation/"
    "christian_journey_player_screen.dart"
)

if not path.exists():
    print(
        f"FAIL BW-87B5C1 missing file: {path}"
    )
    sys.exit(1)

text = path.read_text(encoding="utf-8")

start = text.find(
    "class _PathRow extends StatelessWidget"
)

end = text.find(
    "class _PlayerSurface",
    start,
)

if start == -1 or end == -1:
    print(
        "FAIL BW-87B5C1 could not isolate _PathRow"
    )
    sys.exit(1)

path_row = text[start:end]

for needle in [
    "final Color foreground =",
    "colors.onPrimaryContainer",
    "colors.onSecondaryContainer",
    "colors.onSurfaceVariant",
    "color: colors.onSurface",
    "color: foreground",
    "Text(\n                  kindLabel,",
]:
    if needle not in path_row:
        print(
            "FAIL BW-87B5C1 PathRow contrast "
            f"missing: {needle}"
        )
        sys.exit(1)

if path_row.count("color: foreground") < 2:
    print(
        "FAIL BW-87B5C1 both title and step kind "
        "must use the semantic foreground color."
    )
    sys.exit(1)

if (
    "isCurrent\n"
    "                ? colors.secondaryContainer"
    not in path_row
):
    print(
        "FAIL BW-87B5C1 current-step background "
        "mapping disappeared."
    )
    sys.exit(1)

print(
    "PASS: BW-87B5C1 Journey Path semantic "
    "foreground contrast verified."
)
