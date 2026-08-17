#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

screen_path = ROOT / 'lib/features/rescue/presentation/rescue_screen.dart'
timer_path = (
    ROOT
    / 'lib/features/rescue/presentation/widgets/wave_timer_card.dart'
)
redirect_path = (
    ROOT
    / 'lib/features/rescue/presentation/widgets/redirect_actions_card.dart'
)
completion_path = (
    ROOT
    / 'lib/features/rescue/presentation/widgets/wave_completion_card.dart'
)
test_path = ROOT / 'test/wave_timer_redirect_bridge_test.dart'

for path in (
    screen_path,
    timer_path,
    redirect_path,
    completion_path,
    test_path,
):
    if not path.is_file():
        print(
            f'FAIL BW-89A4 missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

screen = screen_path.read_text(encoding='utf-8')
timer = timer_path.read_text(encoding='utf-8')
redirect = redirect_path.read_text(encoding='utf-8')
completion = completion_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')

screen_required = (
    'final GlobalKey _outcomeFollowUpKey = GlobalKey();',
    'String? _completedNextAction;',
    'String? get _redirectBridgeAction =>',
    'Future<void> _handleWaveTimerOutcomeSaved(',
    'onOutcomeSaved: _handleWaveTimerOutcomeSaved,',
    'Protect the next few minutes',
    'Your next right action: $redirectAction',
    'Choose one next right action before returning to the same environment.',
    'Choose a next right action',
    'Choose a different action',
    '_scrollToOutcomeFollowUpAfterBuild();',
    "if (entryType == 'Slip') {",
    'widget.onOpenSupport();',
)
for needle in screen_required:
    if needle not in screen:
        print(f'FAIL BW-89A4 Rescue bridge missing: {needle}')
        sys.exit(1)

timer_required = (
    'this.onOutcomeSaved,',
    'final Future<void> Function(String entryType, String outcomeTag)?',
    'widget.onOutcomeSaved;',
    'await onOutcomeSaved(entryType, outcomeTag);',
    'widget.onReturnHome();',
    "'Lower Now'",
    "'Still Strong'",
    "'Slipped'",
)
for needle in timer_required:
    if needle not in timer:
        print(f'FAIL BW-89A4 Wave Timer bridge missing: {needle}')
        sys.exit(1)

legacy_rescue_required = (
    "'Rescue Completion'",
    '_selectedNextAction = null;',
    '_showStillStrongFollowUp = true;',
    '_showWaveSavedFollowUp = true;',
    'Choose a redirect action',
    'Return to Calm Reset',
    'Open Support',
)
for needle in legacy_rescue_required:
    if needle not in screen:
        print(
            f'FAIL BW-89A4 historical Rescue contract missing: {needle}'
        )
        sys.exit(1)

redirect_required = (
    "'Put the phone down'",
    "'Leave the room'",
    "'Open your why'",
    "'Text someone safe'",
    "'Cold water reset'",
    "'Take a short walk'",
    "'Other'",
    "'Pray for one minute'",
    "'Next Right Action'",
)
for needle in redirect_required:
    if needle not in redirect:
        print(
            f'FAIL BW-89A4 existing Redirect action missing: {needle}'
        )
        sys.exit(1)

completion_required = (
    'I made it through this wave',
    'Still strong',
    'I slipped',
)
for needle in completion_required:
    if needle not in completion:
        print(
            f'FAIL BW-89A4 Wave Completion contract missing: {needle}'
        )
        sys.exit(1)

test_required = (
    'saved timer outcome hands off to Rescue instead of returning Home',
    'standalone timer keeps its historical Return Home fallback',
    "expect(entryType, 'Victory');",
    "expect(outcomeTag, 'Lower Now');",
    'expect(returnedHome, isFalse);',
    'expect(returnedHome, isTrue);',
)
for needle in test_required:
    if needle not in test:
        print(f'FAIL BW-89A4 regression missing: {needle}')
        sys.exit(1)

for forbidden in (
    'PatternObservationEngine',
    'BreakWaveAccessPolicy',
    'isPlus',
    'billing',
    'relapse probability',
    'you are likely to relapse',
):
    if forbidden in screen or forbidden in timer:
        print(
            f'FAIL BW-89A4 forbidden coupling/wording present: {forbidden}'
        )
        sys.exit(1)

print('PASS: BW-89A4 Rescue to Redirect Bridge verified.')
