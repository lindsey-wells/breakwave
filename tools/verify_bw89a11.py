#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
HOME = ROOT / 'lib/features/home/presentation/home_screen.dart'
CARD = ROOT / 'lib/features/home/presentation/widgets/what_helped_before_card.dart'
TEST = ROOT / 'test/what_helped_before_card_test.dart'

for path in (HOME, CARD, TEST):
    if not path.is_file():
        print(f'FAIL BW-89A11A missing required file: {path.relative_to(ROOT)}')
        raise SystemExit(1)

for historical in (
    'tools/verify_bw89a9.py',
    'tools/verify_bw89a10a.py',
    'tools/verify_bw89a10b.py',
):
    result = subprocess.run(
        [sys.executable, historical],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    print(result.stdout, end='')
    if result.returncode != 0:
        print(f'FAIL BW-89A11A historical contract failed: {historical}')
        raise SystemExit(1)

home = HOME.read_text(encoding='utf-8')
card = CARD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for needle in (
    "import 'widgets/what_helped_before_card.dart';",
    'final List<String> helpfulActions = <String>[];',
    'final Set<String> seenHelpfulActions = <String>{};',
    "entry.entryType == 'Victory'",
    'entry.replacementAction.trim()',
    'helpfulActions.length < 3',
    'helpfulActions: helpfulActions',
    'final List<String> helpfulActions;',
    'summary.helpfulActions.isNotEmpty',
    '!summary.privacy.hideHomeInsights',
    'WhatHelpedBeforeCard(',
    'actions: summary.helpfulActions',
):
    if needle not in home:
        print(f'FAIL BW-89A11A Home reinforcement contract missing: {needle}')
        raise SystemExit(1)

for needle in (
    'class WhatHelpedBeforeCard',
    "'What helped before'",
    'actions you saved with past victories',
    'not predicting',
    'what will work next.',
    'You decide whether any of these fit today.',
):
    if needle not in card:
        print(f'FAIL BW-89A11A card contract missing: {needle}')
        raise SystemExit(1)

for forbidden in (
    'LogRepository',
    'PersonalRecoveryPlanStore',
    'Navigator.',
    'onPressed:',
    'riskScore',
    'probability',
    'bestAction',
    'recommendedAction',
    'PatternObservation',
):
    if forbidden in card:
        print(f'FAIL BW-89A11A card has forbidden coupling/inference: {forbidden}')
        raise SystemExit(1)

for needle in (
    'What helped before stays observational and user owned',
    "find.text('What helped before')",
    "find.textContaining('not predicting what will work next')",
    "find.text('You decide whether any of these fit today.')",
    'expect(find.byType(FilledButton), findsNothing)',
    'What helped before disappears when there is no saved evidence',
):
    if needle not in test:
        print(f'FAIL BW-89A11A widget regression contract missing: {needle}')
        raise SystemExit(1)

snapshot_index = home.find('RecoverySnapshotCard(')
helped_index = home.find('WhatHelpedBeforeCard(')
pattern_index = home.find('const PatternPictureCard()')
if not (-1 < snapshot_index < helped_index < pattern_index):
    print('FAIL BW-89A11A reinforcement card must remain in Progress, before Pattern awareness.')
    raise SystemExit(1)

picture = ROOT / 'lib/features/home/presentation/widgets/pattern_picture_card.dart'
if "'What helped before'" in picture.read_text(encoding='utf-8'):
    print('FAIL BW-89A11A Pattern Picture must remain unchanged/observational.')
    raise SystemExit(1)

print(
    'PASS: BW-89A11A Home reinforcement verified — BreakWave reuses '
    'user-saved Victory actions observationally without prediction, '
    'auto-selection, or new persistence.'
)
