#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
SCREEN = ROOT / 'lib/features/personal_plan/presentation/personal_recovery_plan_screen.dart'
BODY = ROOT / 'lib/features/personal_plan/presentation/widgets/personal_recovery_plan_body.dart'
PICKER = ROOT / 'lib/features/personal_plan/presentation/widgets/confirmed_helpful_actions_picker.dart'
TEST = ROOT / 'test/confirmed_helpful_actions_picker_test.dart'
BODY_TEST = ROOT / 'test/personal_recovery_plan_body_test.dart'

for path in (SCREEN, BODY, PICKER, TEST, BODY_TEST):
    if not path.is_file():
        print(f'FAIL BW-89A11C missing required file: {path.relative_to(ROOT)}')
        raise SystemExit(1)

for historical in (
    'tools/verify_bw89a9.py',
    'tools/verify_bw89a10a.py',
    'tools/verify_bw89a10b.py',
    'tools/verify_bw89a11.py',
    'tools/verify_bw89a11b.py',
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
        print(f'FAIL BW-89A11C historical contract failed: {historical}')
        raise SystemExit(1)

screen = SCREEN.read_text(encoding='utf-8')
body = BODY.read_text(encoding='utf-8')
picker = PICKER.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
body_test = BODY_TEST.read_text(encoding='utf-8')

for needle in (
    'List<String> _confirmedHelpfulActions = const <String>[];',
    'Future<List<String>> _loadConfirmedHelpfulActions() async',
    'const LogRepository().loadEntries()',
    "entry.entryType != 'Victory'",
    'entry.replacementAction.trim()',
    'seen.add(action.toLowerCase())',
    'actions.length == 3',
    '_confirmedHelpfulActions = confirmedHelpfulActions;',
    'confirmedHelpfulActions: _confirmedHelpfulActions',
):
    if needle not in screen:
        print(f'FAIL BW-89A11C screen contract missing: {needle}')
        raise SystemExit(1)

for forbidden in (
    'PersonalRecoveryPlanStore.save(',
    'preferredPreparationAction.text = action',
    '_draftControllers.setPreferredPreparationAction(action)',
):
    if forbidden in screen:
        print(f'FAIL BW-89A11C screen performs forbidden auto-write: {forbidden}')
        raise SystemExit(1)

for needle in (
    "import 'confirmed_helpful_actions_picker.dart';",
    'required this.confirmedHelpfulActions,',
    'final List<String> confirmedHelpfulActions;',
    'ConfirmedHelpfulActionsPicker(',
    'actions: confirmedHelpfulActions',
    'selectedAction:',
    'draftControllers.preferredPreparationAction.text.trim()',
    'onUseAction: (String action)',
    'draftControllers.setPreferredPreparationAction(action)',
):
    if needle not in body:
        print(f'FAIL BW-89A11C plan body contract missing: {needle}')
        raise SystemExit(1)

picker_needles = (
    'class ConfirmedHelpfulActionsPicker',
    "'Helpful actions you confirmed'",
    'victories where you said an action helped',
    'not recommending ',
    'what you should do next.',
    'onPressed: () => onUseAction(actions[index])',
    "'Use ${actions[index]} in my plan'",
    'Nothing changes unless you choose an action, and it is not ',
    "'saved until you save your recovery plan.'",
)
for needle in picker_needles:
    if needle not in picker:
        print(f'FAIL BW-89A11C picker contract missing: {needle}')
        raise SystemExit(1)

for forbidden in (
    'LogRepository',
    'PersonalRecoveryPlanStore',
    'Navigator.',
    'riskScore',
    'probability',
    'recommendedAction',
    'bestAction',
    'autoSave',
):
    if forbidden in picker:
        print(f'FAIL BW-89A11C picker has forbidden coupling/inference: {forbidden}')
        raise SystemExit(1)

for needle in (
    'confirmed helpful actions require an explicit user choice',
    'expect(chosen, isNull)',
    "expect(chosen, 'Leave the room')",
    "find.text('Use Leave the room in my plan')",
    "find.textContaining('not recommending what you should do next')",
    'picker disappears when there is no confirmed helpful evidence',
):
    if needle not in test:
        print(f'FAIL BW-89A11C widget regression missing: {needle}')
        raise SystemExit(1)

for needle in (
    'List<String> confirmedHelpfulActions = const <String>[]',
    'confirmedHelpfulActions: confirmedHelpfulActions',
    'confirmed helpful actions stay user owned through the body integration',
    "confirmedHelpfulActions: const <String>['Leave the room']",
    'controllers.preferredPreparationAction.text',
    "'Use Leave the room in my plan'",
):
    if needle not in body_test:
        print(f'FAIL BW-89A11C body integration regression missing: {needle}')
        raise SystemExit(1)

print(
    'PASS: BW-89A11C Plan reuse verified — confirmed Victory actions are '
    'loaded read-only and enter the existing preparation preference only '
    'after an explicit user choice; saving remains explicit and existing.'
)
