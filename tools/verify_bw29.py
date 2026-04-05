from pathlib import Path
import sys

checks = [
    ("pubspec.yaml", [
        "home_widget:",
    ]),
    ("lib/core/widget/home_widget_sync.dart", [
        "class BreakWaveHomeWidgetSync",
        "providerName = 'BreakWaveHomeWidgetProvider'",
        "HomeWidget.saveWidgetData<String>('bw_widget_title'",
        "HomeWidget.saveWidgetData<String>('bw_widget_status'",
        "HomeWidget.saveWidgetData<String>('bw_widget_focus'",
        "HomeWidget.updateWidget(",
    ]),
    ("lib/features/home/presentation/home_screen.dart", [
        "BreakWaveHomeWidgetSync.sync();",
    ]),
    ("lib/features/checkin/presentation/daily_check_in_card.dart", [
        "BreakWaveHomeWidgetSync.sync();",
    ]),
    ("lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart", [
        "BreakWaveHomeWidgetSync.sync();",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
if not manifest_path.exists():
    print("FAIL missing file: android/app/src/main/AndroidManifest.xml")
    failed = True
else:
    manifest_text = manifest_path.read_text(encoding='utf-8')
    for needle in [
        "es.antonborri.home_widget.action.LAUNCH",
        "BreakWaveHomeWidgetProvider",
        "android.appwidget.action.APPWIDGET_UPDATE",
        "@xml/breakwave_home_widget_info",
    ]:
        if needle not in manifest_text:
            print(f"FAIL android/app/src/main/AndroidManifest.xml missing: {needle}")
            failed = True

layout_path = Path("android/app/src/main/res/layout/breakwave_home_widget.xml")
if not layout_path.exists():
    print("FAIL missing file: android/app/src/main/res/layout/breakwave_home_widget.xml")
    failed = True

xml_path = Path("android/app/src/main/res/xml/breakwave_home_widget_info.xml")
if not xml_path.exists():
    print("FAIL missing file: android/app/src/main/res/xml/breakwave_home_widget_info.xml")
    failed = True

provider_files = list(Path("android/app/src/main").rglob("BreakWaveHomeWidgetProvider.kt")) + \
    list(Path("android/app/src/main").rglob("BreakWaveHomeWidgetProvider.java"))

if not provider_files:
    print("FAIL missing widget provider file: BreakWaveHomeWidgetProvider")
    failed = True
else:
    provider_text = provider_files[0].read_text(encoding='utf-8')
    for needle in [
        "class BreakWaveHomeWidgetProvider",
        "HomeWidgetProvider",
        "HomeWidgetLaunchIntent.getActivity",
        "R.layout.breakwave_home_widget",
    ]:
        if needle not in provider_text:
            print(f"FAIL {provider_files[0]} missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-29 home widget and one-tap entry verified.")
