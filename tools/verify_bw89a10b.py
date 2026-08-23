#!/usr/bin/env python3
from pathlib import Path
import argparse
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
HOME = ROOT / 'lib/features/home/presentation/home_screen.dart'
SHELL = ROOT / 'lib/features/shell/presentation/breakwave_shell.dart'
PICTURE = ROOT / 'lib/features/home/presentation/widgets/pattern_picture_card.dart'
PREPARE = ROOT / 'lib/features/home/presentation/widgets/pattern_prepare_card.dart'
TEST = ROOT / 'test/pattern_prepare_handoff_test.dart'

parser = argparse.ArgumentParser()
parser.add_argument('--expect-gap', action='store_true')
args = parser.parse_args()

for path in (HOME, SHELL, PICTURE, TEST):
    if not path.is_file():
        print(f'FAIL BW-89A10B missing required file: {path.relative_to(ROOT)}')
        raise SystemExit(1)

home = HOME.read_text(encoding='utf-8')
shell = SHELL.read_text(encoding='utf-8')
picture = PICTURE.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for historical in ('tools/verify_bw89a9.py', 'tools/verify_bw89a10a.py'):
    result = subprocess.run(
        [sys.executable, historical], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    print(result.stdout, end='')
    if result.returncode != 0:
        print(f'FAIL BW-89A10B historical contract failed: {historical}')
        raise SystemExit(1)

for needle in (
    'Prepare handoff is explicit and user controlled',
    "find.text('Prepare for the next wave')",
    "find.textContaining('choose what you want ready')",
    'expect(requested, isFalse)',
    'expect(requested, isTrue)',
):
    if needle not in test:
        print(f'FAIL BW-89A10B future regression contract missing: {needle}')
        raise SystemExit(1)

if args.expect_gap:
    absent = (
        not PREPARE.is_file()
        and 'onOpenPersonalPlan' not in home
        and "'Prepare for the next wave'" not in home
        and "'Prepare for the next wave'" not in picture
    )
    if not absent:
        print('FAIL BW-89A10B expected baseline gap is no longer clean.')
        raise SystemExit(1)
    print('PASS: BW-89A10B RED contract installed; explicit Prepare handoff is still absent as expected.')
    raise SystemExit(0)

if not PREPARE.is_file():
    print('FAIL BW-89A10B implementation gap: pattern_prepare_card.dart is missing.')
    raise SystemExit(1)

prepare = PREPARE.read_text(encoding='utf-8')

for needle in (
    'class PatternPrepareCard',
    'required this.onPrepare',
    'final VoidCallback onPrepare;',
    "'Prepare for the next wave'",
    'choose what you want ready',
    'onPressed: onPrepare',
):
    if needle not in prepare:
        print(f'FAIL BW-89A10B Prepare card contract missing: {needle}')
        raise SystemExit(1)

for forbidden in (
    'PatternObservation', 'DailyContextObservation', 'BedtimeContextObservation',
    'LogRepository', 'DailyCheckInStore', 'BedtimeModeStore',
    'PersonalRecoveryPlanStore', 'replacementAction', 'RescueScreen',
):
    if forbidden in prepare:
        print(f'FAIL BW-89A10B Prepare card has forbidden coupling: {forbidden}')
        raise SystemExit(1)

for needle in (
    "import 'widgets/pattern_prepare_card.dart';",
    'required this.onOpenPersonalPlan',
    'final VoidCallback onOpenPersonalPlan;',
    'PatternPrepareCard(',
    'onPrepare: widget.onOpenPersonalPlan',
):
    if needle not in home:
        print(f'FAIL BW-89A10B Home handoff missing: {needle}')
        raise SystemExit(1)

picture_index = home.find('const PatternPictureCard()')
prepare_index = home.find('PatternPrepareCard(')
cycle_index = home.find('const RecoveryCyclePreviewCard()')
if not (-1 < picture_index < prepare_index < cycle_index):
    print('FAIL BW-89A10B Prepare handoff must sit after Pattern Picture and before Recovery Cycle preview.')
    raise SystemExit(1)

for needle in (
    'onOpenPersonalPlan:',
    'const PersonalRecoveryPlanScreen()',
):
    if needle not in shell:
        print(f'FAIL BW-89A10B Shell navigation missing: {needle}')
        raise SystemExit(1)

if "'Prepare for the next wave'" in picture:
    print('FAIL BW-89A10B Pattern Picture itself must remain observational.')
    raise SystemExit(1)

print('PASS: BW-89A10B Recognize → Prepare handoff verified — Pattern Picture remains observational and the user explicitly chooses to open the existing recovery plan.')
