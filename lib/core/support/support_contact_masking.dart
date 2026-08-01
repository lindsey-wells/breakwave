// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_masking.dart
// Purpose: Privacy-safe display formatting for trusted contact details.
// Notes: BW-PRIVACY-01A masks read-only contact details by default.
// ------------------------------------------------------------

class SupportContactMasking {
  const SupportContactMasking._();

  static String phone(String rawValue) {
    final String value = rawValue.trim();
    if (value.isEmpty) return '';

    final int digitCount = RegExp(r'\d').allMatches(value).length;
    if (digitCount == 0) return _maskGeneric(value);

    final int hiddenDigits = digitCount > 4 ? digitCount - 4 : digitCount;
    int seenDigits = 0;
    final StringBuffer masked = StringBuffer();

    for (final int rune in value.runes) {
      final String character = String.fromCharCode(rune);
      if (RegExp(r'\d').hasMatch(character)) {
        masked.write(seenDigits < hiddenDigits ? '•' : character);
        seenDigits += 1;
      } else {
        masked.write(character);
      }
    }

    return masked.toString();
  }

  static String email(String rawValue) {
    final String value = rawValue.trim();
    if (value.isEmpty) return '';

    final int atIndex = value.lastIndexOf('@');
    if (atIndex <= 0 || atIndex == value.length - 1) {
      return _maskGeneric(value);
    }

    final String localPart = value.substring(0, atIndex);
    final String domainPart = value.substring(atIndex + 1);
    final List<int> localRunes = localPart.runes.toList(growable: false);

    final String maskedLocal;
    if (localRunes.length <= 1) {
      maskedLocal = '•';
    } else {
      maskedLocal = String.fromCharCode(localRunes.first) +
          List<String>.filled(localRunes.length - 1, '•').join();
    }

    return '$maskedLocal@$domainPart';
  }

  static String _maskGeneric(String value) {
    final List<int> runes = value.runes.toList(growable: false);
    if (runes.isEmpty) return '';
    if (runes.length == 1) return '•';

    return String.fromCharCode(runes.first) +
        List<String>.filled(runes.length - 1, '•').join();
  }
}
