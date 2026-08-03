#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
required = [
    'lib/core/tutorial/breakwave_tutorial_state.dart',
    'lib/core/tutorial/breakwave_tutorial_state_store.dart',
    'lib/features/tutorial/domain/breakwave_tutorial_step.dart',
    'lib/features/tutorial/presentation/teach_me_breakwave_screen.dart',
    'lib/features/support/presentation/widgets/teach_me_breakwave_entry_card.dart',
    'test/breakwave_tutorial_state_store_test.dart',
    'test/breakwave_tutorial_catalog_test.dart',
    'test/teach_me_breakwave_screen_test.dart',
    'docs/BW_ONBOARD_01B1_TUTORIAL_CONTRACT.md',
]
failed = False

for relative in required:
    if not (ROOT / relative).is_file():
        print(f'FAIL BW-ONBOARD-01B1 missing: {relative}')
        failed = True

if failed:
    sys.exit(1)

support = (ROOT / 'lib/features/support/presentation/support_screen.dart').read_text()
state_store = (ROOT / required[1]).read_text()
catalog = (ROOT / required[2]).read_text()
screen = (ROOT / required[3]).read_text()
entry = (ROOT / required[4]).read_text()
contract = (ROOT / required[8]).read_text()
state_test = (ROOT / required[5]).read_text()
screen_test = (ROOT / required[7]).read_text()

for needle in [
    "import 'widgets/teach_me_breakwave_entry_card.dart';",
    'BW-ONBOARD-01B inserts the replayable tutorial first here.',
    'TeachMeBreakWaveEntryCard()',
]:
    if needle not in support:
        print(f'FAIL BW-ONBOARD-01B1 Support missing: {needle}')
        failed = True

placeholder = support.find('BW-ONBOARD-01B inserts the replayable tutorial first here.')
entry_position = support.find('TeachMeBreakWaveEntryCard()')
cbt_position = support.find('CbtInformedSupportCard()')
if not (placeholder < entry_position < cbt_position):
    print('FAIL BW-ONBOARD-01B1 tutorial is not first in the learning group')
    failed = True

for needle in [
    "storageKey = 'bw_tutorial_state_v1'",
    'SharedPreferences',
    'saveProgress',
    'complete',
    'final BreakWaveTutorialState existing = await load(now: now);',
    'completed: existing.completed',
    'completedAtIso: existing.completedAtIso',
]:
    if needle not in state_store:
        print(f'FAIL BW-ONBOARD-01B1 state store missing: {needle}')
        failed = True

for needle in [
    'BreakWaveAccessPolicy.accessClassFor',
    'BreakWaveFeature.onboarding',
    'BreakWaveFeature.rescueNow',
    'BreakWaveFeature.basicLogging',
    'BreakWaveFeature.advancedRecoveryInsights',
    'RecoveryMode.christian',
    'Always free:',
    'Plus candidates:',
]:
    if needle not in catalog:
        print(f'FAIL BW-ONBOARD-01B1 catalog missing: {needle}')
        failed = True

for needle in [
    'class TeachMeBreakWaveScreen',
    'WillPopScope',
    'RecoveryModeStore.loadMode()',
    'BreakWaveTutorialStateStore.load()',
    'BreakWaveTutorialStateStore.saveProgress',
    'BreakWaveTutorialStateStore.complete()',
    "const Text('Exit tour')",
    "? 'Finish tour'",
]:
    if needle not in screen:
        print(f'FAIL BW-ONBOARD-01B1 screen missing: {needle}')
        failed = True

for needle in [
    'Teach Me How to Use BreakWave',
    'Start quick tour',
    'Review quick tour',
    'TeachMeBreakWaveScreen',
]:
    if needle not in entry:
        print(f'FAIL BW-ONBOARD-01B1 entry missing: {needle}')
        failed = True

for forbidden in [
    'OnboardingStateStore',
    'OnboardingCompletionService',
    'PremiumStateStore',
    'openOnboardingRescue',
    'launchUrl',
    'SupportContactStore',
]:
    combined = '\n'.join([state_store, catalog, screen, entry])
    if forbidden in combined:
        print(f'FAIL BW-ONBOARD-01B1 forbidden cross-scope dependency: {forbidden}')
        failed = True

for needle, source in [
    (
        'completed replay stays completed when progress changes',
        state_test,
    ),
    (
        'replaying after completion keeps completed status',
        screen_test,
    ),
]:
    if needle not in source:
        print(f'FAIL BW-ONBOARD-01B1 replay regression missing: {needle}')
        failed = True

for needle in [
    'No post-onboarding invitation is added in BW-ONBOARD-01B1.',
    'Practice Rescue is reserved for BW-ONBOARD-01B2.',
    'The tutorial never changes onboarding, entitlement, Log, insight, streak, or recovery data.',
    'Rescue remains available regardless of tutorial state.',
    'A completed tutorial remains completed during partial replay.',
]:
    if needle not in contract:
        print(f'FAIL BW-ONBOARD-01B1 contract missing: {needle}')
        failed = True

if failed:
    sys.exit(1)

print('PASS: BW-ONBOARD-01B1 tutorial foundation boundaries verified.')
