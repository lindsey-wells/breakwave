# BreakWave WP-03V — RevenueCat Purchase + Restore Lifecycle

Status: **LOCAL CANDIDATE — SHADOW CI + TEST STORE DEVICE VALIDATION REQUIRED**

WP-03V introduces RevenueCat purchase/restore transport without adding a
paywall or Plus UI.

## Authority

A successful purchase or restore callback is **not** BreakWave Plus authority.

After RevenueCat reports transport completion, BreakWave separately asks the
existing WP-03T trusted entitlement source for Plus state. If that trusted
CustomerInfo path does not positively authorize Plus, access remains locked.

The direct `PurchaseResult.customerInfo` and the `CustomerInfo` returned from
`restorePurchases()` are intentionally ignored for authorization.

## SDK API

The app remains pinned to `purchases_flutter 10.10.1`.

WP-03V uses:

- `Purchases.purchase(PurchaseParams.package(package))`
- `Purchases.restorePurchases()`

## Offering/package contract

Offering:

`default`

RevenueCat packages:

- `$rc_monthly`
- `$rc_annual`

Current Test Store QA products:

- `monthly`
- `yearly`

The Test Store product identifiers are QA-only constants and are not Google Play
product identifiers.

## Purchase outcomes

Purchase transport can result in:

- completed;
- cancelled;
- package unavailable;
- failed.

Only `completed` causes a trusted entitlement re-read. Cancellation, package
absence, and transport failure remain locked.

## Restore

RevenueCat restore is supported. Completion still requires a separate trusted
entitlement read before Plus is returned.

The project restore behavior remains **Transfer to new App User ID** for the
anonymous/no-login model.

## Test Store

RevenueCat Test Store works without Google Play merchant configuration and can
simulate success, failure, and cancellation. Test subscriptions also renew and
expire on accelerated schedules.

A dedicated Test Store QA build will pass the Test Store public SDK key through
the existing build-time seam:

`BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY`

The Test Store key is not included in this package, repository, documentation,
or evidence. It must never ship in a production Google Play artifact.

## Android flow

BreakWave already uses:

`android:launchMode="singleTop"`

which is compatible with RevenueCat's Android purchase flow when users
temporarily background the app.

## UI scope

WP-03V adds no paywall, purchase button, restore button, Plus icon, Rescue
monetization, production price, or trial copy.

## Deterministic lockfile closure

The committed `pubspec.lock` predates the RevenueCat dependency. Successful
Shadow jobs have therefore been resolving a newer lockfile only inside CI.

WP-03V adds a Shadow step that copies the CI-resolved `pubspec.lock` into
`shadow_evidence/pubspec.lock.resolved` and also records its SHA-256.

After the first green WP-03V Shadow run, that exact lockfile will be committed
in a narrow closure commit and Shadow will run again. WP-03V is not fully closed
until that deterministic rerun succeeds.

## Gates

1. Local static verification.
2. Shadow CI compiles the real 10.10.1 API and runs all tests.
3. Retrieve and commit the exact CI-resolved lockfile.
4. Deterministic Shadow rerun.
5. Dedicated non-production Test Store QA APK.
6. On-device Test Store: success, cancel, simulated failure, restore, renewal,
   and expiration.
7. Then WP-03W blue/gray Plus entry point.
