#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

screen_path = ROOT / 'lib/features/log/presentation/log_screen.dart'
card_path = (
    ROOT / 'lib/features/log/presentation/widgets/pattern_observation_card.dart'
)
test_path = ROOT / 'test/pattern_observation_card_test.dart'

for path in (screen_path, card_path, test_path):
    if not path.is_file():
        print(f'FAIL BW-89A3 missing file: {path.relative_to(ROOT)}')
        sys.exit(1)

screen = screen_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')

for needle in (
    "import '../../patterns/domain/pattern_observation.dart';",
    "import '../../patterns/domain/pattern_observation_engine.dart';",
    "import 'widgets/pattern_observation_card.dart';",
    'PatternObservationResult? _patternObservationResult;',
    'PatternObservationResult _evaluatePatternObservations(',
    'const PatternObservationEngine().evaluate(',
    'PatternObservationCard(',
    'minimumBehavioralEntries:',
    'PatternObservationEngine.minimumBehavioralEntries',
):
    if needle not in screen:
        print(f'FAIL BW-89A3 Log integration missing: {needle}')
        sys.exit(1)

if screen.count('_evaluatePatternObservations(entries)') < 3:
    print(
        'FAIL BW-89A3 pattern result must refresh on initial load, '
        'show-all reload, and save/update'
    )
    sys.exit(1)

card_index = screen.find('PatternObservationCard(')
recent_index = screen.find('RecentLogEntriesCard(')
save_index = screen.find('LogSaveCard(')
if not (save_index < card_index < recent_index):
    print(
        'FAIL BW-89A3 Learn your pattern card must be after Save '
        'and before Recent entries'
    )
    sys.exit(1)

for needle in (
    "key: const ValueKey<String>('learn-your-pattern-card')",
    "'Learn your pattern'",
    "'Recognize'",
    'Based only on what you recorded in the last ',
    'Keep logging what you notice.',
    'nothing is repeating strongly enough to call out yet',
    'These are observations from your Log—not causes, predictions, ',
    'final PatternObservation observation',
    'Text(observation.message)',
):
    if needle not in card:
        print(f'FAIL BW-89A3 card contract missing: {needle}')
        sys.exit(1)

for unsafe in (
    'you relapse because',
    'you are likely to relapse',
    'this causes your',
    'we predict',
    'your diagnosis',
):
    if unsafe in card.lower():
        print(f'FAIL BW-89A3 unsafe user-facing wording: {unsafe}')
        sys.exit(1)

for needle in (
    'shows calm insufficient-data guidance',
    'shows A2 observations without rewriting them',
    'shows neutral no-repetition state when data is sufficient',
    'not causes, predictions, or diagnoses',
):
    if needle not in test:
        print(f'FAIL BW-89A3 widget regression missing: {needle}')
        sys.exit(1)

for forbidden in (
    'BreakWaveAccessPolicy',
    'entitlement',
    'isPlus',
    'billing',
):
    if forbidden in card:
        print(f'FAIL BW-89A3 card must not be Plus gated: {forbidden}')
        sys.exit(1)

print('PASS: BW-89A3 Learn your pattern Log card verified.')
