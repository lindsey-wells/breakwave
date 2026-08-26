import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/recovery_report/domain/accountability_check_in_template.dart';

void main() {
  test(
    'A12D provides exactly three editable accountability starters',
    () {
      expect(
        AccountabilityCheckInTemplate.values,
        hasLength(3),
      );

      expect(
        AccountabilityCheckInTemplate.values
            .map((template) => template.label)
            .toList(growable: false),
        <String>[
          'Weekly check-in',
          'After-slip honesty',
          'Victory update',
        ],
      );

      for (final AccountabilityCheckInTemplate template
          in AccountabilityCheckInTemplate.values) {
        expect(template.starterText.trim(), isNotEmpty);
        expect(template.starterText, isNot(contains('phoneNumber')));
        expect(template.starterText, isNot(contains('emailAddress')));
      }
    },
  );
}
