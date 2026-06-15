from pathlib import Path
import sys

rescue_path = Path("lib/features/rescue/presentation/rescue_screen.dart")
rescue_text = rescue_path.read_text(encoding="utf-8")

checks = [
    "Name the wave, then remember why",
    "Use one immediate redirect",
    "Slow the surge before it gets louder",
    "Mark what happened and get support",
    "UrgeIntensitySection",
    "RememberWhyCard",
    "RedirectActionsCard",
    "WaveTimerCard",
    "CalmResetCard",
    "RescueCardEngine",
    "WaveCompletionCard",
    "SupportEscalationCard",
]

failed = False

for needle in checks:
    if needle not in rescue_text:
        print(f"FAIL {rescue_path} missing: {needle}")
        failed = True

order = [
    ("UrgeIntensitySection", rescue_text.find("UrgeIntensitySection(")),
    ("RememberWhyCard", rescue_text.find("RememberWhyCard()")),
    ("RedirectActionsCard", rescue_text.find("RedirectActionsCard(")),
    ("WaveTimerCard", rescue_text.find("WaveTimerCard(")),
    ("CalmResetCard", rescue_text.find("CalmResetCard()")),
    ("RescueCardEngine", rescue_text.find("RescueCardEngine()")),
    ("WaveCompletionCard", rescue_text.find("WaveCompletionCard(")),
    ("SupportEscalationCard", rescue_text.find("SupportEscalationCard(")),
]

for label, index in order:
    if index == -1:
        print(f"FAIL order anchor missing: {label}")
        failed = True

if not failed:
    for (left_label, left_index), (right_label, right_index) in zip(order, order[1:]):
        if left_index > right_index:
            print(f"FAIL order issue: {left_label} should appear before {right_label}")
            failed = True

if "onPressed: () {}" in rescue_text:
    print("FAIL Rescue screen contains a dead button callback")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-56 Rescue hierarchy cleanup verified.")
