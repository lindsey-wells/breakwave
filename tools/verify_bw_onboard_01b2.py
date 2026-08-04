#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
required = [
    'lib/core/tutorial/breakwave_tutorial_invitation_store.dart',
    'lib/features/tutorial/presentation/teach_me_breakwave_invitation_dialog.dart',
    'lib/features/tutorial/presentation/practice_rescue_screen.dart',
    'lib/core/onboarding/onboarding_launch_gate.dart',
    'lib/features/tutorial/presentation/teach_me_breakwave_screen.dart',
    'test/breakwave_tutorial_invitation_store_test.dart',
    'test/onboarding_tutorial_invitation_test.dart',
    'test/practice_rescue_screen_test.dart',
    'test/teach_me_breakwave_practice_route_test.dart',
    'docs/BW_ONBOARD_01B2_INVITATION_PRACTICE_CONTRACT.md',
]
failed = False

for relative in required:
    if not (ROOT / relative).is_file():
        print(f'FAIL BW-ONBOARD-01B2 missing: {relative}')
        failed = True

if failed:
    sys.exit(1)

store = (ROOT / required[0]).read_text()
dialog = (ROOT / required[1]).read_text()
practice = (ROOT / required[2]).read_text()
gate = (ROOT / required[3]).read_text()
tutorial = (ROOT / required[4]).read_text()
invitation_test = (ROOT / required[6]).read_text()
practice_test = (ROOT / required[7]).read_text()
route_test = (ROOT / required[8]).read_text()
contract = (ROOT / required[9]).read_text()

for needle in [
    "storageKey = 'bw_tutorial_invitation_choice_v1'",
    'BreakWaveTutorialInvitationChoice.accepted',
    'BreakWaveTutorialInvitationChoice.declined',
    'shouldOffer',
]:
    if needle not in store:
        print(f'FAIL BW-ONBOARD-01B2 invitation store missing: {needle}')
        failed = True

for needle in [
    'Would you like a quick tour?',
    'Show me',
    "I'll explore myself",
    'barrierDismissible: false',
]:
    if needle not in dialog:
        print(f'FAIL BW-ONBOARD-01B2 invitation dialog missing: {needle}')
        failed = True

for needle in [
    '_runPostOnboardingFlow',
    'if (openPlus)',
    'await Navigator.of(context).push<void>',
    'BreakWaveTutorialInvitationStore.shouldOffer()',
    'showTeachMeBreakWaveInvitation(context)',
    'TeachMeBreakWaveScreen',
]:
    if needle not in gate:
        print(f'FAIL BW-ONBOARD-01B2 launch gate missing: {needle}')
        failed = True

plus_position = gate.find('if (openPlus)')
invitation_position = gate.find('BreakWaveTutorialInvitationStore.shouldOffer()')
if not (0 <= plus_position < invitation_position):
    print('FAIL BW-ONBOARD-01B2 Plus handoff is not preserved before invitation')
    failed = True

for needle in [
    'Practice Rescue — No Save',
    'PRACTICE MODE',
    'No Log entry, insight, streak, plan, Personal Why, message, call, or emergency action',
    'Practice only. No message was opened.',
    "key: const Key('practice-rescue-exit')",
    "key: const Key('practice-rescue-finish')",
    'UrgeIntensitySection',
    'CalmResetCard',
    'CustomWhyStore.load()',
]:
    if needle not in practice:
        print(f'FAIL BW-ONBOARD-01B2 practice screen missing: {needle}')
        failed = True

for forbidden in [
    'LogRepository',
    'saveEntry',
    'SupportContactActions',
    'launchUrl',
    'EmergencyHelpCard',
    'CustomWhyStore.save',
    'BreakWaveTutorialStateStore.saveProgress',
    'OnboardingStateStore',
    'PremiumStateStore',
]:
    if forbidden in practice:
        print(f'FAIL BW-ONBOARD-01B2 practice side effect dependency: {forbidden}')
        failed = True

for needle in [
    "'teach-me-breakwave-practice-rescue'",
    'PracticeRescueScreen',
    'Practice complete. No Log entry, message, call, or recovery data was saved.',
]:
    if needle not in tutorial:
        print(f'FAIL BW-ONBOARD-01B2 tutorial route missing: {needle}')
        failed = True

for needle, source in [
    ('Continue Free shows one optional tutorial invitation', invitation_test),
    ('Review Plus remains first, then invitation appears', invitation_test),
    ('practice is labeled, interactive, and writes nothing', practice_test),
    ('Exit practice leaves immediately without writes', practice_test),
    ('Rescue tutorial opens sandbox and returns to Part 2', route_test),
]:
    if needle not in source:
        print(f'FAIL BW-ONBOARD-01B2 regression missing: {needle}')
        failed = True

for needle in [
    'Established users are not retroactively interrupted by it.',
    'the existing Plus information handoff opens first',
    'create or edit a Log entry',
    'open messaging, calling, emergency, Support, or other external actions',
    'Android Back and **Exit practice** leave immediately.',
    'does not change the real Rescue completion path',
]:
    if needle not in contract:
        print(f'FAIL BW-ONBOARD-01B2 contract missing: {needle}')
        failed = True

if failed:
    sys.exit(1)

print('PASS: BW-ONBOARD-01B2 invitation, Plus ordering, and Practice Rescue sandbox verified.')
