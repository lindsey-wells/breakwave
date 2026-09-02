from pathlib import Path
import sys

main_path = Path("lib/main.dart")
notifications_path = Path(
    "lib/core/reminders/breakwave_notifications.dart"
)
runner_path = Path(
    ".github/scripts/run_breakwave_shadow_ci.py"
)

failed = False

for path in [main_path, notifications_path, runner_path]:
    if not path.exists():
        print(f"FAIL missing file: {path}")
        failed = True

if failed:
    sys.exit(1)

main = main_path.read_text(encoding="utf-8")
notifications = notifications_path.read_text(encoding="utf-8")
runner = runner_path.read_text(encoding="utf-8")

main_required = [
    "Future<void> _warmNotificationsAfterFirstFrame() async",
    "await BreakWaveNotifications.initialize();",
    "name: 'notifications_initialize'",
    "WidgetsBinding.instance.addPostFrameCallback((_) {",
    "unawaited(_warmNotificationsAfterFirstFrame());",
]
for needle in main_required:
    if needle not in main:
        print(f"FAIL lib/main.dart missing: {needle}")
        failed = True

try:
    main_body = main.split("Future<void> main() async {", 1)[1]
    pre_run_app = main_body.split(
        "runApp(const BreakWaveApp());", 1
    )[0]
except IndexError:
    print("FAIL unable to isolate main() pre-runApp section")
    failed = True
    pre_run_app = ""

if "BreakWaveNotifications.initialize()" in pre_run_app:
    print("FAIL notification initialization still blocks before runApp")
    failed = True

run_app_index = main.find("runApp(const BreakWaveApp());")
callback_index = main.find(
    "WidgetsBinding.instance.addPostFrameCallback((_) {",
    run_app_index,
)
warm_index = main.find(
    "unawaited(_warmNotificationsAfterFirstFrame());",
    callback_index,
)
if not (
    run_app_index >= 0
    and callback_index > run_app_index
    and warm_index > callback_index
):
    print("FAIL notification warmup is not post-first-frame")
    failed = True

notification_required = [
    "static Future<void>? _initializationFuture;",
    "static Future<void> initialize() {",
    "final Future<void>? pendingInitialization =",
    "_initializationFuture;",
    "if (pendingInitialization != null) {",
    "return pendingInitialization;",
    "final Future<void> initialization = _initializeOnce();",
    "_initializationFuture = initialization;",
    "static Future<void> _initializeOnce() async {",
    "_initialized = true;",
    "finally {",
    "_initializationFuture = null;",
]
for needle in notification_required:
    if needle not in notifications:
        print(
            "FAIL breakwave_notifications.dart missing: "
            f"{needle}"
        )
        failed = True

if "static Future<void> initialize() async {" in notifications:
    print("FAIL old non-single-flight initialize implementation remains")
    failed = True

runner_required = [
    'PRE_PERF02B_REF = '
    '"97e17cc2eb7ad6a2db99fddfdb638ce22df326b0"',
    '"tools/verify_bw34.py": PRE_PERF02B_REF,',
    '"tools/verify_bw_perf02b.py": "HEAD",',
]
for needle in runner_required:
    if needle not in runner:
        print(f"FAIL Shadow runner missing: {needle}")
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: PERF-02B moves notification initialization after first frame, "
    "deduplicates concurrent initialization, and preserves historical BW-34."
)
