from pathlib import Path
import sys

path = Path("lib/features/rescue/presentation/rescue_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "Start here",
    "Name the wave, then remember why",
    "UrgeIntensitySection",
    "RememberWhyCard",
    "WaveTimerCard",
    "CalmResetCard",
    "RescueCardEngine",
    "RedirectActionsCard",
    "WaveCompletionCard",
    "SupportEscalationCard",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL rescue_screen.dart missing: {needle}")
        failed = True

order = [
    "UrgeIntensitySection",
    "RememberWhyCard",
    "WaveTimerCard",
    "CalmResetCard",
    "RescueCardEngine",
    "RedirectActionsCard",
    "WaveCompletionCard",
    "SupportEscalationCard",
]

positions = {}
for needle in order:
    index = text.find(needle)
    if index == -1:
        print(f"FAIL cannot find order marker: {needle}")
        failed = True
    else:
        positions[needle] = index

if len(positions) == len(order):
    for before, after in zip(order, order[1:]):
        if positions[before] >= positions[after]:
            print(f"FAIL order issue: {before} should appear before {after}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-56 Rescue hierarchy cleanup verified.")
