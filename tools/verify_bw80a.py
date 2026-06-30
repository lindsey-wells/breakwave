from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
text = path.read_text(encoding="utf-8")

required = [
    "import 'package:flutter/services.dart';",
    "showModalBottomSheet<void>",
    "Open in app",
    "Open web link",
    "Copy link",
    "Clipboard.setData",
    "ClipboardData(text: url)",
    "LaunchMode.externalNonBrowserApplication",
    "LaunchMode.inAppBrowserView",
    "Web link copied. Paste it into your browser.",
    "App not available. Choose browser or copy link instead.",
    "https://www.tiktok.com/@BreakWaveapp",
    "https://x.com/BreakWaveapp",
]

for needle in required:
    if needle not in text:
        print(f"FAIL: missing BW-80A social chooser behavior: {needle}")
        sys.exit(1)

print("PASS: BW-80A social link app/browser/copy chooser verified.")
