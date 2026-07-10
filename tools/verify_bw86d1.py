from pathlib import Path
import sys

service = Path(
    "lib/core/email_capture/email_app_handoff_service.dart"
).read_text(encoding="utf-8")

links = Path(
    "lib/features/support/presentation/widgets/breakwave_contact_links_card.dart"
).read_text(encoding="utf-8")

required_links = [
    "Notes: BW-86D1 wires official BreakWave email and social links.",
    "support@breakwaveapp.com",
    "privacy@breakwaveapp.com",
    "https://instagram.com/breakwaveapp",
    "https://www.facebook.com/breakwaveapp",
    "Future<void> _openPrivacyEmail",
    "Future<void> _openInstagram",
    "Future<void> _openFacebook",
    "Instagram $instagramHandle",
    "Facebook $facebookHandle",
]

for needle in required_links:
    if needle not in links:
        print(f"FAIL BW-86D1 contact wiring missing: {needle}")
        sys.exit(1)

if "support@breakwaveapp.com" not in service:
    print("FAIL BW-86D1 feedback default inbox was not updated")
    sys.exit(1)

if "proton.me" in links.lower() or "proton.me" in service.lower():
    print("FAIL BW-86D1 old Proton address remains")
    sys.exit(1)

print("PASS: BW-86D1 official BreakWave contact wiring verified.")
