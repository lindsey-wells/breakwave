import 'package:breakwave/core/branding/breakwave_wordmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'BreakWave wordmark uses approved asset and metadata',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreakWaveWordmark(),
          ),
        ),
      );

      expect(
        find.byKey(BreakWaveWordmark.widgetKey),
        findsOneWidget,
      );

      expect(
        find.byKey(BreakWaveWordmark.semanticsKey),
        findsOneWidget,
      );

      expect(
        find.byKey(BreakWaveWordmark.imageKey),
        findsOneWidget,
      );

      final Semantics semantics =
          tester.widget<Semantics>(
        find.byKey(BreakWaveWordmark.semanticsKey),
      );

      expect(
        semantics.properties.label,
        BreakWaveWordmark.semanticLabel,
      );

      expect(
        semantics.properties.image,
        isTrue,
      );

      final Image image = tester.widget<Image>(
        find.byKey(BreakWaveWordmark.imageKey),
      );

      expect(image.image, isA<AssetImage>());

      final AssetImage provider =
          image.image as AssetImage;

      expect(
        provider.assetName,
        BreakWaveWordmark.assetPath,
      );

      expect(image.fit, BoxFit.contain);
      expect(image.errorBuilder, isNotNull);
    },
  );
}
