# BW WP-03W — Customer-facing BreakWave Plus

WP-03W turns the runtime-proven RevenueCat/BreakWave billing authority into a
simple customer experience without changing who is allowed to grant Plus.

## Customer rules

- Prices and subscription periods are displayed only from the connected store.
- No production price, discount, or trial is hard-coded.
- Purchase and restore use the existing WP-03V lifecycle.
- Purchase callbacks never grant Plus.
- The shared trusted entitlement source remains the only Plus authority.
- Active Plus is blue; inactive/review Plus is gray; no red-slash state.
- Plus feature entry points re-check access immediately before navigation.

## Production versus Test Store

Normal builds use the strict WP-03U Google Play catalog policy. The compile-time
Test Store QA build may recognize the locked Test Store products `monthly` and
`yearly` only so the customer-facing Plus UX can be tested with fake money.
This does not weaken the production catalog validator.

Test Store prices are not production pricing decisions.

## Rescue boundary

Rescue is not paywalled and does not import billing or premium code. The
persistent Plus access button is intentionally hidden while the Rescue tab is
selected. Rescue routing remains direct and independent of RevenueCat.

## Production merchant status

Production Play merchant/payment setup is still required before real-money
subscriptions can be activated. If the production catalog is unavailable, the
Plus screen says purchases are unavailable on that build and keeps Free and
Rescue usable.
