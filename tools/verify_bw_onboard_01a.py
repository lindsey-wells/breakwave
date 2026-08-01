#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
required = {
    'lib/features/onboarding/presentation/onboarding_flow_screen.dart': [
        'Taking the first step toward changing a private',
        'We are glad you are here.',
    ],
    'lib/features/onboarding/presentation/onboarding_intro_step_details.dart': [
        'A welcome from the people behind BreakWave',
        'shake your hand and congratulate you',
        'pornography urges can feel',
        'pause, regain control, and choose what comes next',
        'You are here now, and that matters',
        'not therapy, medical treatment, a diagnosis, a cure, or an emergency service',
    ],
    'lib/features/support/presentation/support_screen.dart': [
        "eyebrow: 'About BreakWave'",
        "title: 'Who we are and why we built this'",
        'WhoWeAreCard()',
    ],
    'lib/features/support/presentation/widgets/who_we_are_card.dart': [
        'Who We Are',
        'reducing pornography',
        'fought similar battles ourselves',
        'We did not build BreakWave to judge or shame you',
        "Let's break the wave, one choice at a time.",
    ],
    'test/founder_welcome_trust_test.dart': [
        'Who We Are introduces the people and purpose',
    ],
}
failed = False
for rel, needles in required.items():
    path = ROOT / rel
    if not path.is_file():
        print(f'FAIL BW-ONBOARD-01A missing file: {rel}')
        failed = True
        continue
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            print(f'FAIL BW-ONBOARD-01A {rel} missing: {needle}')
            failed = True

support = (ROOT / 'lib/features/support/presentation/support_screen.dart').read_text(encoding='utf-8')
about = support.find("eyebrow: 'About BreakWave'")
learn = support.find("eyebrow: 'Learn and resources'")
contact = support.find("eyebrow: 'Contact BreakWave'")
if not (learn != -1 and about != -1 and contact != -1 and learn < about < contact):
    print('FAIL BW-ONBOARD-01A About BreakWave placement is not between learning and contact')
    failed = True

if failed:
    sys.exit(1)
print('PASS: BW-ONBOARD-01A founder welcome and Who We Are verified.')
