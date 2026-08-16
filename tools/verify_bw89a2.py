#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

observation_path = (
    ROOT / 'lib/features/patterns/domain/pattern_observation.dart'
)
engine_path = (
    ROOT / 'lib/features/patterns/domain/pattern_observation_engine.dart'
)
test_path = ROOT / 'test/pattern_observation_engine_test.dart'

for path in (observation_path, engine_path, test_path):
    if not path.is_file():
        print(f'FAIL BW-89A2 missing file: {path.relative_to(ROOT)}')
        sys.exit(1)

observation = observation_path.read_text(encoding='utf-8')
engine = engine_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')

for needle in (
    'enum PatternObservationKind',
    'recurringTrigger',
    'timeWindow',
    'repeatedVictoryAction',
    'class PatternObservationResult',
    'final bool hasEnoughData;',
):
    if needle not in observation:
        print(f'FAIL BW-89A2 observation contract missing: {needle}')
        sys.exit(1)

for needle in (
    'class PatternObservationEngine',
    'static const int windowDays = 30;',
    'static const int minimumBehavioralEntries = 3;',
    'static const int minimumRepeatedSignalCount = 2;',
    'LogSignalClassifier',
    '_signalClassifier.isBehavioralEntryType',
    '_signalClassifier.isUserTrigger',
    'RecoveryInsightsCalculator',
    'busiestTimeWindow30Days',
    'item.entry.replacementAction.trim()',
    'logged recovery moments',
    'was recorded as what worked',
):
    if needle not in engine:
        print(f'FAIL BW-89A2 engine contract missing: {needle}')
        sys.exit(1)

for marker in (
    "'rescue completion'",
    "'wave timer'",
    "'lower now'",
    "'still strong'",
    "'slipped'",
):
    classifier = (
        ROOT / 'lib/features/log/domain/log_signal_classifier.dart'
    ).read_text(encoding='utf-8')
    if marker not in classifier:
        print(f'FAIL BW-89A2 A1 hygiene marker missing: {marker}')
        sys.exit(1)

for needle in (
    'requires three recent behavioral logs before observing patterns',
    'without counting operational metadata',
    'from victories only',
    'conservative timing threshold and tie suppression',
    'deterministic alphabetical tie-break',
    'ignores future, old, unsupported, and reflection entries',
    'observational rather than causal or predictive',
):
    if needle not in test:
        print(f'FAIL BW-89A2 regression test missing: {needle}')
        sys.exit(1)

for forbidden in (
    'you relapse because',
    'this causes',
    'this predicts',
    'you are likely to',
    'diagnosis:',
):
    if forbidden in engine.lower():
        print(f'FAIL BW-89A2 unsafe wording present: {forbidden}')
        sys.exit(1)

ui_paths = (
    ROOT / 'lib/features/log/presentation/log_screen.dart',
    ROOT / 'lib/features/home/presentation/home_screen.dart',
)
for ui_path in ui_paths:
    if 'PatternObservationEngine' in ui_path.read_text(encoding='utf-8'):
        print(
            'FAIL BW-89A2 must remain domain-only; UI integration belongs to A3'
        )
        sys.exit(1)

print('PASS: BW-89A2 cautious Pattern Observation Engine verified.')
