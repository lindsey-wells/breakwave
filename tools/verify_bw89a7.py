#!/usr/bin/env python3
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parent.parent

screen_path = ROOT / 'lib/features/log/presentation/log_screen.dart'
card_path = (
    ROOT
    / 'lib/features/log/presentation/widgets/log_cbt_reflection_card.dart'
)
test_path = ROOT / 'test/log_reflection_user_experience_test.dart'
classifier_path = ROOT / 'lib/features/log/domain/log_signal_classifier.dart'
pattern_path = (
    ROOT
    / 'lib/features/patterns/domain/pattern_observation_engine.dart'
)
model_path = ROOT / 'lib/features/log/domain/log_entry.dart'

for path in (
    screen_path,
    card_path,
    test_path,
    classifier_path,
    pattern_path,
    model_path,
):
    if not path.is_file():
        print(f'FAIL BW-89A7 missing file: {path.relative_to(ROOT)}')
        sys.exit(1)

screen = screen_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')

screen_required = (
    'bool get _isReflectionDraft',
    'final bool enteringReflection =',
    'final bool wasReflection =',
    'if (enteringReflection && !wasReflection)',
    '_selectedTriggers.clear();',
    '_otherTriggerController.clear();',
    '_selectedReplacementAction = null;',
    '_otherReplacementActionController.clear();',
    'final bool preserveLegacyReflectionMetadata =',
    'isReflectionEntry && editingId != null;',
    'preserveLegacyReflectionMetadata',
    'const <String>[]',
    'final String replacementActionForSave = isReflectionEntry',
    '? (preserveLegacyReflectionMetadata',
    '? _resolvedReplacementAction()',
    ": '')",
    ': _resolvedReplacementAction();',
    'if (!_isReflectionDraft) ...<Widget>[',
    'LogTriggerChipsSection(',
    'triggerCount: _isReflectionDraft',
    '? 0',
    ': _resolvedTriggers().length',
)
for needle in screen_required:
    if needle not in screen:
        print(f'FAIL BW-89A7 LogScreen contract missing: {needle}')
        sys.exit(1)

replacement_start = screen.find(
    'final String replacementActionForSave = isReflectionEntry'
)
preserve_start = screen.find(
    '? (preserveLegacyReflectionMetadata',
    replacement_start,
)
legacy_action_start = screen.find(
    '? _resolvedReplacementAction()',
    preserve_start,
)
blank_action_start = screen.find(
    ": '')",
    legacy_action_start,
)
behavioral_action_start = screen.find(
    ': _resolvedReplacementAction();',
    blank_action_start,
)

if not (
    -1 < replacement_start
    < preserve_start
    < legacy_action_start
    < blank_action_start
    < behavioral_action_start
):
    print(
        'FAIL BW-89A7 Reflection replacement-action save semantics '
        'are not in the expected preserve-old / blank-new / behavioral order'
    )
    sys.exit(1)

# Reflection must have a separate runtime branch while old behavioral
# strings remain available for Urge/Victory historical contracts.
for needle in (
    'if (isReflectionEntry)',
    'return _buildReflectionJournal(context);',
    'return _buildBehavioralCard(context);',
    'Widget _buildBehavioralCard(BuildContext context)',
    'Widget _buildReflectionJournal(BuildContext context)',
    "'Healthy replacement action'",
    "'Next better move'",
    "'Add reflection details'",
    "'Thought before the urge'",
    "'Simple reflection'",
    "'Capture what you noticed. There is nothing to grade here.'",
    "'Notice the pattern without judging yourself.'",
    "labelText: 'What are you noticing?'",
    "labelText: 'What felt important?'",
    "labelText: 'What did you learn?'",
    "labelText: 'What do you want to carry forward?'",
):
    if needle not in card:
        print(f'FAIL BW-89A7 Reflection card contract missing: {needle}')
        sys.exit(1)

behavioral_start = card.find(
    'Widget _buildBehavioralCard(BuildContext context)'
)
reflection_start = card.find(
    'Widget _buildReflectionJournal(BuildContext context)'
)
if (
    behavioral_start == -1
    or reflection_start == -1
    or behavioral_start >= reflection_start
):
    print('FAIL BW-89A7 behavioral/reflection branch ordering is unexpected')
    sys.exit(1)

behavioral_slice = card[behavioral_start:reflection_start]
reflection_slice = card[reflection_start:]

for needle in (
    'Healthy replacement action',
    'ChoiceChip(',
    'Open Rescue now',
    'Open trusted support',
):
    if needle not in behavioral_slice:
        print(
            f'FAIL BW-89A7 behavioral path lost existing contract: {needle}'
        )
        sys.exit(1)
    if needle in reflection_slice:
        print(
            f'FAIL BW-89A7 Reflection journal leaked behavioral action UI: {needle}'
        )
        sys.exit(1)

# Preserve the exact historical BW-72C source-order contract.
healthy_index = card.find('Healthy replacement action')
details_index = card.find('Add reflection details')
thought_index = card.find('Thought before the urge')
if not (
    -1 < healthy_index < details_index < thought_index < reflection_start
):
    print('FAIL BW-89A7 broke BW-72C behavioral source-order contract')
    sys.exit(1)

for needle in (
    'Reflection selector has its own icon',
    'Reflection history badge appears without intensity',
    'Reflection draft summary does not invent intensity',
    'Reflection card uses calm nonjudgmental prompts',
    'Reflection journal hides behavioral replacement actions',
    "expect(find.text('Healthy replacement action'), findsNothing);",
    "expect(find.byType(ChoiceChip), findsNothing);",
):
    if needle not in tests:
        print(f'FAIL BW-89A7 widget regression missing: {needle}')
        sys.exit(1)

# Analytics/model surfaces are intentionally untouched by A7.
expected_sha256 = {
    'lib/features/log/domain/log_entry.dart':
        '0aaa13a2faf32f8449da9c184ee4de6bf981bcffddcf9fca40151cd0efb49df8',
    'lib/features/log/domain/log_signal_classifier.dart':
        'eedd2b216ff067523c39b62ef5d1943cf7372bc3f42215bd8391d3d064fa2e44',
    'lib/features/patterns/domain/pattern_observation_engine.dart':
        'df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f',
}

for rel, expected in expected_sha256.items():
    actual = hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
    if actual != expected:
        print(
            f'FAIL BW-89A7 protected analytics/model drift: {rel} '
            f'expected {expected} got {actual}'
        )
        sys.exit(1)

print(
    'PASS: BW-89A7 Reflection Journal Alignment verified — '
    'journal-specific UI, behavioral contracts preserved, analytics unchanged.'
)
