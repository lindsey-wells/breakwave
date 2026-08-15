import 'package:breakwave/features/log/domain/log_signal_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const LogSignalClassifier classifier = LogSignalClassifier();

  group('LogSignalClassifier', () {
    test('classifies behavioral and reflection entry types', () {
      expect(classifier.isBehavioralEntryType(' Urge '), isTrue);
      expect(classifier.isBehavioralEntryType('SLIP'), isTrue);
      expect(classifier.isBehavioralEntryType('victory'), isTrue);
      expect(classifier.isReflectionEntryType(' Reflection '), isTrue);
      expect(classifier.isSupportedEntryType('Reflection'), isTrue);
      expect(classifier.isSupportedEntryType('Mood'), isFalse);
    });

    test('keeps operational metadata out of user triggers', () {
      for (final String marker in <String>[
        'Rescue Completion',
        'Wave Timer',
        'Lower Now',
        'Still Strong',
        'Slipped',
      ]) {
        expect(classifier.isOperationalTrigger(marker), isTrue);
        expect(classifier.isUserTrigger(marker), isFalse);
      }

      expect(classifier.isUserTrigger(' Stress '), isTrue);
      expect(classifier.isUserTrigger(''), isFalse);
    });
  });
}
