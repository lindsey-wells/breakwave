from pathlib import Path
import sys

path = Path("lib/features/rescue/domain/christian_rescue_card_pack.dart")

if not path.exists():
    print("FAIL missing christian_rescue_card_pack.dart")
    sys.exit(1)

text = path.read_text(encoding="utf-8")

required = [
    "Purpose: BW-47 strengthened Christian rescue card pack.",
    "christian-no-condemnation",
    "christian-flee-and-follow",
    "christian-renew-your-mind",
    "christian-guard-your-eyes",
    "christian-lonely-night",
    "christian-after-slip-grace",
    "christian-integrity-minute",
    "christian-not-alone",
    "christian-peace-of-christ",
    "Romans 8:1",
    "Romans 12:2",
    "Lord, help me obey You in the next minute.",
    "Log the moment without shame language",
]

failed = False

for needle in required:
    if needle not in text:
        print(f"FAIL missing: {needle}")
        failed = True

card_count = text.count("RescueCardContent(")
if card_count < 12:
    print(f"FAIL expected at least 12 Christian rescue cards, found {card_count}")
    failed = True

if "cure" in text.lower():
    print("FAIL avoid cure claims in Christian rescue content")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-47 strengthened Christian rescue card pack verified.")
