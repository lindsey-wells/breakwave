import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preferred preparation action round-trips with the existing plan', () {
    final PersonalRecoveryPlan plan = PersonalRecoveryPlan.empty.copyWith(
      redirectActions: const <String>[
        'Put the phone down',
        'Text someone safe',
      ],
      preferredPreparationAction: 'Text someone safe',
    );

    final PersonalRecoveryPlan decoded =
        PersonalRecoveryPlan.fromMap(plan.toMap());

    expect(decoded.redirectActions, <String>[
      'Put the phone down',
      'Text someone safe',
    ]);
    expect(
      decoded.preferredPreparationAction,
      'Text someone safe',
    );
  });

  test('legacy saved plans default preparation preference to blank', () {
    final PersonalRecoveryPlan decoded =
        PersonalRecoveryPlan.fromMap(<String, dynamic>{
      'reasons': <String>['Integrity'],
      'redirectActions': <String>['Leave the room'],
    });

    expect(decoded.preferredPreparationAction, isEmpty);
    expect(decoded.redirectActions, <String>['Leave the room']);
  });

  test('preparation preference counts as real plan content', () {
    final PersonalRecoveryPlan plan = PersonalRecoveryPlan.empty.copyWith(
      preferredPreparationAction: 'Put the phone down',
    );

    expect(plan.hasAnyContent, isTrue);
  });
}
