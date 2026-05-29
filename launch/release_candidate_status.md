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
