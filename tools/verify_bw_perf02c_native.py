from pathlib import Path
import re
import sys

failed = False

paths = {
    "main": Path("lib/main.dart"),
    "activity": Path(
        "android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt"
    ),
    "runner": Path(".github/scripts/run_breakwave_shadow_ci.py"),
    "workflow": Path(".github/workflows/breakwave-test-store-qa.yml"),
    "store": Path("lib/core/privacy/privacy_settings_store.dart"),
    "card": Path(
        "lib/features/support/presentation/widgets/privacy_settings_card.dart"
    ),
}

for name, path in paths.items():
    if not path.is_file():
        print(f"FAIL missing {name}: {path}")
        failed = True

if failed:
    sys.exit(1)

main = paths["main"].read_text(encoding="utf-8")
activity = paths["activity"].read_text(encoding="utf-8")
runner = paths["runner"].read_text(encoding="utf-8")
workflow = paths["workflow"].read_text(encoding="utf-8")
store = paths["store"].read_text(encoding="utf-8")
card = paths["card"].read_text(encoding="utf-8")

def has(pattern: str, text: str) -> bool:
    return re.search(pattern, text, flags=re.S) is not None

activity_patterns = [
    r"override\s+fun\s+onCreate\s*\(\s*savedInstanceState:\s*Bundle\?\s*\)",
    r"applyScreenPrivacyLaunchGuard\s*\(\s*\)",
    r"private\s+fun\s+readStoredScreenPrivacyEnabled\s*\(\s*\)\s*:\s*Boolean",
    r"getSharedPreferences\s*\(\s*FLUTTER_SHARED_PREFERENCES\s*,\s*MODE_PRIVATE\s*\)",
    r'private\s+const\s+val\s+FLUTTER_SHARED_PREFERENCES\s*=\s*"FlutterSharedPreferences"',
    r'private\s+const\s+val\s+FLUTTER_PRIVACY_SETTINGS_KEY\s*=\s*"flutter\.bw_privacy_settings_v1"',
    r'private\s+const\s+val\s+SCREEN_PRIVACY_JSON_KEY\s*=\s*"blockScreenshotsAndScreenRecording"',
    r"JSONObject\s*\(\s*raw\s*\)\s*\.optBoolean\s*\(\s*SCREEN_PRIVACY_JSON_KEY\s*,\s*false\s*\)",
    r"WindowManager\.LayoutParams\.FLAG_SECURE",
    r"window\.clearFlags\s*\(\s*WindowManager\.LayoutParams\.FLAG_SECURE\s*\)",
]
for pattern in activity_patterns:
    if not has(pattern, activity):
        print(f"FAIL native launch guard missing pattern: {pattern}")
        failed = True

try:
    on_create = activity.split(
        "override fun onCreate(savedInstanceState: Bundle?) {", 1
    )[1].split(
        "override fun configureFlutterEngine", 1
    )[0]
except IndexError:
    on_create = ""
    print("FAIL unable to isolate MainActivity.onCreate")
    failed = True

guard_pos = on_create.find("applyScreenPrivacyLaunchGuard()")
super_pos = on_create.find("super.onCreate(savedInstanceState)")
if guard_pos < 0 or super_pos < 0 or guard_pos > super_pos:
    print("FAIL native privacy guard must run before FlutterActivity.onCreate")
    failed = True

try:
    reader = activity.split(
        "private fun readStoredScreenPrivacyEnabled(): Boolean {", 1
    )[1].split(
        "private fun setScreenPrivacyEnabled", 1
    )[0]
except IndexError:
    reader = ""
    print("FAIL unable to isolate native privacy preference reader")
    failed = True

if not has(r"if\s*\(\s*raw\.isNullOrBlank\s*\(\s*\)\s*\)\s*\{\s*true\s*\}", reader):
    print("FAIL missing/blank native privacy state is not fail-secure")
    failed = True

if not has(r"catch\s*\(\s*_:\s*Exception\s*\)\s*\{\s*true\s*\}", reader):
    print("FAIL corrupt/unreadable native privacy state is not fail-secure")
    failed = True

main_patterns = [
    r"Future<void>\s+_reconcileScreenPrivacyAfterNativeLaunch\s*\(\s*bool\s+enabled\s*,?\s*\)\s+async",
    r"name:\s*'privacy_screen_shield_reconcile'",
    r"final\s+PrivacySettings\s+privacy\s*=\s*await\s+PrivacySettingsStore\.load\s*\(\s*\)\s*;",
    r"name:\s*'privacy_settings_load'",
    r"unawaited\s*\(\s*_reconcileScreenPrivacyAfterNativeLaunch\s*\(",
    r"privacy\.blockScreenshotsAndScreenRecording",
    r"name:\s*'privacy_initialize'",
]
for pattern in main_patterns:
    if not has(pattern, main):
        print(f"FAIL Flutter privacy reconciliation missing pattern: {pattern}")
        failed = True

if "name: 'privacy_screen_shield_apply'" in main:
    print("FAIL obsolete blocking privacy_screen_shield_apply metric remains")
    failed = True

try:
    body = main.split("Future<void> main() async {", 1)[1]
    pre_run_app = body.split("runApp(const BreakWaveApp());", 1)[0]
except IndexError:
    pre_run_app = ""
    print("FAIL unable to isolate pre-runApp startup body")
    failed = True

if has(
    r"await\s+ScreenPrivacyService\.setScreenPrivacyEnabled\s*\(",
    pre_run_app,
):
    print("FAIL native shield MethodChannel is still awaited before runApp")
    failed = True

load_pos = pre_run_app.find("PrivacySettingsStore.load()")
reconcile_pos = pre_run_app.find("_reconcileScreenPrivacyAfterNativeLaunch(")
overall_pos = pre_run_app.find("name: 'privacy_initialize'")
if (
    load_pos < 0
    or reconcile_pos < 0
    or overall_pos < 0
    or not (load_pos < reconcile_pos < overall_pos)
):
    print("FAIL PERF-02C startup reconciliation order is incorrect")
    failed = True

if "static const String storageKey = 'bw_privacy_settings_v1';" not in store:
    print("FAIL Flutter privacy storage key changed unexpectedly")
    failed = True

for needle in [
    "PrivacySettingsStore.save(_settings)",
    "ScreenPrivacyService.setScreenPrivacyEnabled(",
]:
    if needle not in card:
        print(f"FAIL runtime privacy save/apply path missing: {needle}")
        failed = True

routing_patterns = [
    r'PRE_PERF02C_REF\s*=\s*"3d2d8d8816cd972eba2b095c211ae96f83939946"',
    r'"tools/verify_bw70b\.py"\s*:\s*PRE_PERF02C_REF',
    r'"tools/verify_bw_perf02c\.py"\s*:\s*PRE_PERF02C_REF',
]
for pattern in routing_patterns:
    if not has(pattern, runner):
        print(f"FAIL historical PERF-02C routing missing pattern: {pattern}")
        failed = True

if "python3 tools/verify_bw_perf02c_native.py" not in workflow:
    print("FAIL Test Store QA does not run current PERF-02C native verifier")
    failed = True

if "python3 tools/verify_bw_perf02c.py" in workflow:
    print("FAIL Test Store QA still runs superseded split-only verifier on HEAD")
    failed = True

if failed:
    sys.exit(1)

print(
    "PASS: PERF-02C native launch guard protects startup before Flutter, "
    "reconciles the saved setting without blocking first frame, and preserves "
    "historical privacy contracts phase-aware."
)
