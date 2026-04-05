from pathlib import Path
import sys

checks = [
    ("lib/core/bedtime/bedtime_mode_entry.dart", [
        "class BedtimeModeEntry",
        "dateKey",
        "isRisky",
        "savedAtIso",
        "toMap()",
        "fromMap",
    ]),
    ("lib/core/bedtime/bedtime_mode_store.dart", [
        "class BedtimeModeStore",
        "bw_bedtime_mode_v1",
        "todayKey()",
        "loadTodayEntry",
        "saveTodayRisk",
    ]),
    ("lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart", [
        "class BedtimeDangerModeCard",
        "Bedtime danger mode",
        "Bedtime check",
        "Tonight feels steady",
        "Tonight feels risky",
        "Open Rescue now",
        "RecoveryMode.christian",
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
    if "BedtimeDangerModeCard" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: BedtimeDangerModeCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-23 bedtime danger mode verified.")
