from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/home/presentation/widgets/daily_encouragement_card.dart").read_text(encoding="utf-8")

required = [
    "BW-81C rotates grounded recovery encouragement by day.",
    "static final DateTime _rotationStartDate = DateTime(2026, 1, 1);",
    "static const List<_DailyEncouragementLine> _encouragementLines",
    "_DailyEncouragementLine(",
    "An urge is a wave, not a command.",
    "This moment is not your identity.",
    "The wave can rise without ruling you.",
    "Clarity beats secrecy.",
    "static _DailyEncouragementLine _lineForDate(DateTime date)",
    "today.difference(_rotationStartDate).inDays",
    "daysSinceStart % _encouragementLines.length",
    "_lineForDate(DateTime.now())",
    "line.title",
    "line.body",
    "class _DailyEncouragementLine",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-81C Daily Encouragement missing: {needle}")
        sys.exit(1)

if card.count("_DailyEncouragementLine(") < 10:
    print("FAIL BW-81C expected at least 10 encouragement lines")
    sys.exit(1)

for forbidden in [
    "Random(",
    "shuffle(",
    "static const DateTime _rotationStartDate",
    "http://",
    "https://",
]:
    if forbidden in card:
        print(f"FAIL BW-81C should be local deterministic encouragement only: {forbidden}")
        sys.exit(1)

print("PASS: BW-81C rotating Daily Encouragement verified.")
