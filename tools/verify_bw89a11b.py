#!/usr/bin/env python3
from pathlib import Path
import hashlib
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
HOME = ROOT / 'lib/features/home/presentation/home_screen.dart'
PICTURE = ROOT / 'lib/features/home/presentation/widgets/pattern_picture_card.dart'
CARD = ROOT / 'lib/features/home/presentation/widgets/pattern_helpful_actions_card.dart'
TEST = ROOT / 'test/pattern_helpful_actions_card_test.dart'

BASE_PATTERN_PICTURE_SHA256 = (
    '954f44ff1763bf5496df46371b9a5ddae2190de6c0f103ee7a9ae98d214083e7'
)

for path in (HOME, PICTURE, CARD, TEST):
    if not path.is_file():
        print(f'FAIL BW-89A11B missing required file: {path.relative_to(ROOT)}')
        raise SystemExit(1)

for historical in (
    'tools/verify_bw89a9.py',
    'tools/verify_bw89a10a.py',
    'tools/verify_bw89a10b.py',
    'tools/verify_bw89a11.py',
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
        print(f'FAIL BW-89A11B historical contract failed: {historical}')
        raise SystemExit(1)

home = HOME.read_text(encoding='utf-8')
card = CARD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

picture_sha = hashlib.sha256(PICTURE.read_bytes()).hexdigest()
if picture_sha != BASE_PATTERN_PICTURE_SHA256:
    print(
        'FAIL BW-89A11B protected Recognize core drift: '
        f'pattern_picture_card.dart expected {BASE_PATTERN_PICTURE_SHA256} '
        f'got {picture_sha}'
    )
    raise SystemExit(1)

for needle in (
    "import 'widgets/pattern_helpful_actions_card.dart';",
    'final Map<String, int> helpfulActionCounts = <String, int>{};',
    "entry.entryType == 'Victory'",
    'entry.replacementAction.trim()',
    'helpfulActionCounts[action] =',
    '(helpfulActionCounts[action] ?? 0) + 1',
    'helpfulActionCounts: helpfulActionCounts',
    'final Map<String, int> helpfulActionCounts;',
    'summary.helpfulActionCounts.isNotEmpty',
    '!summary.privacy.hideHomeInsights',
    'PatternHelpfulActionsCard(',
    'actionCounts: summary.helpfulActionCounts',
):
    if needle not in home:
        print(f'FAIL BW-89A11B Home reinforcement lens missing: {needle}')
        raise SystemExit(1)

picture_index = home.find('const PatternPictureCard()')
reinforce_index = home.find('PatternHelpfulActionsCard(')
prepare_index = home.find('PatternPrepareCard(')
if not (-1 < picture_index < reinforce_index < prepare_index):
    print(
        'FAIL BW-89A11B Reinforce lens must sit after the protected '
        'Pattern Picture and before Prepare.'
    )
    raise SystemExit(1)

for needle in (
    'class PatternHelpfulActionsCard',
    "'Actions you recorded as helpful'",
    "'From confirmed victories'",
    'These counts show only what you recorded after victories.',
    'do not prove what caused the outcome',
    'predict what ',
    'will work next.',
    'You decide whether any of these fit a future wave.',
    'actionCounts.entries.take(3)',
    "'Recorded as helpful in 1 victory.'",
    "'Recorded as helpful in $count victories.'",
):
    if needle not in card:
        print(f'FAIL BW-89A11B card contract missing: {needle}')
        raise SystemExit(1)

for forbidden in (
    'LogRepository',
    'PersonalRecoveryPlan',
    'Navigator.',
    'onPressed:',
    'riskScore',
    'risk_score',
    'probability',
    'likelihood',
    'recommendedAction',
    'bestAction',
    'should use',
    'will help you',
):
    if forbidden in card:
        print(f'FAIL BW-89A11B card has forbidden coupling/inference: {forbidden}')
        raise SystemExit(1)

for needle in (
    'Pattern reinforcement stays observational and user owned',
    "find.text('Actions you recorded as helpful')",
    "find.text('From confirmed victories')",
    "find.text('Put the phone down'), findsNothing",
    "find.textContaining('do not prove what caused the outcome')",
    "find.textContaining('predict what will work next')",
    'expect(find.byType(FilledButton), findsNothing)',
    'Pattern reinforcement disappears without confirmed helpful evidence',
):
    if needle not in test:
        print(f'FAIL BW-89A11B widget regression contract missing: {needle}')
        raise SystemExit(1)

print(
    'PASS: BW-89A11B Pattern reinforcement verified — the protected '
    'Recognize Pattern Picture remains exact while confirmed Victory actions '
    'are reflected beside it as observational Reinforce evidence.'
)
