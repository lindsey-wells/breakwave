from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card_path = root / "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
card = card_path.read_text(encoding="utf-8")

required = [
    "tikTokBrowserUrl",
    "xBrowserUrl",
    "is_from_webapp=1",
    "sender_device=pc",
    "required String browserUrl",
    "final Uri browserUri = Uri.parse(browserUrl);",
    "Tries the web profile in your browser. Copy link is the fallback.",
    "await _openSocialInDefaultBrowser(context, browserUri);",
    "browserUrl: tikTokBrowserUrl",
    "browserUrl: xBrowserUrl",
    "url: tikTokUrl",
    "url: xUrl",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-80G missing direct web-mode social link behavior: {needle}")
        sys.exit(1)

print("PASS: BW-80G direct web-mode social links verified.")
