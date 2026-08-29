# BreakWave WP-03S — RevenueCat SDK Bootstrap

Status: **LOCAL CANDIDATE — CI REQUIRED**

Baseline: WP-03R commit `02136802599b5a286cf42d98217da7b4f696e50b`

This first WP-03S slice introduces the RevenueCat Flutter SDK boundary without
changing entitlement decisions or exposing purchase UI.

## Scope

- Pin `purchases_flutter: 10.10.1`.
- Add Android `com.android.vending.BILLING` permission.
- Add `RevenueCatBootstrap`.
- Configure RevenueCat only on Android and only when the public Android SDK key
  is supplied at build time using:
  `BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY`.
- Use RevenueCat-generated anonymous App User ID by intentionally not supplying
  a BreakWave account/user identifier.
- Start RevenueCat after `runApp` using an unawaited best-effort initialization
  so billing/network initialization cannot delay the recovery UI.
- Use debug RevenueCat logging only in Flutter debug mode; release uses info.
- Keep all existing entitlement/access seams unchanged.

## Explicitly NOT in WP-03S bootstrap

This slice adds no:

- paywall;
- offering lookup;
- purchase call;
- restore call;
- subscription product ID;
- RevenueCat entitlement ID;
- Plus access grant;
- gray/blue Plus indicator behavior;
- local trusted-entitlement snapshot;
- `verified` / `verifiedOnDevice` enforcement;
- RevenueCat service credential;
- secret/server API key;
- custom backend deployment.

Those come only after the SDK compiles and builds cleanly in CI.

## Key handling

The Android RevenueCat SDK key is a **public client SDK key**, not a server
secret. WP-03S still does not hard-code a real key into source. The first
integration build may supply it through `--dart-define` after the RevenueCat
project exists.

No Google Play service-account JSON and no RevenueCat secret/server key may
enter this repository, APK/AAB source tree, logs, evidence bundles, or chat.

## Launch invariant

**Billing failure must never become recovery failure.**

RevenueCat initialization occurs after `runApp`, is best-effort, and catches
initialization failure. Rescue and protected Free features remain independent
of RevenueCat.

## CI requirement

There is no local Flutter toolchain in the BreakWave Android/Termux workflow.
This local candidate is not green until GitHub Actions completes dependency
resolution, `flutter analyze`, Flutter tests, and Android APK/AAB build gates.

`pubspec.lock` is intentionally not hand-edited. The correct resolved lockfile
must come from the pinned Flutter toolchain rather than guessed package metadata.

## Next

After this bootstrap passes CI:

1. capture the CI-resolved lockfile deterministically;
2. add the RevenueCat project public Android SDK key to the controlled build
   configuration;
3. implement the trusted RevenueCat entitlement source with RC1K/WP-03R rules;
4. then add offerings/purchase/restore and the required gray/blue Plus UX.
