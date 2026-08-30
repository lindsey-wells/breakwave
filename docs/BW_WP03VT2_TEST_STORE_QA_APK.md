# BreakWave WP-03V-T2 — Isolated RevenueCat Test Store QA APK

## Purpose

T1 wired the real RevenueCat purchase/restore lifecycle into a compile-time-gated
Billing QA console. T2 creates an installable Android QA artifact that enables
that console and uses RevenueCat Test Store without changing the production Play
identity.

## Android identity

Production default:

- application ID: `com.cube23.breakwave`
- application label: `BreakWave`

Test Store QA lane:

- application ID: `com.cube23.breakwave.teststoreqa`
- application label: `BreakWave Test Store`

The Kotlin namespace remains `com.cube23.breakwave`. Android native component
names are fully qualified in the manifest so the alternate application ID does
not redirect `.MainActivity` or the home-widget provider into a nonexistent
package.

## QA flags

The dedicated workflow builds with:

- Gradle property `breakwaveTestStoreQa=true`
- Dart define `BREAKWAVE_REVENUECAT_TEST_STORE_QA=true`
- Dart define `BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY=<Test Store key>`

The Test Store public SDK key comes only from GitHub Actions secret:

`BREAKWAVE_REVENUECAT_TEST_STORE_PUBLIC_SDK_KEY`

The workflow writes it to a mode-0600 file under `RUNNER_TEMP`, uses
`--dart-define-from-file`, then deletes the temporary file. The value is never
written to tracked source or QA evidence. Like all RevenueCat public SDK keys,
the key is necessarily present in the compiled QA client that uses it; this
artifact is Test Store QA only and must never be distributed as the production
Play build.

## Startup behavior

Production remains non-blocking: the normal build starts BreakWave and
initializes RevenueCat asynchronously.

Only when `BREAKWAVE_REVENUECAT_TEST_STORE_QA=true` does `main.dart` await
RevenueCat initialization before creating the app tree. This gives the Billing
QA console a deterministic configured SDK at first use.

## Dedicated workflow

`.github/workflows/breakwave-test-store-qa.yml` uses two triggers:

- `workflow_dispatch` for normal manual QA once the workflow exists on the
  repository default branch;
- a pre-merge `push` bootstrap scoped only to
  `billing/wp-03vt2-test-store-qa-apk`, because GitHub does not allow
  `workflow_dispatch` to address a workflow that is absent from the default
  branch.

The branch-scoped bootstrap does not run from `main` and exists only to prove
the dedicated Test Store QA lane before T2 is merged.

It:

1. requires the Test Store GitHub secret without printing it;
2. gets dependencies;
3. runs WP-03V, T1, and T2 static verifiers;
4. runs Flutter analyze;
5. runs the full Flutter test suite;
6. builds only a release APK with QA identity and QA Dart defines;
7. uses no production signing secrets;
8. validates the APK package ID and label with Android `aapt`;
9. proves the key value did not enter tracked source;
10. uploads an evidence artifact with no key value;
11. uploads the isolated QA APK.

It does not build an AAB.

## Required gates

T2 is not device-ready until BOTH are green at the exact T2 commit:

1. standard `breakwave-shadow-ci.yml`
   - proves ordinary BreakWave still builds with production identity/default QA
     flag off;
2. `breakwave-test-store-qa.yml`
   - proves isolated QA identity, full tests, and installable Test Store APK.

## Device QA sequence after CI

The first runtime pass should capture, in order:

1. launch the **BreakWave Test Store** app alongside normal BreakWave;
2. open **Billing QA**;
3. confirm `RevenueCat configured = YES`;
4. confirm current Offering is `default`;
5. confirm catalog maps:
   - `$rc_monthly` -> `monthly`
   - `$rc_annual` -> `yearly`;
6. confirm initial trusted access is `FREE`;
7. Buy Monthly;
8. inspect lifecycle result + trusted access;
9. exercise cancel/failure;
10. restore;
11. exercise annual;
12. use RevenueCat Test Store controls/dashboard to exercise renewal and expiry;
13. verify trusted access follows RevenueCat state and never unlocks from a
    purchase callback alone.

## Not included

T2 still does not introduce:

- customer-facing BreakWave Plus paywall;
- gray/blue Plus shell icon;
- Google Play production base plans;
- production prices/trials;
- production Google merchant setup;
- Rescue monetization.

Those remain later gates.
