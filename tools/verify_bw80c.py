from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

dart_path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
kt_path = root / "android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt"
manifest_path = root / "android/app/src/main/AndroidManifest.xml"

dart = dart_path.read_text(encoding="utf-8")
kt = kt_path.read_text(encoding="utf-8")
manifest = manifest_path.read_text(encoding="utf-8")

dart_required = [
    "MethodChannel('breakwave/social_links')",
    "openDefaultBrowser",
    "openUrlInPackage",
    "Future<void> _openSocialInDefaultBrowser",
    "Future<void> _showBrowserFallbackOptions",
    "'packageName': packageName",
    "LaunchMode.externalNonBrowserApplication",
]

kt_required = [
    "import android.content.Intent",
    "import android.content.pm.PackageManager",
    "import android.net.Uri",
    "SOCIAL_LINKS_CHANNEL",
    "breakwave/social_links",
    "openDefaultBrowser",
    "openUrlInPackage",
    "PackageManager.MATCH_DEFAULT_ONLY",
    "setPackage(packageName)",
    "Intent.ACTION_VIEW",
    "Intent.CATEGORY_BROWSABLE",
]

manifest_required = [
    'android.intent.action.VIEW',
    'android.intent.category.BROWSABLE',
    'android:scheme="https"',
    'android:scheme="http"',
]

for needle in dart_required:
    if needle not in dart:
        print(f"FAIL BW-80E Dart missing: {needle}")
        sys.exit(1)

for needle in kt_required:
    if needle not in kt:
        print(f"FAIL BW-80E Android missing: {needle}")
        sys.exit(1)

for needle in manifest_required:
    if needle not in manifest:
        print(f"FAIL BW-80E manifest missing: {needle}")
        sys.exit(1)

print("PASS: BW-80E default-browser social links verified.")
