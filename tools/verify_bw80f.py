from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card_path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
card = card_path.read_text(encoding="utf-8")

required = [
    "tikTokBrowserUrl",
    "xBrowserUrl",
    "duckduckgo.com",
    "required String browserUrl",
    "final Uri browserUri = Uri.parse(browserUrl);",
    "Uses a browser-safe web page when apps intercept direct links.",
    "await _openSocialInDefaultBrowser(context, browserUri);",
    "browserUrl: tikTokBrowserUrl",
    "browserUrl: xBrowserUrl",
    "url: tikTokUrl",
    "url: xUrl",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-80F missing browser-safe social link behavior: {needle}")
        sys.exit(1)

print("PASS: BW-80F browser-safe social web links verified.")
