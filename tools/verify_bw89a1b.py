#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

home_path = ROOT / 'lib/features/home/presentation/home_screen.dart'
card_path = ROOT / 'lib/features/home/presentation/widgets/recovery_snapshot_card.dart'
test_path = ROOT / 'test/recovery_snapshot_card_test.dart'

for path in (home_path, card_path, test_path):
    if not path.is_file():
        print(f'FAIL BW-89A1B missing file: {path.relative_to(ROOT)}')
        sys.exit(1)

home = home_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')

home_required = (
    'int reflectionCount = 0;',
    "case 'Reflection':",
    'reflectionCount += 1;',
    'reflectionCount: reflectionCount,',
    'reflectionCount: summary.reflectionCount,',
    'final int reflectionCount;',
    'required this.reflectionCount,',
    'reflectionCount = 0,',
)
for needle in home_required:
    if needle not in home:
        print(f'FAIL BW-89A1B Home missing: {needle}')
        sys.exit(1)

card_required = (
    'final int reflectionCount;',
    'required this.reflectionCount,',
    "label: 'Reflections'",
    "value: '$reflectionCount'",
    'onTap: onOpenLog',
)
for needle in card_required:
    if needle not in card:
        print(f'FAIL BW-89A1B snapshot card missing: {needle}')
        sys.exit(1)

if card.count('onTap: onOpenLog') < 5:
    print('FAIL BW-89A1B expected all five snapshot metrics to open Log')
    sys.exit(1)

for needle in (
    'totalEntries: 8',
    'urgeCount: 1',
    'slipCount: 4',
    'victoryCount: 2',
    'reflectionCount: 1',
    "find.text('Reflections')",
):
    if needle not in test:
        print(f'FAIL BW-89A1B regression test missing: {needle}')
        sys.exit(1)

for forbidden in (
    'RecoveryInsightsCalculator',
    'averageIntensity',
    'busiestTimeWindow',
    'topTriggers',
):
    if forbidden in home or forbidden in card:
        print(
            'FAIL BW-89A1B Home snapshot must not add behavioral analytics: '
            + forbidden
        )
        sys.exit(1)

print('PASS: BW-89A1B Recovery Snapshot reflection parity verified.')
