#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

model_path = (
    ROOT
    / 'lib/features/patterns/domain/daily_context_observation.dart'
)
engine_path = (
    ROOT
    / 'lib/features/patterns/domain/daily_context_observation_engine.dart'
)
card_path = (
    ROOT
    / 'lib/features/checkin/presentation/daily_check_in_card.dart'
)
a2_path = (
    ROOT
    / 'lib/features/patterns/domain/pattern_observation_engine.dart'
)
test_path = ROOT / 'test/daily_context_observation_engine_test.dart'

for path in (
    model_path,
    engine_path,
    card_path,
    a2_path,
    test_path,
):
    if not path.is_file():
        print(
            f'FAIL BW-89A6 missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

model = model_path.read_text(encoding='utf-8')
engine = engine_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
a2 = a2_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')

for needle in (
    'class DailyContextObservationResult',
    'final int checkInCount;',
    'final bool hasEnoughData;',
    'final bool hasObservation;',
    'final String? dominantStatus;',
    'final int evidenceCount;',
):
    if needle not in model:
        print(f'FAIL BW-89A6 result model missing: {needle}')
        sys.exit(1)

for needle in (
    'class DailyContextObservationEngine',
    'static const int windowDays = 7;',
    'static const int minimumCheckIns = 3;',
    'static const int minimumRepeatedStatusCount = 2;',
    "'steady': 'Steady'",
    "'vulnerable': 'Vulnerable'",
    "'fought through': 'Fought through'",
    "'slipped': 'Slipped'",
    'final Map<String, DailyCheckInEntry> latestByDate',
    'tiedTopCount != 1',
    'You marked ${top.value} of $checkInCount Daily Check-Ins as ${top.key}',
    'No single Daily Check-In status is repeating more than the others yet.',
):
    if needle not in engine:
        print(f'FAIL BW-89A6 engine contract missing: {needle}')
        sys.exit(1)

for needle in (
    "import '../../patterns/domain/daily_context_observation.dart';",
    "import '../../patterns/domain/daily_context_observation_engine.dart';",
    'DailyContextObservationResult _dailyContext =',
    'const DailyContextObservationEngine().evaluate(',
    'entries: entries,',
    "'Recognize'",
    "'Daily context'",
    "'Learn from the days around the waves.'",
    '_dailyContext.message',
    'This reflects what you recorded—it does not explain why a wave happened or predict what happens next.',
):
    if needle not in card:
        print(f'FAIL BW-89A6 Daily Check-In UI missing: {needle}')
        sys.exit(1)

for legacy in (
    "'Steady'",
    "'Vulnerable'",
    "'Fought through'",
    "'Slipped'",
    "'Control signal:",
    'DailyCheckInStore.saveTodayStatus(status)',
    "Saved today\\'s check-in: $status",
    'ChoiceChip(',
):
    if legacy not in card:
        print(f'FAIL BW-89A6 broke Daily Check-In legacy contract: {legacy}')
        sys.exit(1)

if 'DailyCheckInEntry' in a2 or 'DailyContextObservationEngine' in a2:
    print(
        'FAIL BW-89A6 must not mix Daily Check-In context into A2 behavioral engine'
    )
    sys.exit(1)

for forbidden in (
    'LogEntry',
    'LogRepository',
    'PatternObservationEngine',
    'RecoveryInsightsCalculator',
):
    if forbidden in engine:
        print(
            f'FAIL BW-89A6 context engine must remain separate from behavioral Log: {forbidden}'
        )
        sys.exit(1)

for forbidden in (
    'BreakWaveAccessPolicy',
    'isPlus',
    'billing',
    'cloud',
):
    if forbidden in engine or forbidden in card:
        print(f'FAIL BW-89A6 forbidden scope coupling: {forbidden}')
        sys.exit(1)

new_text = (engine + '\n' + model).lower()
for unsafe in (
    'you relapse because',
    'this causes',
    'this predicts',
    'you are likely to',
    'diagnosis:',
):
    if unsafe in new_text:
        print(f'FAIL BW-89A6 unsafe wording: {unsafe}')
        sys.exit(1)

for needle in (
    'requires three recent Daily Check-Ins',
    'reports one dominant repeated status observationally',
    'suppresses tied context instead of declaring a pattern',
    'uses one latest valid status per date',
    'context wording remains non-causal and non-predictive',
):
    if needle not in tests:
        print(f'FAIL BW-89A6 regression test missing: {needle}')
        sys.exit(1)

wrap_index = card.find('children: _statuses.map((String status)')
context_index = card.find("'Daily context'")
if wrap_index == -1 or context_index == -1 or wrap_index > context_index:
    print(
        'FAIL BW-89A6 Daily context must appear after the status choices'
    )
    sys.exit(1)

print('PASS: BW-89A6 Daily Context Signals verified.')
