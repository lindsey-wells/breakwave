# BW-87B6P Product Access Contract

## Purpose

BreakWave must establish its onboarding, Free experience, Plus
experience, and paywall rules before Google Play Billing is connected.

This document is a product and engineering contract. It does not enable
subscriptions or change access in the current testing build.

## Free experience

The following remain available without a subscription:

- Rescue and immediate urge interruption
- Basic logging
- Log history and correction
- Privacy settings and privacy lock
- Essential support resources
- Secular or Christian recovery-mode selection
- Reasons, triggers, and the personal Why
- Daily check-ins
- Recovery reminders
- Bedtime risk support
- Recovery-cycle education
- Access to review, correct, and delete the user's own saved data

Rescue must remain reachable from onboarding, paywalls, locked-feature
surfaces, and normal navigation.

## BreakWave Plus

Plus is the deeper, repeat-use recovery layer:

- 30-day and 90-day recovery insights
- Saved personal recovery plan
- Guided recovery routines with progress
- Multi-step Christian recovery journeys
- Privacy-first recovery reports and accountability exports
- Extended Christian depth content

Plus must deepen the recovery process. It must not hold urgent help,
privacy, basic logging, or access to personal data hostage.

## Onboarding architecture

A fresh installation will receive a guided setup of approximately ten
short screens:

1. Welcome, founder purpose, and immediate Rescue access
2. Local-first privacy explanation
3. Secular or Christian recovery mode
4. What the user most needs help with
5. Reasons and personal focus
6. Common triggers
7. Risky times and danger windows
8. Preferred interruption actions
9. Starter recovery plan
10. Honest Free-versus-Plus choice

Every step must provide progress, a back path, and immediate Rescue
access. Optional questions may be skipped.

Incomplete onboarding will resume safely. Completing or skipping setup
will enter the Free app without requiring payment.

Existing installations with established BreakWave data must not be
mistaken for brand-new users after an update. Legacy migration behavior
will be defined before the launch gate is connected.

## Paywall architecture

A Plus gate must:

- Name the feature the user attempted to open
- Explain what Plus adds
- State what remains free
- Offer a clear way back to the Free app
- Preserve access to Rescue
- Show actual store-provided price and billing period only
- Avoid countdowns, false scarcity, shame, or recovery-pressure tactics
- Provide Restore Purchases
- Provide subscription-management and policy links
- Never claim a purchase succeeded until entitlement verification does

## Entitlement architecture

`PremiumStateStore` is a local testing scaffold. It is not a production
billing authority.

BW-87B7 will place an entitlement service between presentation code and
Google Play Billing. The verified entitlement service will become the
only production source of Plus access.

No billing dependency, purchase button, trial claim, price, or automatic
entitlement change is introduced by BW-87B6P1.
