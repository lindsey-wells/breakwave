# BW-BETA-01A — Closed-Testing Operations Foundation

## Status

This document defines the first formal operating system for BreakWave closed-
testing feedback.

BW-BETA-01A changes no application behavior. It creates no tester account,
collects no recovery data, and does not enable analytics.

The versioned CSV in this repository is a blank working template. Actual
reports must remain in an owner-approved private location and must follow the
privacy rules below.

## Purpose

Every meaningful beta report should be traceable from:

1. the tester's observation
2. the tested device and exact BreakWave build
3. triage and reproducibility
4. the authorized fix commit
5. Shadow CI and main CI evidence
6. device retesting
7. final resolution

Chat messages, screenshots, terminal output, and memory may support a report,
but none of them replaces the master issue record.

## Roles

- **Product triage:** BreakWave's primary product operator assigns priority,
  approves deferral, and accepts final closure.
- **QA:** approved closed testers and designated QA collaborators provide
  reproducible evidence and perform retesting.
- **Implementation:** Cube23 LLC may implement approved technical corrections
  as the development partner.
- **Production ownership:** 24/3CJ LLC retains release, credential, financial,
  and production authority.

A person may perform more than one operational role, but each issue record must
show who made the triage, implementation, and retest decisions.

## Privacy boundary

The beta register must never contain:

- pornography descriptions or browsing details
- recovery-log text
- urge, slip, victory, Reflection, or check-in content
- triggers or risky-time details tied to a person
- Personal Why text or images
- recovery plans, prayers, journal text, or trusted-contact details
- phone numbers, email addresses, legal names, passwords, tokens, or secrets
- screenshots that expose notifications, contacts, other applications, or
  private recovery information

Use a tester alias or assigned tester code. Evidence must be scrubbed before it
is attached or referenced.

A technical report may say, for example, "a saved Reflection entry was not
visible after reopening Log." It must not reproduce the Reflection text.

A possible privacy exposure, unsafe external action, or inaccessible Rescue
flow is a P0 stop condition. Stop the affected test and notify the product
operator directly. Do not add sensitive details to the register.

## Required issue identity

Issue IDs use:

    BWBETA-0001
    BWBETA-0002

Numbers are never reused, even after a duplicate or invalid report.

Every report must identify:

- tester alias
- device model and Android version
- BreakWave app version and version code
- build source: Play closed testing, Shadow APK, or main CI APK
- screen or workflow
- expected and actual behavior
- exact reproduction steps
- frequency or reproducibility
- privacy-scrubbed evidence reference when available

## Report types

Use one of:

- Defect
- Usability
- Accessibility
- Copy
- Enhancement

Enhancements are not automatically P1 or P2 defects. Triage must record whether
the request is accepted, deferred, or not planned.

## Severity rules

### P0 — Release stop / immediate safety concern

Examples:

- BreakWave will not start
- Rescue is unavailable, crashes, or is blocked by onboarding or Plus
- recovery data is lost, corrupted, or exposed
- a private notification reveals sensitive recovery information
- a harmless in-app action unexpectedly opens a call, message, or emergency
  action
- a free or never-paywalled safety feature becomes inaccessible
- an update makes the application unusable on a supported test device

P0 handling:

1. stop affected release or promotion work
2. preserve the exact build and device evidence
3. notify the product operator immediately
4. reproduce only when safe
5. require an authorized fix, Shadow evidence, and device retest before closure

### P1 — High impact / core workflow failure

Examples:

- a major Home, Log, Rescue-adjacent, Support, privacy, reminder, or onboarding
  workflow is materially broken
- reminders consistently fail, duplicate, or use the wrong privacy copy
- saved data is not displayed or editable as designed, without proven loss
- an accessibility defect blocks practical use
- a defect has no safe workaround for an important non-emergency task

P1 must be triaged before lower-severity polish and requires device retesting.

### P2 — Normal defect or polish

Examples:

- clipping, spacing, awkward copy, or minor visual inconsistency
- a low-impact action has a safe workaround
- a non-blocking accessibility or usability improvement
- a feature works but needs clearer confirmation or guidance

P2 may be grouped into a focused polish pass when that does not obscure
ownership or retest evidence.

## Reproducibility values

Use one of:

- Always
- Often
- Sometimes
- Once
- Not reproduced
- Not yet tested

"Cannot reproduce" is a resolution, not an intake shortcut. Record the attempted
build, device, steps, and outcome before using it.

## Status workflow

Use one of:

1. **New** — captured but not yet triaged
2. **Needs information** — required build, steps, or evidence is missing
3. **Needs reproduction** — enough information exists to begin testing
4. **Confirmed** — reproduced or otherwise supported by reliable evidence
5. **In progress** — an approved fix or investigation is active
6. **Ready for retest** — candidate fix is available on an identified build
7. **Closed** — closure criteria are satisfied
8. **Deferred** — valid but intentionally scheduled later
9. **Cannot reproduce** — documented attempts did not reproduce it
10. **Duplicate** — linked to the surviving issue ID

Do not mark an issue Closed merely because code was committed.

## Closure rules

A code defect may close only when the record contains:

- fix commit
- exact Shadow or main build used for retest
- retest tester and date
- retest result
- resolution

P0 and P1 code fixes require a passing device retest unless the product operator
documents why device retesting is impossible and what substitute evidence was
accepted.

A documentation, copy, or process-only issue may close through direct review
without an APK when no application artifact changed.

Deferred issues require a reason and intended milestone or review point.

Duplicate issues must name the surviving issue ID.

## Evidence references

Store references, not sensitive content. Examples:

- scrubbed screenshot filename
- private issue attachment identifier
- GitHub Actions run number
- PASS evidence ZIP name
- tester-provided screen recording label
- Play Console feedback reference

Do not place access tokens, temporary download URLs, or raw private content in
the CSV.

## Triage cadence

During active closed testing:

- P0: immediate review
- P1: review at the next working session
- P2: review in the regular beta-triage batch

The register should be reviewed before promoting a new release candidate and
after receiving a new batch of tester feedback.

## Definition of BW-BETA-01A complete

BW-BETA-01A is complete when:

- this operating contract is versioned
- the blank issue register is versioned
- the tester report template is versioned
- the verifier passes
- Shadow CI passes
- main remains unchanged until explicit promotion

No tester report is required to complete the operating foundation.
