# BW-HOME-01A — Recovery Model Home Foundation

## Purpose

Make the existing BreakWave Home screen quietly communicate and
operationalize the recovery model without rebuilding Home or creating
new navigation, analytics, persistence, entitlement, or recovery tools.

The organizing model remains:

**RECOGNIZE → INTERRUPT → REDIRECT → REINFORCE**

with the plain-language companion:

**Notice it → Break it → Choose differently → Strengthen what works**

## Home responsibility

Home should answer two questions quickly:

1. **Do I need help right now?**
2. **If not, what should I notice or prepare for next?**

Rescue remains the clearest immediate action. Home does not replace Rescue.

## Foundation mapping

### Recognize

Existing Home content already supports recognition:

- Current Focus
- triggers and risky times
- daily check-in
- bedtime risk
- recent pattern information
- Learn the Wave Pattern

BW-HOME-01A keeps the established Home section labels stable and uses the
new recovery-model card to explain how these existing areas fit together.
It does not create a new pattern-analysis engine.

### Interrupt

The direct **Open Rescue** action at the top of Home becomes visually
primary. It opens Rescue without first requiring a Log entry.

Fast Urge remains available as the existing optional
**capture the urge, then open Rescue** path.

### Redirect

Home explains that Rescue can lead into one Next Right Action after the
interruption. BW-HOME-01A does not create a new saved Next Right Action,
Recovery Plan, or Guided Routine surface on Home.

### Reinforce

Existing Victories, Recovery Snapshot, recent Log information, Simple
Insights, and Daily Encouragement remain available as the current
reinforcement/progress layer.

BW-HOME-01A does not turn Home into a streak scoreboard and does not add
failure, back-to-zero, or shame language.

## Compact recovery-model card

Home gains one compact card near the top that shows both forms of the model
and explains how the existing architecture fits together. Existing section
labels such as **Today** and **Pattern awareness** remain intact.

The card uses three scannable plain-language mappings rather than one dense
paragraph:

- **Notice It**
  - Home helps you notice patterns and prepare.
- **Break It → Choose Differently**
  - Rescue helps you interrupt the wave and choose one next right action.
- **Strengthen What Works**
  - Your Log helps you remember what helped and learn the pattern.

The wording intentionally uses **what helped** rather than claiming that one
response is guaranteed to have caused a particular recovery outcome.

The card is orientation, not a curriculum.

## Access

The complete BW-HOME-01A foundation is core recovery UI.

It must not:
- gate Rescue behind Plus;
- add an upgrade wall to core Home recovery;
- change BreakWaveAccessPolicy;
- change billing or entitlement state.

Plus may later deepen pattern insight, personalization, planning, routines,
journeys, and longer-term analysis.

## Scope restraint

BW-HOME-01A does not:
- remove or replace existing Home recovery cards;
- change Fast Urge persistence behavior;
- redesign Log, Rescue, Support, Teach Me, Insights, Recovery Plan,
  or Guided Routines;
- add a new analytics engine;
- add a new navigation tab;
- change recovery data storage.

The visual-copy repair after Moto G smoke changes only the recovery-model
card, its widget test, this contract, and the existing BW-HOME-01A verifier.
`home_screen.dart` remains unchanged from the first green Shadow candidate.

Future Home work should continue to ask:

**How does this help the user Recognize, Interrupt, Redirect, or Reinforce?**
