#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

checks = {
    "lib/features/log/presentation/widgets/log_entry_type_section.dart": [
        "BW-LOG-01B2 exposes Reflection",
        "'Reflection',",
        "log-entry-type-$type",
    ],
    "lib/features/log/presentation/widgets/log_entry_visuals.dart": [
        "static const LogEntryVisualStyle reflection",
        "Icons.lightbulb_outline_rounded",
        "case 'reflection':",
        "return reflection;",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "bool get _isReflectionDraft",
        "final bool isReflectionEntry",
        "intensity: isReflectionEntry ? null : _intensity,",
        "if (!_isReflectionDraft) ...<Widget>[",
        "isReflectionEntry: _isReflectionDraft,",
        "intensity: _isReflectionDraft ? null : _intensity,",
    ],
    "lib/features/log/presentation/widgets/log_cbt_reflection_card.dart": [
        "required this.isReflectionEntry",
        "final bool isReflectionEntry;",
        "Simple reflection",
        "Capture what you noticed",
        "Notice the pattern without judging yourself.",
        "Thought or pattern noticed",
    ],
    "lib/features/log/presentation/widgets/log_save_card.dart": [
        "final int? intensity;",
        "final String draftSummary = intensity == null",
        "Current draft: $entryType • $triggerCount",
    ],
    "lib/features/insights/presentation/simple_insights_card.dart": [
        "int reflectionCount = 0;",
        "case 'Reflection':",
        "reflectionCount += 1;",
        "$reflectionCount reflection",
    ],
    "test/log_reflection_user_experience_test.dart": [
        "Reflection selector has its own icon",
        "Reflection history badge appears without intensity",
        "Reflection draft summary does not invent intensity",
        "Reflection card uses calm nonjudgmental prompts",
    ],
}

for rel_path, needles in checks.items():
    path = ROOT / rel_path
    if not path.is_file():
        print(f"FAIL BW-LOG-01B2 missing file: {rel_path}")
        sys.exit(1)
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-LOG-01B2 {rel_path} missing: {needle}")
            sys.exit(1)

recent = (
    ROOT
    / "lib/features/log/presentation/widgets/recent_log_entries_card.dart"
).read_text(encoding="utf-8")
if "if (entry.intensity != null)" not in recent:
    print("FAIL BW-LOG-01B2 recent Reflection entries may show fake intensity")
    sys.exit(1)

print(
    "PASS: BW-LOG-01B2 Reflection UX is visible, calm, "
    "intensity-free, and covered."
)
