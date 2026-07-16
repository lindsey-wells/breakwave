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
