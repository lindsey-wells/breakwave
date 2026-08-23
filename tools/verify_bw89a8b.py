#!/usr/bin/env python3
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parent.parent

model_path = (
    ROOT
    / 'lib/features/patterns/domain/bedtime_context_observation.dart'
)
engine_path = (
    ROOT
    / 'lib/features/patterns/domain/bedtime_context_observation_engine.dart'
)
card_path = (
    ROOT
    / 'lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart'
)
test_path = ROOT / 'test/bedtime_context_observation_engine_test.dart'

for path in (model_path, engine_path, card_path, test_path):
    if not path.is_file():
        print(
            f'FAIL BW-89A8B missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

model = model_path.read_text(encoding='utf-8')
engine = engine_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
a8a_verifier_path = ROOT / 'tools/verify_bw89a8a.py'
if not a8a_verifier_path.is_file():
    print('FAIL BW-89A8B successor A8A verifier missing')
    sys.exit(1)
a8a_verifier = a8a_verifier_path.read_text(encoding='utf-8')

for needle in (
    'bedtime control compatibility missing',
    'protected foundation drift',
    'successor presentation boundary',
):
    if needle not in a8a_verifier:
        print(
            f'FAIL BW-89A8B A8A successor-boundary verifier missing: {needle}'
        )
        sys.exit(1)

for needle in (
    'class BedtimeContextObservationResult',
    'final int bedtimeCount;',
    'final int riskyCount;',
    'final int steadyCount;',
    'final bool hasEnoughData;',
    'final bool hasObservation;',
    'final int windowDays;',
):
    if needle not in model:
        print(f'FAIL BW-89A8B result model missing: {needle}')
        sys.exit(1)

for needle in (
    'class BedtimeContextObservationEngine',
    'static const int windowDays = 7;',
    'static const int minimumBedtimeCheckIns = 3;',
    'required List<BedtimeModeEntry> entries',
    'final Map<String, BedtimeModeEntry> latestByDate',
    'if (riskyCount == steadyCount)',
    "dominantLabel =",
    "'risky' : 'steady'",
    'You marked $dominantCount of $bedtimeCount bedtime check-ins as $dominantLabel',
    'Risky and steady bedtime check-ins are evenly represented',
):
    if needle not in engine:
        print(f'FAIL BW-89A8B engine contract missing: {needle}')
        sys.exit(1)

for needle in (
    "import '../../../patterns/domain/bedtime_context_observation.dart';",
    "import '../../../patterns/domain/bedtime_context_observation_engine.dart';",
    'BedtimeContextObservationResult _bedtimeContext =',
    'BedtimeModeStore.loadEntries()',
    'const BedtimeContextObservationEngine().evaluate(',
    'entries: entries,',
    "'Recognize'",
    "'Bedtime context'",
    "'Learn from the nights around the waves.'",
    '_bedtimeContext.message',
    'This reflects what you marked at bedtime—it does not explain why a wave happened or predict what happens next.',
):
    if needle not in card:
        print(f'FAIL BW-89A8B Bedtime UI missing: {needle}')
        sys.exit(1)

# Existing BW-23 user/control contract must still exist.
for legacy in (
    'BedtimeModeStore.loadTodayEntry()',
    'BedtimeModeStore.saveTodayRisk(isRisky)',
    'BreakWaveHomeWidgetSync.sync()',
    'Tonight feels steady',
    'Tonight feels risky',
    'Open Rescue now',
    'Saved bedtime risk for tonight.',
    'Saved tonight as steady.',
):
    if legacy not in card:
        print(
            f'FAIL BW-89A8B broke bedtime legacy contract: {legacy}'
        )
        sys.exit(1)

# Protected semantic boundaries from the A8B audit.
protected = {
    'lib/core/bedtime/bedtime_mode_store.dart':
        '004d5a67f1eafafe86e936329e33904a7760f37ad6de0b24df897246a1cf158a',
    'lib/features/patterns/domain/daily_context_observation_engine.dart':
        '97dad84b8e222aec873631f26c4e7e9311ffae5c440c477e0033c6befb0b2fba',
    'lib/features/patterns/domain/pattern_observation_engine.dart':
        'df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f',
    'lib/features/log/presentation/widgets/pattern_observation_card.dart':
        '61a1ca526c4adb9869ea1390bcbac818a0980771719603111a1c5f56aab72a0f',
    'lib/features/log/presentation/log_screen.dart':
        '186c4987f6e0d33b96724a04cc6eff85c97cce2bc60ea5648cbe7c7f51f7c588',
    'lib/features/insights/domain/recovery_insights_calculator.dart':
        '5051fe330cc68315a1fe3e560f34b1a4690235e02f13c9f272e3f8c528bc09e0',
}

for rel, expected in protected.items():
    actual = hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
    if actual != expected:
        print(
            f'FAIL BW-89A8B protected semantic boundary drift: {rel} '
            f'expected {expected} got {actual}'
        )
        sys.exit(1)

for forbidden in (
    'LogEntry',
    'LogRepository',
    'PatternObservationEngine',
    'DailyContextObservationEngine',
    'RecoveryInsightsCalculator',
    'BreakWaveAccessPolicy',
    'billing',
    'cloud',
):
    if forbidden in engine:
        print(
            f'FAIL BW-89A8B context engine forbidden coupling: '
            f'{forbidden}'
        )
        sys.exit(1)

for needle in (
    'requires three recent bedtime check-ins',
    'reports risky bedtime context observationally',
    'reports steady bedtime context observationally',
    'suppresses a tied bedtime observation',
    'uses one latest entry per date and ignores old nights',
    'wording remains non-causal and non-predictive',
):
    if needle not in tests:
        print(
            f'FAIL BW-89A8B regression test missing: {needle}'
        )
        sys.exit(1)

choice_index = card.find("label: const Text('Tonight feels steady')")
context_index = card.find("'Bedtime context'")
if choice_index == -1 or context_index == -1 or choice_index > context_index:
    print(
        'FAIL BW-89A8B Bedtime context must appear after bedtime choices'
    )
    sys.exit(1)

print(
    'PASS: BW-89A8B Bedtime Context Observations verified — '
    'separate deterministic context, legacy bedtime controls preserved, '
    'A2/A3/A6 boundaries unchanged.'
)
