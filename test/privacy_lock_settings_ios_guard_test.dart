import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/support/presentation/widgets/privacy_lock_settings_card.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS settings guard exposes no legacy raw-PIN entry controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PrivacyLockSettingsCard(),
        ),
      ),
    );

    expect(
      find.textContaining('Keychain protection'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Save privacy lock'), findsNothing);
    expect(find.text('Clear privacy lock'), findsNothing);
  });
}
