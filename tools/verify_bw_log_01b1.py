#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

checks = {
    "lib/features/log/domain/log_entry.dart": [
        "BW-LOG-01B1 allows Reflection entries without intensity.",
        "static const String reflectionEntryType = 'Reflection';",
        "final int? intensity;",
        "const LogEntry.reflection({",
        "bool get isReflection",
        "bool get hasIntensity => intensity != null;",
        "static int? _nullableIntValue(",
        "(isReflection",
        "? null",
        "'intensity': intensity",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "_intensity = entry.intensity ?? 3;",
    ],
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart": [
        "if (entry.intensity != null)",
        "intensity: entry.intensity!,",
        "class _IntensityDots",
    ],
    "lib/features/home/presentation/widgets/latest_logged_moment_card.dart": [
        "if (latest.intensity != null) ...<Widget>[",
        "'Intensity ${latest.intensity}'",
    ],
    "lib/features/insights/presentation/simple_insights_card.dart": [
        "int intensityEntryCount = 0;",
        "final int? intensity = entry.intensity;",
        "intensityEntryCount += 1;",
        "intensityEntryCount == 0",
        "totalIntensity / intensityEntryCount",
    ],
    "lib/features/insights/domain/recovery_insights_calculator.dart": [
        "int intensityEntryCount = 0;",
        "final int? intensity = item.entry.intensity;",
        "intensityEntryCount += 1;",
        "totalIntensity / intensityEntryCount",
    ],
    "test/log_entry_reflection_data_foundation_test.dart": [
        "legacy non-Reflection map without intensity defaults to 3",
        "Reflection map without intensity stays intensity-free",
        "Reflection constructor round-trips without fake intensity",
        "non-Reflection null intensity still receives legacy fallback",
    ],
}

for rel_path, needles in checks.items():
    path = ROOT / rel_path
    if not path.is_file():
        print(f"FAIL BW-LOG-01B1 missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(
                f"FAIL BW-LOG-01B1 {rel_path} missing: {needle}"
            )
            sys.exit(1)

print(
    "PASS: BW-LOG-01B1 Reflection data foundation "
    "remains nullable and backward-compatible."
)
