#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

files = {
    "visuals": ROOT / (
        "lib/features/log/presentation/widgets/"
        "log_entry_visuals.dart"
    ),
    "selector": ROOT / (
        "lib/features/log/presentation/widgets/"
        "log_entry_type_section.dart"
    ),
    "recent": ROOT / (
        "lib/features/log/presentation/widgets/"
        "recent_log_entries_card.dart"
    ),
    "test": ROOT / "test/log_entry_visual_identity_test.dart",
}

for label, path in files.items():
    if not path.is_file():
        print(f"FAIL BW-LOG-01A missing {label}: {path}")
        sys.exit(1)

visuals = files["visuals"].read_text(encoding="utf-8")
selector = files["selector"].read_text(encoding="utf-8")
recent = files["recent"].read_text(encoding="utf-8")
tests = files["test"].read_text(encoding="utf-8")

for token in [
    "class LogEntryVisualStyle",
    "class LogEntryVisuals",
    "Icons.waves_rounded",
    "Icons.warning_amber_rounded",
    "Icons.emoji_events_rounded",
    "static LogEntryVisualStyle forType",
]:
    if token not in visuals:
        print(f"FAIL BW-LOG-01A visual mapping missing: {token}")
        sys.exit(1)

for token in [
    "log_entry_visuals.dart",
    "log-entry-type-$type",
    "visual.icon",
    "visual.color",
    "selectedColor: visual.backgroundColor",
    "Semantics(",
]:
    if token not in selector:
        print(f"FAIL BW-LOG-01A selector identity missing: {token}")
        sys.exit(1)

for token in [
    "class _EntryTypeBadge",
    "class _IntensityDots",
    "log-entry-badge-",
    "List<Widget>.generate(5",
    "Intensity $safeIntensity",
    "Intensity $safeIntensity out of 5",
    "log-intensity-dot-",
]:
    if token not in recent:
        print(f"FAIL BW-LOG-01A history identity missing: {token}")
        sys.exit(1)

for token in [
    "entry selector gives Urge Slip and Victory distinct icons",
    "recent entry shows a type badge and five intensity dots",
    "log-entry-badge-urge",
    "log-intensity-dot-entry-1-$value-filled",
    "log-intensity-dot-entry-1-$value-empty",
]:
    if token not in tests:
        print(f"FAIL BW-LOG-01A widget test missing: {token}")
        sys.exit(1)

for forbidden in [
    "LogRepository",
    "SharedPreferences",
    "toMap(",
    "fromMap(",
]:
    if forbidden in visuals + selector + recent:
        print(
            "FAIL BW-LOG-01A presentation scope contains "
            f"data behavior: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-LOG-01A visual Log entry identity "
    "is presentation-only and covered."
)
