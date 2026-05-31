# BreakWave — Play Store Internal Testing Setup

## Purpose

BW-52 prepares the handoff for uploading BreakWave to Google Play Console internal testing.

Internal testing is the next correct release step after producing a signed AAB artifact.

## Required before upload

- GitHub Actions green on main
- `breakwave-release-aab` artifact downloaded from latest green run
- Confirm CI used Android release signing secrets
- Confirm package name is correct: `com.cube23.breakwave`
- Confirm version code/version name are ready
- Confirm support email: `BreakWaveapp@proton.me`
- Confirm privacy policy URL is available
- Confirm Play Store metadata draft is ready
- Confirm Data Safety answers are drafted
- Confirm screenshots/icon are ready or in progress

## How to upload internal test release

1. Open Google Play Console.
2. Select the BreakWave app.
3. Go to Release.
4. Go to Testing.
5. Open Internal testing.
6. Create or manage the internal testing track.
7. Add tester email addresses or create an email list.
8. Create a new release.
9. Upload the signed AAB from GitHub Actions.
10. Add release notes.
11. Review warnings and required setup tasks.
12. Save and roll out to internal testing.
13. Copy the tester opt-in link.
14. Send the opt-in link to testers.
15. Test install from Google Play, not just sideloaded APK.

## Tester list

Suggested first testers:

- founder
- developer
- Upwork Play Store publisher
- one Android user who has not installed the APK before
- one Android user willing to test privacy lock, rescue, email handoff, and Christian mode

## Internal test smoke checklist

Each tester should verify:

- app installs from Play internal testing
- app opens without crash
- Home loads
- Rescue opens quickly
- Rescue completion works
- Log saves a slip/check-in
- Recent history appears
- Christian mode can be selected
- Christian cards appear in Rescue
- Custom Why text saves
- Custom Why image saves, enlarges, changes, and removes
- optional email preferences save
- manual email handoff opens email draft to `BreakWaveapp@proton.me`
- contact links open
- privacy lock saves a 6-digit PIN
- Lock Log & Support keeps Home and Rescue reachable
- full-app lock requires PIN
- wrong PIN attempts show readable warning text
- reminders/privacy settings do not crash
- app can close/reopen with saved data intact

## Known non-MVP deferrals

Do not block internal testing for:

- Play Integrity / runtime licensing
- advanced analytics
- account login
- cloud sync
- full subscription wiring
- redesigned art pass
- advanced widgets
- iOS release

## Internal test release notes draft

BreakWave MVP internal test build.

Focus areas for testers:
- Rescue flow
- Christian/Secular recovery mode
- privacy lock
- custom Why image
- email handoff
- logging and recent history
- support/contact links

This is an internal test build. Please report crashes, confusing copy, broken navigation, or any place where sensitive recovery details appear unexpectedly.
