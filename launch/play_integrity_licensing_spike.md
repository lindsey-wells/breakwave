# BreakWave — Play Integrity / Licensing Research Spike

## Purpose

BW-53 documents the launch-safe approach for protecting BreakWave against unauthorized installs, cloning, and tampered builds.

This is a research and decision pass only. It does not add runtime blocking code yet.

## Current protection already in place

- Official GitHub repository controls the source of truth.
- GitHub Actions builds APK/AAB artifacts.
- Release AAB pipeline supports Play upload signing through GitHub Secrets.
- Play App Signing / upload key flow protects the official Play release chain.
- Keystore and signing secrets are not committed to the repository.

## What SlimNation means by a licensing key

There are two different concepts:

1. Play upload signing key
   - Used to sign AABs before upload to Google Play.
   - Already prepared in BW-51.
   - Protects the official release pipeline.
   - Does not stop someone from decompiling or copying the app.

2. Runtime licensing / integrity check
   - App verifies whether it appears to be a legitimate Play-distributed install.
   - Can help detect unauthorized installs, tampering, or non-Play environments.
   - Should be implemented carefully to avoid blocking legitimate users.

## Google Play Licensing

Google Play Licensing allows an app published through Google Play to query Google Play at runtime and receive a licensing status for the current user/install.

Potential use:
- discourage unauthorized copies
- check whether an app install is licensed through Google Play
- support a simple allow / warn / restrict decision

Limitations:
- designed for apps distributed through Google Play
- depends on Google Play client availability
- client-side-only checks can be bypassed by determined attackers
- harsh blocking can create support problems

## Play Integrity API

Play Integrity can help verify signals about:
- whether the app is genuine
- whether it was installed by Google Play
- whether the device/environment appears valid
- whether the request/action appears trustworthy

Best use:
- server-side verification for important actions
- risk-based decisions rather than immediate app lockout
- protecting paid features, account features, abuse-sensitive actions, or backend calls

Limitations:
- strongest implementation usually requires a backend
- offline users and Play-services edge cases need safe handling
- not a magic anti-cloning shield
- implementation should wait until Play Console/internal testing is stable

## MVP recommendation

Do not add runtime blocking before first internal test.

Recommended order:
1. Complete Play internal testing upload.
2. Verify signed AAB installs from Google Play.
3. Confirm package name and signing are accepted.
4. Decide whether MVP needs runtime license warning or whether it can wait.
5. If needed, implement Play Integrity / Licensing behind a remote-safe or soft-fail policy.

## Launch-safe policy recommendation

For MVP, do not hard-block the whole app on first failed integrity/licensing check.

Use soft behavior first:
- allow Rescue to keep working
- show a warning if the app appears not installed from Google Play
- restrict future premium-only features if needed
- log only locally unless backend exists
- avoid blocking users in crisis/urge moments

## Future implementation options

Option A — Defer runtime licensing
- Best for fastest MVP launch.
- Lowest risk.
- Keep focus on Play-signed distribution and internal testing.

Option B — Client-side Play Licensing warning
- Medium effort.
- Can warn if the app does not appear licensed.
- Easier than full backend.
- Not strong anti-tamper protection.

Option C — Play Integrity with backend verification
- Strongest long-term path.
- Requires backend or trusted server component.
- Better suited after MVP, subscriptions, or account features.

## Decision

Recommended MVP decision:

Defer runtime Play Integrity / Licensing until after internal testing and first Play Console upload are stable.

Do not hardcode a secret license key inside the Flutter app. Hardcoded secrets can be extracted from the app and checks can be patched out.

Track as post-MVP security hardening:
- Play Integrity API research
- Play Licensing feasibility
- backend verification option
- premium feature protection strategy
