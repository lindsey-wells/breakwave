from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart").read_text(encoding="utf-8")

required = [
    "Open in Chrome",
    "Open in DuckDuckGo",
    "Copy the web profile link.",
    "$browserName was not available. Web link copied.",
    "browserName: 'Chrome'",
    "browserName: 'DuckDuckGo'",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-80D missing browser-specific UX copy: {needle}")
        sys.exit(1)

print("PASS: BW-80D browser-specific social UX copy verified.")
