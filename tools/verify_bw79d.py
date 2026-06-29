from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
notification_path = root / "lib/core/reminders/breakwave_notifications.dart"
text = notification_path.read_text(encoding="utf-8")

required = [
    "const String fullBody = 'Pause early and choose one clean next step.';",
    "body: privacy.discreetNotifications ? 'Pause early.' : fullBody",
    "title: privacy.discreetNotifications ? 'Nudge' : 'BreakWave nudge'",
]

for needle in required:
    if needle not in text:
        print(f"FAIL: missing neutral notification copy guard: {needle}")
        sys.exit(1)

forbidden = [
    "Watch for ${",
    "preview.join",
    "selectedTriggers",
    "selectedRiskyTimes",
]

for needle in forbidden:
    if needle in text:
        print(f"FAIL: risky notification body may expose saved patterns: {needle}")
        sys.exit(1)

print("PASS: BW-79D neutral notification body verified.")
