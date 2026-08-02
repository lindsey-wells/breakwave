#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
screen_path = ROOT / 'lib/features/support/presentation/support_screen.dart'
contract_path = ROOT / 'docs/BW_SUPPORT_01C_STRUCTURE_CONTRACT.md'

failed = False
for path in [screen_path, contract_path]:
    if not path.is_file():
        print(f'FAIL BW-SUPPORT-01C missing file: {path.relative_to(ROOT)}')
        failed = True

if failed:
    sys.exit(1)

screen = screen_path.read_text(encoding='utf-8')
contract = contract_path.read_text(encoding='utf-8')

for needle in [
    'BW-SUPPORT-01C creates a compact task-based Support structure.',
    'Find the right support for this moment.',
    'Immediate help stays first.',
    "key: Key('support-help-now-group')",
    "key: Key('support-recovery-setup-group')",
    "key: Key('support-learn-breakwave-group')",
    "key: Key('support-privacy-safety-group')",
    "key: const Key('support-plus-group')",
    "key: Key('support-about-contact-group')",
    "key: Key('support-more-tools-group')",
    "title: 'Get help now'",
    "title: 'Set up your recovery'",
    "title: 'Learn how BreakWave helps'",
    "title: 'Privacy and safety'",
    "title: 'Explore BreakWave Plus'",
    "title: 'About and contact'",
    "title: 'More tools'",
    'BW-ONBOARD-01B inserts the replayable tutorial first here.',
    'maintainState: true',
    'dense: true',
    'visualDensity: VisualDensity.compact',
    'margin: EdgeInsets.zero',
    'EdgeInsets.fromLTRB(16, 16, 16, 150)',
]:
    if needle not in screen:
        print(f'FAIL BW-SUPPORT-01C support_screen.dart missing: {needle}')
        failed = True

order = [
    'support-help-now-group',
    'support-recovery-setup-group',
    'support-learn-breakwave-group',
    'support-privacy-safety-group',
    'support-plus-group',
    'support-about-contact-group',
    'support-more-tools-group',
]
positions = [screen.find(marker) for marker in order]
if any(position == -1 for position in positions) or positions != sorted(positions):
    print('FAIL BW-SUPPORT-01C task groups are missing or out of order')
    failed = True

group_invocations = re.findall(
    r"(?:const\s+)?_SupportGroup\(\s*"
    r"key:\s*(?:const\s+)?Key\('support-[^']+-group'\)",
    screen,
)
if len(group_invocations) != 7:
    print(
        'FAIL BW-SUPPORT-01C expected exactly seven '
        f'task-based group invocations, found {len(group_invocations)}'
    )
    failed = True

help_start = screen.find('support-help-now-group')
help_end = screen.find('support-recovery-setup-group')
help_group = screen[help_start:help_end]
for needle in [
    'initiallyExpanded: true',
    'EmergencyHelpCard()',
    'SupportContactCard()',
    'SupportQuickActionsCard()',
    'TrustedAccountabilityCard()',
]:
    if needle not in help_group:
        print(f'FAIL BW-SUPPORT-01C immediate group missing: {needle}')
        failed = True

learn_start = screen.find('support-learn-breakwave-group')
learn_end = screen.find('support-privacy-safety-group')
learn_group = screen[learn_start:learn_end]
for needle in [
    'CbtInformedSupportCard()',
    'ProfessionalHelpCard()',
    'SupportCategoriesCard()',
    'EducationResourcesCard()',
    'EducateMeEntryCard()',
]:
    if needle not in learn_group:
        print(f'FAIL BW-SUPPORT-01C learning group missing: {needle}')
        failed = True

about_start = screen.find('support-about-contact-group')
about_end = screen.find('support-more-tools-group')
about_group = screen[about_start:about_end]
for needle in [
    'WhoWeAreCard()',
    'EmailCaptureSettingsCard()',
    'EmailAppHandoffCard()',
    'BreakWaveContactLinksCard()',
]:
    if needle not in about_group:
        print(f'FAIL BW-SUPPORT-01C about/contact group missing: {needle}')
        failed = True

for stale in [
    "eyebrow: 'Recovery model'",
    "title: 'Cognitive behavioral tools, not shame'",
    "title: 'Go deeper than emergency interruption'",
    "eyebrow: 'Advanced'",
]:
    if stale in screen:
        print(f'FAIL BW-SUPPORT-01C stale top-level structure remains: {stale}')
        failed = True

for needle in [
    'Get help now remains first and expanded by default.',
    'Seven task-based groups replace nine similarly weighted groups.',
    'Teach Me How to Use BreakWave belongs first in the learning group.',
    'No emergency, privacy, contact, learning, Plus, or export function is removed.',
]:
    if needle not in contract:
        print(f'FAIL BW-SUPPORT-01C contract missing: {needle}')
        failed = True

if failed:
    sys.exit(1)

print('PASS: BW-SUPPORT-01C compact Support structure and preserved functionality verified.')
