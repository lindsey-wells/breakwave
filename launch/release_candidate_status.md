# BreakWave — Release Candidate Status

## Current status
BreakWave is at a release candidate baseline.

## Rules from this point
- No new feature scope unless a true launch blocker is found
- Only blocker fixes, launch-trust fixes, or final release prep
- Non-blockers should be logged and deferred

## Launch-trust areas already swept
- save reliability
- rescue flow
- refresh correctness
- premium routing
- privacy/reminder safety

## Current blocker status
No launch blockers logged at the time this baseline was created.


## BW-49D privacy/security release copy

Release copy now clarifies:
- BreakWave is local-first for MVP core recovery data.
- Optional email preferences are saved locally.
- Manual email handoff opens the user's email app and can be reviewed before sending.
- Privacy lock is app-level protection, not medical-grade security.
- Lock Log & Support keeps Home and Rescue reachable.
- Failed PIN attempts trigger cooldown instead of automatic data deletion.


## BW-50 AAB artifact

GitHub Actions now builds and uploads:
- release APK artifact for device smoke testing
- release AAB artifact for Play Store preparation

The AAB artifact is not the final signed Play upload flow yet. Play signing/upload key configuration is handled in BW-51.


## BW-52 Play internal testing setup

Internal testing setup doc added.

Next handoff step:
- Upload the signed AAB artifact to Google Play Console internal testing.
- Add tester emails.
- Roll out the internal test release.
- Send tester opt-in link.
- Verify install through Google Play.


## BW-79 QA hardening sweep

Final internal-testing trust fixes completed:
- removed cosmetic privacy toggle that did not change behavior
- required current PIN before changing or clearing privacy lock
- cleaned unfinished BreakWave Plus preview/testing copy
- kept risky notification details neutral so saved triggers stay inside the app
- removed unfinished Plus preview/build wording from app-facing copy

No P0 launch blockers are currently logged after the BW-79 sweep.
