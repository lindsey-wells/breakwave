from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart").read_text(encoding="utf-8")

required = [
    "Open in app",
    "Open in browser",
    "Tries the web profile in your browser. Copy link is the fallback.",
    "Choose browser",
    "No default browser was available.",
    "Open in Chrome",
    "Most Android devices include Chrome.",
    "Open in DuckDuckGo",
    "Use DuckDuckGo Browser if installed.",
    "Copy the web profile link.",
    "$browserName was not available. Web link copied.",
    "browserName: 'Chrome'",
    "browserName: 'DuckDuckGo'",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-80G missing default-browser UX copy: {needle}")
        sys.exit(1)

print("PASS: BW-80G default-browser social UX copy verified.")
