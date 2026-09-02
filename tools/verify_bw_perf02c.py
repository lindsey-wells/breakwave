from pathlib import Path
import sys

main_path = Path("lib/main.dart")
failed = False

if not main_path.is_file():
    print("FAIL missing file: lib/main.dart")
    sys.exit(1)

text = main_path.read_text(encoding="utf-8")

required = [
    "final Stopwatch? privacyTimer =",
    "final Stopwatch? privacySettingsTimer =",
    "final PrivacySettings privacy = await PrivacySettingsStore.load();",
    "name: 'privacy_settings_load'",
    "final Stopwatch? privacyShieldTimer =",
    "await ScreenPrivacyService.setScreenPrivacyEnabled(",
    "privacy.blockScreenshotsAndScreenRecording,",
    "name: 'privacy_screen_shield_apply'",
    "name: 'privacy_initialize'",
]
for needle in required:
    if needle not in text:
        print(f"FAIL PERF-02C instrumentation missing: {needle}")
        failed = True

try:
    main_body = text.split("Future<void> main() async {", 1)[1]
    pre_run_app = main_body.split("runApp(const BreakWaveApp());", 1)[0]
except IndexError:
    print("FAIL unable to isolate pre-runApp startup section")
    failed = True
    pre_run_app = ""

for needle in [
    "PrivacySettingsStore.load()",
    "ScreenPrivacyService.setScreenPrivacyEnabled(",
    "name: 'privacy_settings_load'",
    "name: 'privacy_screen_shield_apply'",
    "name: 'privacy_initialize'",
]:
    if needle not in pre_run_app:
        print(f"FAIL privacy operation/timing moved after runApp: {needle}")
        failed = True

if "unawaited(PrivacySettingsStore.load" in text:
    print("FAIL privacy settings load became unawaited")
    failed = True

if "unawaited(ScreenPrivacyService.setScreenPrivacyEnabled" in text:
    print("FAIL screen privacy shield became unawaited")
    failed = True

load_pos = pre_run_app.find("PrivacySettingsStore.load()")
load_record = pre_run_app.find("name: 'privacy_settings_load'")
shield_pos = pre_run_app.find("ScreenPrivacyService.setScreenPrivacyEnabled(")
shield_record = pre_run_app.find("name: 'privacy_screen_shield_apply'")
overall_record = pre_run_app.find("name: 'privacy_initialize'")

if not (
    load_pos >= 0
    and load_record > load_pos
    and shield_pos > load_record
    and shield_record > shield_pos
    and overall_record > shield_record
):
    print("FAIL PERF-02C privacy timing/order contract is not preserved")
    failed = True

if failed:
    sys.exit(1)

print(
    "PASS: PERF-02C splits privacy startup timing without changing "
    "pre-runApp privacy ordering."
)
