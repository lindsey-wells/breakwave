# BreakWave WP-03V-T1 — Billing Composition + Test Store QA Console

Status: **LOCAL CANDIDATE — SHADOW CI REQUIRED**

## Purpose

WP-03V built and proved the RevenueCat purchase/restore engine, but BreakWave did
not yet have a visible purchase entry point or a single app-level billing
composition.

WP-03V-T1 adds the bridge needed before device Test Store testing:

1. one shared trusted entitlement source for both feature access and
   purchase/restore lifecycle;
2. an internal Billing QA console that can call the real WP-03V lifecycle;
3. a compile-time gate that keeps the QA console absent from normal builds.

This slice does **not** build the dedicated Test Store APK/workflow yet. That is
WP-03V-T2.

## Shared billing composition

`BreakWaveBillingComposition.production()` creates one
`RevenueCatEntitlementSource.production()` instance.

That same object is passed to:

- `BreakWaveAccessService`;
- `RevenueCatPurchaseLifecycleService`.

The purchase path therefore cannot use one entitlement authority while feature
access uses another.

Free and never-paywalled behavior is unchanged. The existing access service
still resolves Rescue and other Free features before consulting entitlement
state.

`BreakWaveApp` owns the production composition and exposes it through
`BreakWaveBillingScope`.

RevenueCat bootstrap remains best-effort and asynchronous after app launch.

## QA build gate

The console is controlled only by:

`BREAKWAVE_REVENUECAT_TEST_STORE_QA`

using `bool.fromEnvironment(..., defaultValue: false)`.

Normal builds are therefore OFF by default.

The presence of an SDK key does not automatically enable QA UI.

Both the QA screen and its shell navigation destination are guarded by the same
compile-time flag.

## Billing QA console

When the QA flag is enabled, the shell gains a fifth internal destination:

`Billing QA`

The screen is unmistakably labeled:

`TEST STORE QA — NO REAL MONEY`

It reports:

- whether RevenueCat is configured;
- current Offering identifier;
- whether the Test Store catalog matches the expected QA contract;
- returned package identifiers;
- returned Test Store product identifiers;
- store-supplied price strings;
- store-supplied billing periods;
- current trusted access state: FREE or PLUS;
- last purchase/restore lifecycle result.

Actions:

- Buy Monthly;
- Buy Annual;
- Restore Purchases;
- Refresh Trusted Entitlement.

The presentation layer never calls RevenueCat purchase APIs directly. It calls
`BreakWaveBillingQaController`, which calls the already-proven WP-03V lifecycle.

## Separate QA catalog validation

The production WP-03U catalog validator intentionally requires Google products
in the form:

`breakwave_plus_v1:<base-plan-id>`

That validator must remain unchanged.

The Test Store currently uses:

- `$rc_monthly` -> `monthly`
- `$rc_annual` -> `yearly`

T1 therefore checks the raw `RevenueCatCatalogProvider` snapshot against a
separate Test Store QA contract. It does not call the production catalog
validator.

The QA catalog also requires store-supplied price and billing-period metadata.
No production price or trial is hard-coded.

## Authority rules remain unchanged

A purchase or restore transport callback is not Plus authority.

WP-03V still performs the trusted entitlement read. The QA controller displays
the lifecycle result and trusted state; it does not invent an entitlement.

For cancellation, package absence, or transport failure, the controller may
refresh current trusted state for accurate status display. That refresh does
not turn the failed/cancelled transaction into authority.

## Security and isolation

T1 contains no Test Store SDK key and no production SDK key.

The GitHub secret created for Test Store QA remains outside source control.
WP-03V-T2 will inject it only into the dedicated QA workflow.

T1 does not change:

- Android application ID;
- GitHub Actions workflow;
- production RevenueCat key seam;
- Google Play product configuration;
- Rescue;
- customer-facing Plus UI.

## Not customer UI

The Billing QA console is an internal engineering surface, not the BreakWave
Plus paywall.

WP-03W remains responsible for the eventual customer experience:

- gray Plus indicator when inactive;
- blue Plus indicator when verified active;
- customer-facing benefits and purchase choices;
- restore access;
- transparent terms/cancellation.

## Required verification

T1 tests prove:

- the QA flag defaults to false;
- Rescue does not read entitlement state;
- Plus access and purchase lifecycle share one entitlement source;
- composition disposal is idempotent;
- valid Test Store catalog is accepted;
- missing/mismatched packages fail QA readiness;
- monthly purchase delegates through WP-03V lifecycle;
- cancellation does not fabricate purchase activation;
- restore delegates through WP-03V lifecycle;
- catalog failure degrades safely.

## Next

1. Local static verification.
2. Push T1 branch and run Shadow CI.
3. If green, WP-03V-T2 adds a separate QA Android identity and dedicated
   workflow.
4. T2 injects the Test Store public SDK key only from GitHub Actions secret.
5. Install QA APK alongside normal BreakWave.
6. Exercise Test Store SUCCESS / CANCEL / FAIL / RESTORE / RENEW / EXPIRE.
7. Only after Test Store behavior is proven, build WP-03W customer Plus UI.
