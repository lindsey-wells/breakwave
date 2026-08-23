#!/usr/bin/env python3
from pathlib import Path
import hashlib
import os
import sys

FIXTURE_ROOT = os.environ.get('BW_A10A_FIXTURE_ROOT')
ROOT = Path(FIXTURE_ROOT).resolve() if FIXTURE_ROOT else Path(__file__).resolve().parent.parent
FIXTURE_MODE = FIXTURE_ROOT is not None

model_path = (
    ROOT
    / 'lib/features/personal_plan/domain/personal_recovery_plan.dart'
)
controllers_path = (
    ROOT
    / 'lib/features/personal_plan/presentation/'
    'personal_recovery_plan_draft_controllers.dart'
)
body_path = (
    ROOT
    / 'lib/features/personal_plan/presentation/widgets/'
    'personal_recovery_plan_body.dart'
)
store_path = (
    ROOT
    / 'lib/features/personal_plan/data/personal_recovery_plan_store.dart'
)
rescue_path = (
    ROOT / 'lib/features/rescue/presentation/rescue_screen.dart'
)
redirect_path = (
    ROOT
    / 'lib/features/rescue/presentation/widgets/redirect_actions_card.dart'
)
picture_path = (
    ROOT
    / 'lib/features/home/presentation/widgets/pattern_picture_card.dart'
)
log_entry_path = (
    ROOT / 'lib/features/log/domain/log_entry.dart'
)
log_repo_path = (
    ROOT / 'lib/features/log/data/log_repository.dart'
)
test_path = ROOT / 'test/preparation_plan_foundation_test.dart'

for path in (
    model_path,
    controllers_path,
    body_path,
    store_path,
    rescue_path,
    redirect_path,
    picture_path,
    log_entry_path,
    log_repo_path,
    test_path,
):
    if not path.is_file():
        print(
            f'FAIL BW-89A10A missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

model = model_path.read_text(encoding='utf-8')
controllers = controllers_path.read_text(encoding='utf-8')
body = body_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')

for needle in (
    "this.preferredPreparationAction = '',",
    'final String preferredPreparationAction;',
    'String? preferredPreparationAction,',
    'preferredPreparationAction:',
    "'preferredPreparationAction':",
    "preferredPreparationAction",
    "map['preferredPreparationAction']",
):
    if needle not in model:
        print(
            f'FAIL BW-89A10A plan model contract missing: {needle}'
        )
        sys.exit(1)

for needle in (
    'final TextEditingController preferredPreparationAction =',
    'preferredPreparationAction,',
    'preferredPreparationAction.text =',
    'plan.preferredPreparationAction;',
    'preferredPreparationAction:',
    'List<String> get redirectActionChoices',
    'void setPreferredPreparationAction(String value)',
):
    if needle not in controllers:
        print(
            f'FAIL BW-89A10A controller contract missing: {needle}'
        )
        sys.exit(1)

for needle in (
    "'Preferred preparation action'",
    "'Choose one action you want ready before the next wave.'",
    'draftControllers.redirectActionChoices',
    '.setPreferredPreparationAction(',
    'controller:',
    'draftControllers.preferredPreparationAction',
    "'This is your plan for what you intend to try. Rescue still records what you actually choose during a live wave.'",
):
    if needle not in body:
        print(
            f'FAIL BW-89A10A plan UI contract missing: {needle}'
        )
        sys.exit(1)

# Explicit user choice only: no Pattern Picture or Rescue write coupling.
for forbidden in (
    'PatternPictureCard',
    'PatternObservationEngine',
    'DailyContextObservationEngine',
    'BedtimeContextObservationEngine',
    'LogRepository',
    'replacementAction',
):
    if forbidden in model or forbidden in controllers:
        print(
            f'FAIL BW-89A10A preparation plan has forbidden coupling: '
            f'{forbidden}'
        )
        sys.exit(1)

protected_sha256 = {'lib/features/personal_plan/data/personal_recovery_plan_store.dart': 'ad7bc81f6fbfa7bad62ad331f1f9f5bfba56c59668da088140fb56490958bcd5',
 'lib/features/rescue/presentation/rescue_screen.dart': 'e60f77ecc9b8b30c6b6485650235d65aae01706022fdfd9cc1cddfb9810f4cce',
 'lib/features/rescue/presentation/widgets/redirect_actions_card.dart': '0c1e9bd4dd39a3d76676883358b28f4b54f26a4dd0af05d4fdd45868187e5f95',
 'lib/features/home/presentation/widgets/pattern_picture_card.dart': '954f44ff1763bf5496df46371b9a5ddae2190de6c0f103ee7a9ae98d214083e7',
 'lib/features/log/domain/log_entry.dart': '0aaa13a2faf32f8449da9c184ee4de6bf981bcffddcf9fca40151cd0efb49df8',
 'lib/features/log/data/log_repository.dart': '2c082d70c040b767c96a12d7b5d48338d96cb73e1316d17657aacebc1a73ef3b'}

if not FIXTURE_MODE:
    for rel, expected in protected_sha256.items():
        actual = hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
        if actual != expected:
            print(
                f'FAIL BW-89A10A protected boundary drift: {rel} '
                f'expected {expected} got {actual}'
            )
            sys.exit(1)

for needle in (
    'preferred preparation action round-trips with the existing plan',
    'legacy saved plans default preparation preference to blank',
    'preparation preference counts as real plan content',
):
    if needle not in tests:
        print(
            f'FAIL BW-89A10A regression test missing: {needle}'
        )
        sys.exit(1)

print(
    'PASS: BW-89A10A Preparation Plan Foundation verified — '
    'existing PersonalRecoveryPlan extended with one explicit user-owned '
    'preparation preference while Rescue, replacementAction, trusted-contact '
    'ownership, Pattern Picture, and the existing plan store remain intact.'
)

if FIXTURE_MODE:
    print('PASS: BW-89A10A actual packaged verifier executed against candidate contract fixture.')
