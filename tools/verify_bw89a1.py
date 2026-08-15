#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

checks = {
    'lib/features/log/domain/log_signal_classifier.dart': [
        'class LogSignalClassifier',
        "'rescue completion'",
        "'wave timer'",
        "'lower now'",
        "'still strong'",
        "'slipped'",
        'isBehavioralEntryType',
        'isReflectionEntryType',
        'isSupportedEntryType',
        'isUserTrigger',
    ],
    'lib/features/insights/domain/recovery_insights_calculator.dart': [
        'LogSignalClassifier',
        'reflectionEntryCount += 1;',
        '_signalClassifier.isBehavioralEntryType',
        '_signalClassifier.isUserTrigger(display)',
    ],
    'lib/features/insights/domain/recovery_insights_snapshot.dart': [
        'final int reflectionEntryCount;',
        'int get supportedEntryCount',
    ],
    'lib/features/recovery_report/domain/recovery_report_snapshot_builder.dart': [
        'LogSignalClassifier',
        '_signalClassifier.isBehavioralEntryType',
        '_signalClassifier.isUserTrigger(display)',
    ],
    'test/log_signal_classifier_test.dart': [
        'keeps operational metadata out of user triggers',
    ],
    'test/recovery_insights_calculator_test.dart': [
        'reflection is supported but excluded from behavioral analytics',
        'operational metadata never becomes a top trigger',
    ],
}

for rel, needles in checks.items():
    path = ROOT / rel
    if not path.is_file():
        print(f'FAIL BW-89A1 missing file: {rel}')
        sys.exit(1)
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            print(f'FAIL BW-89A1 {rel} missing: {needle}')
            sys.exit(1)

report = (
    ROOT / 'test/recovery_report_snapshot_builder_test.dart'
).read_text(encoding='utf-8')
for marker in (
    'Rescue Completion',
    'Wave Timer',
    'Lower Now',
    'Still Strong',
    'Slipped',
):
    if marker not in report:
        print(f'FAIL BW-89A1 report regression set missing: {marker}')
        sys.exit(1)

print('PASS: BW-89A1 Pattern Signal Hygiene contracts are present.')
