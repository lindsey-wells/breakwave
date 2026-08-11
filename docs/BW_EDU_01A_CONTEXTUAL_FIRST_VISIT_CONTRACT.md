# BW-EDU-01A — Contextual First-Visit Education Foundation

## Purpose
Give users brief, contextual guidance the first time they encounter core
BreakWave areas without creating another tutorial or interrupting recovery.

BW-EDU-01A applies to Rescue, Log, and Support.
Home is excluded because BW-HOME-01A already provides everyday orientation.

## Behavior
Each contextual card is brief, dismissible with **Got it**, independent per
surface, stored locally, and permanently hidden for that surface after
dismissal.

A surface is **not** marked dismissed merely because its widget is built.
BreakWave's IndexedStack constructs offscreen tabs, so only the user's
explicit **Got it** action persists dismissal.

If the user leaves without dismissing the card, it may appear again on the
next visit until acknowledged.

## Rescue
The Rescue education appears after the existing urge-intensity control so
education never sits between a user and the first Rescue action.

**Interrupt + Redirect**

- First visit • Interrupt + Redirect
- Use Rescue when the wave is rising
- Name the intensity, bring your Personal Why into view, then choose one next
  right action. You do not need to Log anything before using Rescue.

BW-EDU-01A does not change Rescue behavior, persistence, completion,
support escalation, or navigation.

## Log
The Log education appears immediately after the existing entry-type selector.
The user can therefore choose Urge, Slip, Victory, or Reflection before any
first-visit education increases the vertical distance to that first action.

**Recognize + Reinforce**

- First visit • Recognize + Reinforce
- Use your Log to make patterns visible
- Record an urge, slip, victory, or reflection when it helps. Notice triggers,
  what you tried, and what helped—without grading yourself.

This placement preserves the established Log first-action hierarchy and keeps
existing Slip selection behavior reachable before contextual education.

BW-EDU-01A does not change Log entry types, recovery data, Slip Follow-Up,
edit/delete behavior, or navigation.

## Support
The Support education appears after the existing Support Harbor introduction
and before the established task groups.

**Redirect**

- First visit • Redirect
- Support is organized by what you need next
- Immediate help stays first. Recovery setup, learning, privacy, and contact
  tools are grouped below so you can find the next useful step.

BW-EDU-01A does not reorder or redesign Support groups.

## State and privacy
New local key:
`bw_contextual_first_visit_dismissed_v1`

It contains only dismissed surface identifiers: `rescue`, `log`, `support`.

This state is not recovery data, contains no user-entered content, requires
no account, is not analytics, does not change onboarding/tutorial progress,
and does not change billing, entitlement, or Plus access.

## Recovery-mode behavior
The contextual copy is intentionally neutral and valid in both Christian and
Secular mode. BW-EDU-01A does not add mode-specific branches.

## Test model
The widget regression test gives each synthetic education surface a distinct
key. That models the real BreakWave shell, where Rescue, Log, and Support are
independent tab elements rather than one stateful widget changing surfaces in
place.

## Guardrails
BW-EDU-01A must not:
- block or gate Rescue;
- require education dismissal before using any feature;
- add navigation;
- write Log entries;
- change Personal Why;
- launch messages, calls, or emergency actions;
- change BreakWaveAccessPolicy;
- add an upgrade prompt;
- duplicate Teach Me BreakWave;
- automatically mark offscreen tabs dismissed;
- push the Log entry-type selector behind contextual education.
