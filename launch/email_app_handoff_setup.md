# BreakWave — Email App Handoff Setup

Use this with BW-44B manual email app handoff.

## Goal
Open the user's email app with a prefilled draft containing saved BreakWave email-consent data.

## What the draft includes
- saved email address
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
