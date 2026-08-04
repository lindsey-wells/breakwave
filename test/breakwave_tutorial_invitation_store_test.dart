import 'package:breakwave/core/tutorial/breakwave_tutorial_invitation_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('invitation is available until a choice is saved', () async {
    expect(await BreakWaveTutorialInvitationStore.shouldOffer(), isTrue);

    await BreakWaveTutorialInvitationStore.save(
      BreakWaveTutorialInvitationChoice.accepted,
    );

    expect(await BreakWaveTutorialInvitationStore.shouldOffer(), isFalse);
    expect(
      await BreakWaveTutorialInvitationStore.load(),
      BreakWaveTutorialInvitationChoice.accepted,
    );
  });

  test('decline is stored without removing future Support replay', () async {
    await BreakWaveTutorialInvitationStore.save(
      BreakWaveTutorialInvitationChoice.declined,
    );

    expect(await BreakWaveTutorialInvitationStore.shouldOffer(), isFalse);
    expect(
      await BreakWaveTutorialInvitationStore.load(),
      BreakWaveTutorialInvitationChoice.declined,
    );
  });
}
