from pathlib import Path
import sys

checks = [
    ("launch/privacy_security_release_copy.md", [
        "BreakWave is designed as a private, local-first recovery companion.",
        "does not require an account",
        "manual handoff flow opens the user's email app",
        "privacy@breakwaveapp.com",
        "app-level privacy lock",
        "6-digit PIN",
        "lock Log and Support while keeping Home and Rescue reachable",
        "not a substitute for device-level security",
        "Automatic data deletion is not enabled in the MVP",
        "Play Store Data Safety notes",
        "Avoid this language:",
        "HIPAA compliant",
        "prevents cloning",
        "MFA-protected account",
    ]),
    ("launch/launch_checklist_draft.md", [
        "Privacy/security release copy reviewed",
        "Play Data Safety answers drafted",
        "AAB artifact confirmed",
        "Play upload signing key configured",
    ]),
    ("launch/release_candidate_status.md", [
        "BW-49D privacy/security release copy",
        "Privacy lock is app-level protection, not medical-grade security.",
        "Failed PIN attempts trigger cooldown instead of automatic data deletion.",
    ]),
    ("launch/play_store_metadata_draft.md", [
        "Privacy & security positioning",
        "local-first for core recovery data",
        "app-level 6-digit privacy lock",
    ]),
    ("launch/release_candidate_blockers.md", [
        "Privacy/security copy reviewed in BW-49D",
        "Do not claim HIPAA compliance",
        "clone prevention",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-49D privacy/security release copy verified.")
