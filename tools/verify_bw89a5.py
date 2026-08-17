#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

screen_path = ROOT / 'lib/features/rescue/presentation/rescue_screen.dart'
timer_path = (
    ROOT
    / 'lib/features/rescue/presentation/widgets/wave_timer_card.dart'
)
repo_path = ROOT / 'lib/features/log/data/log_repository.dart'
a2_path = (
    ROOT
    / 'lib/features/patterns/domain/pattern_observation_engine.dart'
)
bridge_test_path = ROOT / 'test/wave_timer_redirect_bridge_test.dart'
repo_test_path = ROOT / 'test/victory_reinforcement_repository_test.dart'

for path in (
    screen_path,
    timer_path,
    repo_path,
    a2_path,
    bridge_test_path,
    repo_test_path,
):
    if not path.is_file():
        print(
            f'FAIL BW-89A5 missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

screen = screen_path.read_text(encoding='utf-8')
timer = timer_path.read_text(encoding='utf-8')
repo = repo_path.read_text(encoding='utf-8')
a2 = a2_path.read_text(encoding='utf-8')
bridge_test = bridge_test_path.read_text(encoding='utf-8')
repo_test = repo_test_path.read_text(encoding='utf-8')

screen_required = (
    'String? _pendingVictoryEntryId;',
    'String? _confirmedVictoryAction;',
    '_confirmedVictoryAction ??',
    'String entryId,',
    '_pendingVictoryEntryId = entryId;',
    'final String entryId =',
    "replacementAction: entryType == 'Victory'",
    "? ''",
    'confirmVictoryReplacementAction(',
    'entryId: entryId,',
    'replacementAction: action,',
    "label: const Text('That helped')",
    'You chose differently. Keep what worked.',
    'was saved as something that helped during this victory.',
    'Choose a different action',
    'Protect the next few minutes',
)
for needle in screen_required:
    if needle not in screen:
        print(f'FAIL BW-89A5 Rescue reinforcement missing: {needle}')
        sys.exit(1)

timer_required = (
    'final Future<void> Function(',
    'String outcomeTag,',
    'String entryId,',
    'final String entryId =',
    'id: entryId,',
    'await onOutcomeSaved(entryType, outcomeTag, entryId);',
    'widget.onReturnHome();',
)
for needle in timer_required:
    if needle not in timer:
        print(f'FAIL BW-89A5 timer exact-ID handoff missing: {needle}')
        sys.exit(1)

repo_required = (
    'Future<bool> confirmVictoryReplacementAction({',
    'required String entryId,',
    'required String replacementAction,',
    "item.entryType.trim().toLowerCase() != 'victory'",
    'item.id != entryId',
    'replacementAction: confirmedAction,',
    'createdAtIso: item.createdAtIso,',
)
for needle in repo_required:
    if needle not in repo:
        print(f'FAIL BW-89A5 repository confirmation missing: {needle}')
        sys.exit(1)

a2_required = (
    '_topVictoryReplacementAction(behavioral)',
    "'victory'",
    'item.entry.replacementAction.trim()',
    'was recorded as what worked',
)
for needle in a2_required:
    if needle not in a2:
        print(f'FAIL BW-89A5 A2 semantics missing: {needle}')
        sys.exit(1)

test_required = (
    'confirms what helped on the exact Victory ID only',
    "entryId: 'victory-a'",
    "replacementAction: 'Take a short walk'",
    'expect(refusedUrge, isFalse);',
)
for needle in test_required:
    if needle not in repo_test:
        print(f'FAIL BW-89A5 repository regression missing: {needle}')
        sys.exit(1)

bridge_required = (
    'String savedEntryId',
    'savedEntryId = incomingEntryId;',
    'expect(savedEntryId, isNotEmpty);',
)
for needle in bridge_required:
    if needle not in bridge_test:
        print(f'FAIL BW-89A5 timer ID regression missing: {needle}')
        sys.exit(1)

for forbidden in (
    'BreakWaveAccessPolicy',
    'isPlus',
    'relapse probability',
    'you are likely to relapse',
    'DateTime.now().difference',
    'createdAtIso ==',
):
    if forbidden in screen or forbidden in repo:
        print(
            f'FAIL BW-89A5 forbidden coupling/inference present: {forbidden}'
        )
        sys.exit(1)

print('PASS: BW-89A5 Reinforce the Win verified.')
