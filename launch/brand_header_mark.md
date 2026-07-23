# BreakWave — Header Brand Mark

## BW-64 history

BW-64 replaced the menu-like Material wave icon with a
Flutter-drawn circular ocean badge.

That was an intentional temporary MVP decision while the final
BreakWave branding assets were still being prepared.

## BW-88RC1B finalization

BW-88RC1B replaces the temporary painted badge and separate
BreakWave text with the approved bundled horizontal wordmark.

The production header now uses:

- `lib/core/branding/breakwave_wordmark.dart` owns the reusable widget
- `assets/branding/breakwave_in_app_header.png`
- A transparent, tightly cropped UI derivative
- The approved user-provided wave and BreakWave lettering
- The existing Home, Rescue, Log, and Support section label
- An accessible semantic label
- A text fallback if the image asset cannot load

The original supplied 2172×724 source is retained as:

- `assets/branding/breakwave_in_app_header_source.png`
