# BreakWave WP-03U — RevenueCat Production Configuration + Catalog

Status: **LOCAL CANDIDATE — SHADOW CI + DASHBOARD CONFIGURATION REQUIRED**

## Purpose

WP-03U establishes stable production identifiers and adds a read-only
RevenueCat catalog validator. It does not purchase, restore, show a paywall, or
change BreakWave Plus entitlement policy.

## Locked identifiers

| Layer | Identifier |
|---|---|
| Google Play subscription | `breakwave_plus_v1` |
| RevenueCat entitlement | `breakwave_plus` |
| RevenueCat launch Offering | `default` |

For Google Play subscriptions under the modern base-plan model, RevenueCat
products are expected to use:

`breakwave_plus_v1:<base-plan-id>`

The base-plan ID is intentionally not locked in this package. Billing cadence,
price, and trial terms are business/store decisions and are not silently
invented by WP-03U.

## Google Play Console setup

1. Open BreakWave in Play Console.
2. Go to Monetize with Play → Products → Subscriptions.
3. Create the subscription:
   - Product ID: `breakwave_plus_v1`
   - User-facing name: `BreakWave Plus`
4. Do not activate an arbitrary base plan merely to satisfy this package.
5. Once launch cadence is approved, create at least one auto-renewing base plan
   with a clear lowercase/hyphen ID and its store price.
6. Activate only after its period and price are correct.

Google Play product IDs cannot be changed or reused after creation. Base-plan
IDs likewise should be planned before activation.

The app must display the store-provided price and billing period. WP-03U has no
hard-coded production price or trial claim.

## RevenueCat dashboard setup

Use the existing Android RevenueCat app for:

`com.cube23.breakwave`

The Flutter client receives only the RevenueCat public Android SDK key. No
RevenueCat secret/server key and no Google service-account JSON belong in the
app, repository, CI logs, evidence bundles, or chat.

Create or confirm the entitlement:

`breakwave_plus`

Attach each approved BreakWave Plus Google Play base-plan product to it.

For each activated Play base plan, import/add:

`breakwave_plus_v1:<base-plan-id>`

Create or confirm the Offering:

`default`

Make `default` the current launch Offering and add at least one Package pointing
to an approved `breakwave_plus_v1:<base-plan-id>` product.

WP-03U does not require `$rc_monthly`, `$rc_annual`, or a custom duration package
until the actual launch cadence is approved.

## Runtime catalog validation

`RevenueCatCatalogService` calls `Purchases.getOfferings()` and checks:

- RevenueCat is configured;
- Offering `default` exists;
- `default` is current for launch;
- at least one Package exists;
- Package identifiers are unique;
- every Package maps to `breakwave_plus_v1:<non-empty-base-plan-id>`;
- each Package has a store-provided localized price;
- each Package has a store-provided billing period.

This is read-only. It cannot purchase anything.

## Entitlement source alignment

`RevenueCatEntitlementSource.production()` keeps:

`BREAKWAVE_REVENUECAT_PLUS_ENTITLEMENT_ID`

as an override seam, but defaults to:

`breakwave_plus`

so an absent dart-define no longer means a blank production entitlement ID.

## What cannot be proved pre-purchase

The Flutter Offerings response does not prove that a RevenueCat Product is
attached to `breakwave_plus`. That relationship lives in RevenueCat dashboard
configuration.

Final product → entitlement proof therefore requires:

1. dashboard configuration review;
2. a real Google Play test purchase;
3. server-verified CustomerInfo with active `breakwave_plus`.

That belongs to the later purchase/restore lifecycle gate.

## Explicitly absent

No purchase call, restore call, sync purchase call, paywall UI, hard-coded
production price, hard-coded trial, hard-coded billing cadence, Plus status
icon, RevenueCat secret key, or Google service credential is introduced.

## Next gates

1. Local static evidence.
2. Shadow CI.
3. Create/confirm locked Play and RevenueCat identifiers.
4. Decide launch base-plan cadence and store price before activation.
5. Validate the live RevenueCat catalog.
6. Proceed to purchase + restore.
