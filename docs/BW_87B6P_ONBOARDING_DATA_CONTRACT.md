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

## Reasons, current focus, and written Why

Onboarding Step 5 allows the user to:

- select one or more preset reasons
- add custom reasons
- choose one selected reason as the current focus
- optionally write a short personal Why

At least one reason and a valid current focus are required before
advancing.

The written Why is optional and is limited to a short local statement.

Reason selections, current focus, and Why text remain in
OnboardingDraftStore while onboarding is unfinished.

Onboarding saves the current draft before saving the next onboarding
step. Finishing onboarding also saves the current draft before the
completion service merges supported answers.

Step 5 must not write ReasonsStore, CustomWhyStore, PremiumStateStore,
billing state, recovery logs, or contact information before final
completion.

## Triggers, risky times, and interruption actions

Onboarding Steps 6 through 8 use the established BreakWave trigger,
risky-time, and replacement-action vocabulary.

These selections are optional. A user may continue without choosing one,
because the existing live trigger and action tools do not require a
selection and onboarding must not invent a new blocking rule.

Selections are saved immediately to OnboardingDraftStore so rapid taps,
Back navigation, force-close, and restart preserve the latest choices.
Rapid repeated chip taps remain responsive while draft writes are queued
in order.

Custom triggers and one custom Other interruption action may be stored as
short labels. These steps do not store phone numbers, email addresses,
trusted-contact information, or any action execution result.

Choosing Open Rescue or Text someone safe during onboarding prepares a
future plan only. It does not open Rescue, send a message, or require a
saved contact from the onboarding screen.

Pray for one minute is offered only when the explicitly selected recovery
mode is Christian. Changing the draft back to secular removes that
Christian-only interruption action.

Steps 6 through 8 must not write TriggersStore,
PersonalRecoveryPlanStore, SupportContactStore, PremiumStateStore,
billing state, or entitlement state before final completion.

## Starter recovery setup summary

Onboarding Step 9 reads only the temporary draft and presents the user's
starting plan.

The summary keeps Current Focus and Personal Why as separate concepts and
labels. Optional unanswered sections are shown honestly as not selected
or not added.

The summary does not fabricate insights, risk scores, trends,
predictions, diagnoses, treatment claims, or recovery guarantees. Back
remains available for edits, and the summary does not call the completion
service or write live stores.

## Honest Free-versus-Plus completion choice

Onboarding Step 10 requires one explicit choice:

- Continue Free
- Review BreakWave Plus

Continue Free always remains available. Rescue, basic logging, privacy
controls, essential support resources, access to personal recovery data,
and base secular or Christian language remain part of the protected free
core.

Review BreakWave Plus saves navigation intent only. It does not set
PremiumState, unlock Plus, begin a trial, start checkout, restore a
purchase, or create entitlement.

While billing is not implemented, Step 10 shows no price, discount,
countdown, purchase-success message, restore-success message, or fake
checkout control. It states plainly that Plus purchasing is not yet
available.

Final completion saves the latest draft, runs the merge-safe completion
service, marks onboarding complete only after successful merges, and
clears the draft last. When Review BreakWave Plus was selected, the app
may open the existing honest Plus information screen after onboarding has
completed. Closing that screen enters the normal app; Plus remains
locked.
