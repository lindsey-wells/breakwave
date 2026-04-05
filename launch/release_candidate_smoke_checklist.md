# BreakWave — Release Candidate Smoke Checklist

## Rules
- Focus only on launch-critical trust issues
- Do not open new feature scope here
- Log blockers clearly and defer non-blockers

---

## 1) First-run and recovery mode
- [ ] Fresh install / clean state opens correctly
- [ ] Recovery mode selection appears when expected
- [ ] Secular mode persists after app relaunch
- [ ] Christian mode persists after app relaunch

## 2) Home → Rescue → Log core loop
- [ ] Fast urge entry from Home saves an Urge entry
- [ ] Fast urge entry routes into Rescue
- [ ] Completing Rescue returns Home
- [ ] Returning to Log shows the latest entry immediately
- [ ] Tapping Home again refreshes Home surfaces correctly

## 3) Logging and history trust
- [ ] Manual Urge save returns Home
- [ ] Manual Slip save returns Home
- [ ] Manual Victory save returns Home
- [ ] Edit log entry works
- [ ] Delete log entry works
- [ ] Recent history updates correctly

## 4) Daily check-in / bedtime / widget sync
- [ ] Daily check-in saves today’s status
- [ ] Daily check-in snackbar wording is clear
- [ ] Bedtime steady save works
- [ ] Bedtime risky save works
- [ ] Bedtime risky can route into Rescue
- [ ] Home widget reflects updated daily/bedtime state

## 5) Reminders / privacy resilience
- [ ] Reminder settings save locally
- [ ] Reminder save feedback is accurate if scheduling fails
- [ ] Privacy settings save locally
- [ ] Privacy settings update Home visibility
- [ ] Discreet notifications path does not break save flow

## 6) Premium routing
- [ ] Premium gate tile opens BreakWave Plus when locked
- [ ] Debug unlock updates premium-gated entry behavior
- [ ] Deeper insights gate routes correctly
- [ ] Faith depth premium gate routes correctly

## 7) Christian / secular path sanity
- [ ] Christian Rescue cards appear in Christian mode
- [ ] Secular Rescue cards appear in secular mode
- [ ] Christian Faith Depth pack is available only when Christian mode is active
- [ ] Christian wording feels explicitly Christian, not generic
- [ ] Secular wording feels practical and direct

## 8) Support and learning surfaces
- [ ] Trusted contact save works
- [ ] Quick support message copy works
- [ ] Educate Me opens
- [ ] Recovery Cycle Wheel opens
- [ ] Faith Depth screen handles locked/unlocked states correctly

## 9) Launch blockers only
Mark an item as a blocker only if it breaks:
- core rescue trust
- save reliability
- routing reliability
- premium gate correctness
- notification/privacy safety
