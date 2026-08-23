#!/usr/bin/env python3
from pathlib import Path
import hashlib
import os
import sys

FIXTURE_ROOT = os.environ.get('BW_A9_FIXTURE_ROOT')
ROOT = (
    Path(FIXTURE_ROOT).resolve()
    if FIXTURE_ROOT
    else Path(__file__).resolve().parent.parent
)
FIXTURE_MODE = FIXTURE_ROOT is not None

home_path = ROOT / 'lib/features/home/presentation/home_screen.dart'
card_path = (
    ROOT
    / 'lib/features/home/presentation/widgets/pattern_picture_card.dart'
)
test_path = ROOT / 'test/pattern_picture_card_test.dart'

for path in (home_path, card_path, test_path):
    if not path.is_file():
        print(
            f'FAIL BW-89A9 missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

home = home_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')

for needle in (
    "import 'widgets/pattern_picture_card.dart';",
    "eyebrow: 'Pattern awareness'",
    "title: 'Learn the pattern'",
    'const PatternPictureCard()',
    'const RecoveryCyclePreviewCard()',
):
    if needle not in home:
        print(f'FAIL BW-89A9 Home integration missing: {needle}')
        sys.exit(1)

section_index = home.find("eyebrow: 'Pattern awareness'")
picture_index = home.find('const PatternPictureCard()')
cycle_index = home.find('const RecoveryCyclePreviewCard()')
if not (-1 < section_index < picture_index < cycle_index):
    print(
        'FAIL BW-89A9 Pattern Picture must sit inside the existing '
        'Pattern Awareness area before RecoveryCyclePreviewCard'
    )
    sys.exit(1)

for needle in (
    'class PatternPictureCard',
    "'Your Pattern Picture'",
    "'See the signals without turning them into conclusions.'",
    'const LogRepository().loadEntries()',
    'DailyCheckInStore.loadEntries()',
    'BedtimeModeStore.loadEntries()',
    'const PatternObservationEngine().evaluate(',
    'const DailyContextObservationEngine().evaluate(',
    'const BedtimeContextObservationEngine().evaluate(',
    "'Recovery moments'",
    "'From your Log'",
    "'Daily context'",
    "'From Daily Check-In'",
    "'Bedtime context'",
    "'From bedtime check-ins'",
    'These are separate observations from what you recorded.',
    'They can help you notice repetition, but they do not ',
    'explain what caused a wave or predict what happens next.',
):
    if needle not in card:
        print(f'FAIL BW-89A9 Pattern Picture contract missing: {needle}')
        sys.exit(1)

# No combined risk model, no cross-source score, no Reflection mining.
for forbidden in (
    'riskScore',
    'risk_score',
    'probability',
    'likelihood',
    'percentRisk',
    'Reflection',
    'reflection',
    'causeScore',
    'predictionScore',
):
    if forbidden in card:
        print(
            f'FAIL BW-89A9 forbidden synthesis/inference marker: {forbidden}'
        )
        sys.exit(1)

# Existing engines/models remain exact. A9 composes outputs only.
protected_sha256 = {'lib/features/patterns/domain/pattern_observation.dart': 'e0a81cda9a3d75c7bc4685e28d6f79d0a799df3652921ae6af8600a646feaf67',
 'lib/features/patterns/domain/pattern_observation_engine.dart': 'df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f',
 'lib/features/patterns/domain/daily_context_observation.dart': '1da1a205697300e993732d0b85e8746ba6b8b0dcff96dee51d4cb1b6c46db329',
 'lib/features/patterns/domain/daily_context_observation_engine.dart': '97dad84b8e222aec873631f26c4e7e9311ffae5c440c477e0033c6befb0b2fba',
 'lib/features/patterns/domain/bedtime_context_observation.dart': '9ae6f540c0bc7582160f40524032e1b3f6501ab6818a76b72c5e21d1a1b8f399',
 'lib/features/patterns/domain/bedtime_context_observation_engine.dart': 'de44fc97159a987f64e5c2d8c01ff78353546b4c0cd5649891c27343cf743a04',
 'lib/features/log/domain/log_signal_classifier.dart': 'eedd2b216ff067523c39b62ef5d1943cf7372bc3f42215bd8391d3d064fa2e44',
 'lib/features/log/presentation/widgets/pattern_observation_card.dart': '61a1ca526c4adb9869ea1390bcbac818a0980771719603111a1c5f56aab72a0f',
 'lib/features/log/presentation/log_screen.dart': '186c4987f6e0d33b96724a04cc6eff85c97cce2bc60ea5648cbe7c7f51f7c588',
 'lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart': '6207d0eada86ec06c1c079ad30c02ca84a5fec494116549448da59c4e21d5a75',
 'lib/features/insights/presentation/simple_insights_card.dart': '1101e4f4a9ae10335f2f3b43adfdb40d70681490a6f417efc50bc4ebeee0d7cf',
 'lib/features/insights/domain/recovery_insights_calculator.dart': 'e16bdc639d9bc829dcd78e64fc137ac39ade54b453ba57ded4455c20c5a88d6a'}

if not FIXTURE_MODE:
    for rel, expected in protected_sha256.items():
        actual = hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
        if actual != expected:
            print(
                f'FAIL BW-89A9 protected Recognize boundary drift: {rel} '
                f'expected {expected} got {actual}'
            )
            sys.exit(1)

for needle in (
    'Pattern Picture keeps Recognize sources visibly separate',
    "find.text('Recovery moments')",
    "find.text('Daily context')",
    "find.text('Bedtime context')",
    "find.textContaining('risk score'), findsNothing",
    'tester.takeException()',
):
    if needle not in tests:
        print(f'FAIL BW-89A9 widget regression missing: {needle}')
        sys.exit(1)

print(
    'PASS: BW-89A9 Your Pattern Picture verified — '
    'Log, Daily Context, and Bedtime Context are composed visibly '
    'without blending evidence or creating inference.'
)
if FIXTURE_MODE:
    print(
        'PASS: BW-89A9 actual packaged verifier executed against '
        'patched candidate fixture.'
    )
