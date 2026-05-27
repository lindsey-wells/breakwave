# BreakWave — Email App Handoff Setup

Use this with BW-44B manual email app handoff.

## Goal
Open the user's email app with a prefilled draft containing saved BreakWave email-consent data.

## What the draft includes
- saved user email address
- marketing opt-in
- research opt-in
- timestamp
- source: BreakWave

## App flow
1. Save optional email preferences in BreakWave
2. Enter the BreakWave team email address under **Send to BreakWave team**
3. Save the team email
4. Tap **Send saved data now**
5. Review the prefilled email draft
6. Tap send in Gmail or the preferred email app

## Why this path exists
- no backend required
- no Google Apps Script required
- user-controlled and explicit
- good fallback while the collection stack stays simple


## BW-48 launch polish

The app now defaults to `BreakWaveapp@proton.me` for manual email handoff.

Users do not need to configure a team email address. The support screen can still store a local override during internal testing.

The handoff remains manual: BreakWave opens the user's email app with a prefilled draft, and the user can review, edit, send, or cancel it.


## Verifier compatibility note

The manual handoff includes saved email address, marketing opt-in, and research opt-in consent data.
