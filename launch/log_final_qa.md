# BW-85A Log Final QA

Log has been reviewed after the BW-84 polish run.

Covered behavior:
- Log saves Urge, Slip, and Victory entries locally on device.
- Rescue-saved Victory / Urge / Slip entries appear in Log.
- Custom Other triggers save inside entries as entry text, not permanent visible buttons.
- Custom Other replacement actions save inside entries as entry text, not permanent visible buttons.
- Recent Entries shows the latest saved entries by default.
- Log clearly states how many entries are saved locally.
- Users can switch between latest 5 and all saved entries.
- Show all entries allows older saved entries to be reviewed.
- Show latest 5 collapses the review list back to the newest entries.
- Saved entries can be edited from the recent entries list.
- Edit opens the main Log form in Update Mode.
- Update Mode is visible near the top of the Log page.
- Update Entry also shows editing clarity near the save action.
- Cancel edit returns the form to a new draft.
- Updated entries are highlighted with a blue visual treatment.
- Updated entries show the label “Updated just now.”
- Highlight clears when another entry is edited or a new entry is saved.
- Delete shows a brief undo snackbar.
- Undo restores a deleted entry when tapped in time.

Manual APK checks:
1. Save a new Urge entry.
2. Save a new Slip entry.
3. Complete Rescue and confirm the Victory appears in Log.
4. Add an Other trigger and confirm it saves inside the entry.
5. Add an Other replacement action and confirm it saves inside the entry.
6. Use Show all entries and confirm older entries are visible.
7. Use Show latest 5 and confirm the list collapses.
8. Edit a saved entry and confirm Update Mode appears at the top.
9. Confirm the Update Entry area also shows edit clarity.
10. Cancel edit and confirm the form returns to a new draft.
11. Update an entry and confirm it highlights blue with “Updated just now.”
12. Edit a different entry and confirm the old highlight clears.
13. Delete an entry and confirm Undo is briefly available.
14. Tap Undo and confirm the entry is restored.
