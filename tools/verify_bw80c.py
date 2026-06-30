from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

dart_path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
kt_path = root / "android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt"

dart = dart_path.read_text(encoding="utf-8")
kt = kt_path.read_text(encoding="utf-8")

dart_required = [
    "MethodChannel('breakwave/social_links')",
    "openBrowserChooser",
    "<String, String>{'url': webUri.toString()}",
    "Web link copied. Paste it into your browser.",
    "LaunchMode.externalNonBrowserApplication",
]

kt_required = [
    "import android.content.Intent",
    "import android.net.Uri",
    "SOCIAL_LINKS_CHANNEL",
    "breakwave/social_links",
    "openBrowserChooser",
    "Intent.createChooser(webIntent, \"Open web link\")",
    "Intent.ACTION_VIEW",
    "Intent.CATEGORY_BROWSABLE",
]

for needle in dart_required:
    if needle not in dart:
        print(f"FAIL BW-80C Dart missing: {needle}")
        sys.exit(1)

for needle in kt_required:
    if needle not in kt:
        print(f"FAIL BW-80C Android missing: {needle}")
        sys.exit(1)

print("PASS: BW-80C Android browser chooser verified.")
