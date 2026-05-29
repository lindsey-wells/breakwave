# BreakWave — Privacy & Security Release Copy

## Plain-language privacy position

BreakWave is designed as a private, local-first recovery companion.

The MVP stores recovery information on the user's device using local app storage. This includes items such as logs, check-ins, recovery mode, privacy settings, custom why text/image path, reminder settings, trigger settings, support contact details, and optional email preferences.

BreakWave does not require an account to use the core recovery tools.

## Optional email collection

Email collection is optional.

BreakWave works without an email address. If a user chooses to save an email address, it is stored locally on the device along with separate consent choices for:

- product updates
- research / feedback invitations

The manual handoff flow opens the user's email app with a prefilled draft to `BreakWaveapp@proton.me`. The user can review, edit, send, or cancel the email before anything is sent.

## Privacy lock

BreakWave includes an app-level privacy lock.

The privacy lock uses a 6-digit PIN and can be configured to:

- keep the app unlocked
- lock the full app
- lock Log and Support while keeping Home and Rescue reachable

The privacy lock is designed to reduce casual exposure of sensitive recovery content. It is not a substitute for device-level security, encryption, medical privacy compliance, or a secure account system.

## Rescue accessibility

BreakWave intentionally allows Rescue to remain reachable in the Lock Log & Support mode.

This keeps urgent help available when the user needs fast interruption during an urge, while still protecting more sensitive screens like Log and Support.

## Failed PIN attempts

After repeated failed PIN attempts, BreakWave temporarily pauses additional unlock attempts instead of deleting user data.

Automatic data deletion is not enabled in the MVP because accidental deletion could harm user trust and remove important recovery history.

## Notifications and discreet mode

BreakWave includes privacy controls for discreet notifications and reduced Home detail.

Users can hide Home insights, hide the latest logged moment, and prefer Rescue as the safer visible path.

## Release-safe claim boundaries

Use this language:

- "privacy-conscious"
- "local-first"
- "app-level privacy lock"
- "manual email handoff"
- "helps reduce casual exposure"

Avoid this language:

- "HIPAA compliant"
- "medical-grade security"
- "fully encrypted recovery vault"
- "guaranteed anonymous"
- "impossible to access"
- "prevents cloning"
- "MFA-protected account"

## Play Store Data Safety notes

Likely launch disclosures to review in Play Console:

- optional email address
- app activity / recovery logs stored locally
- user-generated content such as custom why text and optional image
- app preferences such as reminders, triggers, privacy settings, and recovery mode
- manual sharing/export initiated by the user

Final Play Data Safety answers must match the actual app behavior and any final privacy policy.
