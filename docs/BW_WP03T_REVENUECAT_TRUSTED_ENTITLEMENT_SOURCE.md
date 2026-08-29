# BreakWave WP-03T — RevenueCat Trusted Entitlement Source

Status: **LOCAL CANDIDATE — SHADOW CI REQUIRED**

## Goal

Wire RevenueCat CustomerInfo into the existing
`BreakWaveEntitlementSource` contract without introducing purchase UI or making
a purchase callback authoritative.

## Trust rule

Only RevenueCat `VerificationResult.verified` may create or replace a positive
BreakWave Plus authorization.

- `verified` — may authorize Plus when the configured entitlement is active and
  has a usable expiration.
- `verifiedOnDevice` — never creates or extends BreakWave Plus. A previously
  accepted server-verified state may continue only until its already-stored
  BreakWave deadline.
- `notRequested` — no Plus.
- `failed` — no Plus.

The bootstrap explicitly configures
`EntitlementVerificationMode.informational`; BreakWave performs the enforcement.

## Freshness and offline ceilings

A trusted positive state stores only:

- accepted RevenueCat server request time;
- positive/negative authority bit;
- BreakWave valid-until time;
- last observed device time.

No recovery data and no raw purchase token are stored.

For `verified` active entitlement data:

- normal active/canceled-but-unexpired authorization is capped at 72 hours from
  RevenueCat `CustomerInfo.requestDate`;
- a detected billing issue is capped at 24 hours;
- the RevenueCat entitlement expiration always wins if it occurs sooner.

RevenueCat's `TEMPORARY_ENTITLEMENT_GRANT` webhook event is not exposed as a
separate field in Flutter `CustomerInfo`. RevenueCat bounds that server-issued
grant by its entitlement expiration. BreakWave never extends authorization past
the signed entitlement expiration; therefore a RevenueCat temporary grant with
a <=24-hour expiration cannot become a longer BreakWave authorization.

## Stale and clock defense

- An older or equal `CustomerInfo.requestDate` cannot replace a newer accepted
  BreakWave state.
- A stale positive cannot restore Plus after a newer accepted negative.
- A stale negative cannot destroy a newer trusted positive.
- Device clock rollback below the last observed device time or accepted server
  request time fails closed for Plus.
- A RevenueCat request time in the future relative to the device clock fails
  closed.
- Device time can shorten access but cannot extend the stored valid-until time.

## RevenueCat outage

If CustomerInfo cannot be loaded, BreakWave may use only the last persisted
server-verified positive state and only while its existing valid-until deadline
has not elapsed.

If trusted-state persistence fails, a new positive authorization is denied.

## Free and Rescue safety

The existing `BreakWaveAccessService` resolves Never Paywalled, Protected Free,
and Free Support classes before it reads the entitlement source.

WP-03T adds a test proving `rescueNow` does not call the RevenueCat observation
provider even when RevenueCat is unavailable.

Billing failure must never become recovery failure.

## Configuration

No real subscription product ID is introduced.

The RevenueCat Plus entitlement identifier is supplied later with:

`BREAKWAVE_REVENUECAT_PLUS_ENTITLEMENT_ID`

If that value is absent or blank, the production RevenueCat entitlement source
fails closed for Plus without contacting RevenueCat.

## Explicitly absent

WP-03T adds no:

- offering lookup;
- purchase call;
- purchase callback authority;
- restore call;
- paywall;
- RevenueCat Paywalls UI SDK;
- real Google Play subscription product ID;
- gray/blue Plus icon;
- Google service-account credential;
- RevenueCat secret/server key;
- custom backend deployment.

## CI gate

No local Flutter is run in Termux.

Shadow CI must prove:

- `flutter pub get`;
- changed/new verifier;
- historical phase-aware verifier suite;
- `flutter analyze`;
- new WP-03T Flutter tests;
- full Flutter test suite;
- release APK;
- release AAB;
- artifact contract checks.

Only after that is WP-03T CI-proven.
