// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_signal_classifier.dart
// Purpose: Authoritative semantic classification for saved Log signals.
// Notes: BW-89A1 keeps behavioral analytics separate from operational metadata.
// ------------------------------------------------------------

class LogSignalClassifier {
  const LogSignalClassifier();

  static const Set<String> behavioralEntryTypes = <String>{
    'urge',
    'slip',
    'victory',
  };

  static const String reflectionEntryType = 'reflection';

  static const Set<String> operationalTriggerKeys = <String>{
    'rescue completion',
    'wave timer',
    'lower now',
    'still strong',
    'slipped',
  };

  String normalizeEntryType(String value) => value.trim().toLowerCase();

  String normalizeTrigger(String value) => value.trim().toLowerCase();

  bool isBehavioralEntryType(String value) =>
      behavioralEntryTypes.contains(normalizeEntryType(value));

  bool isReflectionEntryType(String value) =>
      normalizeEntryType(value) == reflectionEntryType;

  bool isSupportedEntryType(String value) =>
      isBehavioralEntryType(value) || isReflectionEntryType(value);

  bool isOperationalTrigger(String value) =>
      operationalTriggerKeys.contains(normalizeTrigger(value));

  bool isUserTrigger(String value) {
    final String normalized = normalizeTrigger(value);
    return normalized.isNotEmpty &&
        !operationalTriggerKeys.contains(normalized);
  }
}
