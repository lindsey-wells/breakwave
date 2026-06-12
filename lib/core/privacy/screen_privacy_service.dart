// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: screen_privacy_service.dart
// Purpose: BW-70B Android screen privacy bridge.
// Notes: Requests Android FLAG_SECURE to reduce screenshots and screen recording.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenPrivacyService {
  static const MethodChannel _channel = MethodChannel('breakwave/screen_privacy');

  static Future<bool> setScreenPrivacyEnabled(bool enabled) async {
    if (kIsWeb) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'setScreenPrivacyEnabled',
        <String, bool>{'enabled': enabled},
      );

      return result == true;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
