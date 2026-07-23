import 'package:breakwave/core/privacy/breakwave_privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Privacy Policy uses the published BreakWave URL', () {
    expect(
      BreakWavePrivacyPolicy.url,
      'https://breakwaveapp.com/#privacy',
    );

    expect(
      BreakWavePrivacyPolicy.uri.toString(),
      BreakWavePrivacyPolicy.url,
    );
  });

  testWidgets(
    'Privacy Policy button exposes label and callback',
    (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreakWavePrivacyPolicyButton(
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(
        find.byKey(
          BreakWavePrivacyPolicyButton.widgetKey,
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          BreakWavePrivacyPolicy.buttonLabel,
        ),
        findsOneWidget,
      );

      expect(
        find.byIcon(Icons.policy_outlined),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          BreakWavePrivacyPolicyButton.widgetKey,
        ),
      );

      await tester.pump();

      expect(pressed, isTrue);
    },
  );
}
