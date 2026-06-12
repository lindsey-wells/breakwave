from pathlib import Path
import sys

checks = [
    ("android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt", [
        "MethodChannel",
        "breakwave/screen_privacy",
        "setScreenPrivacyEnabled",
        "WindowManager.LayoutParams.FLAG_SECURE",
        "window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)",
    ]),
    ("lib/core/privacy/screen_privacy_service.dart", [
        "class ScreenPrivacyService",
        "MethodChannel('breakwave/screen_privacy')",
        "setScreenPrivacyEnabled",
        "MissingPluginException",
    ]),
    ("lib/core/privacy/privacy_settings.dart", [
        "blockScreenshotsAndScreenRecording",
        "'blockScreenshotsAndScreenRecording': blockScreenshotsAndScreenRecording",
        "map['blockScreenshotsAndScreenRecording'] == true",
    ]),
    ("lib/main.dart", [
        "ScreenPrivacyService.setScreenPrivacyEnabled",
        "privacy.blockScreenshotsAndScreenRecording",
        "best-effort shield",
    ]),
    ("lib/features/support/presentation/widgets/privacy_settings_card.dart", [
        "Block screenshots and screen recording",
        "Asks Android to block normal screenshots and screen recordings",
        "reduces casual exposure but is not absolute protection",
        "ScreenPrivacyService.setScreenPrivacyEnabled",
    ]),
    ("launch/screen_privacy_shield.md", [
        "BW-70B Screen Privacy Shield",
        "block normal screenshots and screen recordings",
        "not absolute protection",
        "optional",
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

unsafe_claims = [
    "guaranteed protection",
    "impossible to capture",
    "prevents all screenshots",
    "cannot be bypassed",
]

for rel_path in [
    "lib/features/support/presentation/widgets/privacy_settings_card.dart",
    "launch/screen_privacy_shield.md",
]:
    text = Path(rel_path).read_text(encoding="utf-8").lower()
    for claim in unsafe_claims:
        if claim in text:
            print(f"FAIL unsafe screen privacy claim in {rel_path}: {claim}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-70B Screen Privacy Shield verified.")
