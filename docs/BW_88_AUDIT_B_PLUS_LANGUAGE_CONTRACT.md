# BW-88 Audit B — BreakWave Plus Language Contract

## Purpose

This contract governs BreakWave Plus language before Google Play
Billing, real purchase restoration, and verified production
entitlements are operational.

It does not add billing, pricing, trials, checkout, restoration, or
subscription-management behavior.

## Current testing-build language

BreakWave may describe:

- BreakWave Plus as in development
- working Plus tools as previews
- protected Free features
- the product standard required before paid launch
- features planned for BreakWave Plus
- the fact that purchasing is not available yet

Current user-facing surfaces must not imply that a user can presently:

- buy or subscribe
- start a trial
- restore a purchase
- receive a verified Plus entitlement
- complete checkout
- see a confirmed store price
- manage a subscription
- receive purchase-success or restore-success confirmation

## Preview and gate wording

Before billing is operational:

- A working test-build feature may say `Preview available`.
- A future or inaccessible Plus feature may say
  `Planned for BreakWave Plus`.
- A navigation action may say `Review BreakWave Plus`.
- A gate must not say `Unlocked`, `Open BreakWave Plus`, or
  `Available in BreakWave Plus` when no real purchase or verified
  entitlement path exists.
- Relevant surfaces must state that purchasing is not available yet.

## Pricing language

BreakWave must not hardcode or promise launch prices in production
presentation code.

Plan structure and pricing remain undecided until:

1. the billing architecture is approved
2. Google Play products are configured
3. store-provided product details are available
4. purchase and lifecycle testing is complete
5. the paid-launch gate is approved

If multiple billing periods are eventually offered, they should not
create different levels of core recovery access.

## Restore Purchases language

Restore Purchases remains a future production requirement.

Before restoration is implemented and tested, BreakWave must not expose
a control or message that implies restoration can be started or has
succeeded.

## Historical and internal references

Tests, verifiers, and engineering contracts may contain obsolete prices
or purchase phrases when those strings are explicitly used as forbidden
regression markers.

Those references must not appear as active user-facing purchase claims.

## Safety rule

Billing language must never pressure a user during an urge or imply that
payment is required for Rescue, basic recovery support, privacy,
human-support information, or access to the user's own recovery data.
