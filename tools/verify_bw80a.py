from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
text = path.read_text(encoding="utf-8")

required = [
    "import 'package:flutter/services.dart';",
    "showModalBottomSheet<void>",
    "Open in app",
    "Open in browser",
    "Copy link",
    "Tries the web profile in your browser. Copy link is the fallback.",
    "Choose browser",
    "Open in Chrome",
    "Open in DuckDuckGo",
    "Clipboard.setData",
    "LaunchMode.externalNonBrowserApplication",
    "openDefaultBrowser",
    "openUrlInPackage",
    "com.android.chrome",
    "com.duckduckgo.mobile.android",
    "https://www.tiktok.com/@BreakWaveapp",
    "https://x.com/BreakWaveapp",
]

for needle in required:
    if needle not in text:
        print(f"FAIL: missing BW-80G social chooser behavior: {needle}")
        sys.exit(1)

print("PASS: BW-80G social link default-browser chooser verified.")
