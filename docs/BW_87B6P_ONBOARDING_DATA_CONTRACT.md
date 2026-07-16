# BW-87B6P Onboarding Data Contract

## Temporary draft purpose

An onboarding draft exists only to resume unfinished setup.

The draft may contain:

- Recovery mode
- Broad support needs
- Reasons and current focus
- A short written Why
- Triggers
- Risky times
- Preferred interruption actions
- Whether the user chose to continue free or review Plus

The draft remains local to the device.

## Excluded from the draft

The draft must not contain:

- Phone numbers
- Email addresses
- Trusted-contact details
- Why image paths
- Individual recovery logs
- Notes
- CBT reflection text
- Thoughts, actions, or consequences from logs
- Privacy-lock passcodes
- Billing or entitlement state

## Access-choice safety

The onboarding Free-versus-Plus answer is navigation intent only.

Choosing to review Plus does not unlock Plus, start a purchase, begin a
trial, or change entitlement state.

## Save behavior

P3A1 saves only the temporary onboarding draft.

It does not write RecoveryModeStore, ReasonsStore, TriggersStore,
CustomWhyStore, PersonalRecoveryPlanStore, PremiumStateStore, or billing
data.

P3A2 will add an explicit completion service that safely merges selected
answers into the real BreakWave stores.

Skipping onboarding may clear the temporary draft, but it must never
erase previously saved recovery data.

## Completion synchronization

When onboarding is completed, BreakWave may synchronize supported
answers into the real local stores.

Synchronization follows these rules:

- Selected recovery mode may be saved
- Reasons and triggers are merged without duplicate values
- Existing saved reasons and triggers are preserved
- A saved Why is filled only when the existing Why text is blank
- An existing Why image path is preserved
- Existing personal-plan text is never replaced merely because
  onboarding was completed
- Empty personal-plan sections may be filled from onboarding answers
- Preferred interruption actions fill the plan only when that plan
  section is empty
- Completion is retry-safe and list merging is idempotent
- Plus-review intent remains navigation intent only

Broad support-needs answers currently personalize onboarding copy only.
They are not written into a separate recovery-data store.

Onboarding is marked complete only after requested data synchronization
succeeds. The temporary draft is then cleared.

Skipping onboarding changes only onboarding status and temporary draft
storage. It does not clear or replace recovery data.

## Launch and navigation behavior

Fresh users enter the versioned onboarding flow.

Established users and users who already completed or skipped onboarding
continue directly into the normal BreakWave launch path.

An interrupted onboarding session resumes at its last saved step.

Every onboarding step provides:

- Visible step progress
- Continue
- Back after the first step
- Skip setup
- Need help now? Open Rescue

Opening Rescue does not complete, skip, or reset onboarding. Closing
Rescue returns the user to the same onboarding step.

System Back moves to the previous onboarding step and does not
accidentally dismiss the flow.

If onboarding-state storage fails during launch, onboarding must never
prevent the existing recovery-mode gate or app shell from opening.

## Introductory setup screens

The first four onboarding screens provide real setup content:

1. BreakWave purpose and scope
2. Privacy and local-data expectations
3. Explicit secular or Christian recovery-mode choice
4. Broad support-needs selection

Recovery mode and support-needs answers are saved only to the temporary
onboarding draft while setup is in progress.

The recovery-mode screen explains that both paths retain access to
Rescue. Christian mode is explicit and optional.

The support-needs screen does not diagnose the user or describe its
answers as medical treatment.

A recovery mode and at least one support need are required before the
user advances from their respective screens.

These draft answers do not write RecoveryModeStore, PremiumStateStore,
billing state, logs, or other live recovery stores before final
onboarding completion.
