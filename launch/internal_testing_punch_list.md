# BreakWave — Internal Testing Punch List

## Status

BreakWave is moving from MVP hardening into internal testing.

The app is not considered feature-complete forever. It is considered ready for structured internal testing once CI is green, APK/AAB artifacts are produced, and no P0 blockers are found.

## Punch list rules

### P0 — Must fix before internal testing

- App crash or launch failure.
- Broken Home / Rescue / Log / Support navigation.
- Rescue flow cannot be completed.
- Log entry cannot be saved, edited, or deleted.
- Support contact actions are broken.
- Privacy lock prevents Rescue from being reached when it should remain reachable.
- AAB/APK build or signing pipeline fails.
- User-facing copy claims cure, therapy replacement, HIPAA compliance, guaranteed anonymity, or medical-grade security.
- Visible placeholder, TODO, fake, or unfinished launch copy.

### P1 — Fix during internal testing

- Confusing labels.
- Messy section order.
- Too much scrolling.
- Awkward card density.
- Unclear onboarding or setup flow.
- Support organization polish.
- Log clarity and recent-entry readability.
- Founder/SlimNation punch-list items that improve trust but do not block testing.

### P2 — Post-MVP / v1.1

- Hamburger / slide-out menu.
- Advanced analytics.
- Custom dashboards.
- Full account system.
- Backend syncing.
- Server-side entitlement checks.
- Billing expansion.
- Major visual redesign.
- Deep export/reporting tools.
- New premium content packs.

## Internal testing goal

Find what breaks trust.

Testing should focus on whether a real user can:

1. Open BreakWave.
2. Choose recovery mode.
3. Use Rescue during pressure.
4. Save a Log entry quickly.
5. Add a trusted contact.
6. Save a custom why.
7. Understand privacy controls.
8. Know BreakWave is support, not therapy or a cure.

## Freeze rule

After BW-74, do not add new features unless they are required to fix a P0 blocker.
