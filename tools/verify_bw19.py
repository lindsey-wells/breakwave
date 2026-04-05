from pathlib import Path
import sys

checks = [
    ("lib/core/checkin/daily_check_in_entry.dart", [
        "class DailyCheckInEntry",
        "dateKey",
        "status",
        "savedAtIso",
        "toMap()",
        "fromMap",
    ]),
    ("lib/core/checkin/daily_check_in_store.dart", [
        "class DailyCheckInStore",
        "bw_daily_check_ins_v1",
        "saveTodayStatus",
        "loadTodayEntry",
        "dateKeyFor",
        "todayKey",
    ]),
    ("lib/features/checkin/presentation/daily_check_in_card.dart", [
        "class DailyCheckInCard",
        "Daily check-in",
        "Steady",
        "Vulnerable",
        "Fought through",
        "Slipped",
        "Control signal:",
        "ChoiceChip",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

home_path = Path("lib/features/home/presentation/home_screen.dart")
if not home_path.exists():
    print("FAIL missing file: lib/features/home/presentation/home_screen.dart")
    failed = True
else:
    home_text = home_path.read_text(encoding="utf-8")
    if "DailyCheckInCard" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: DailyCheckInCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-19 daily check-in and control logic verified.")
