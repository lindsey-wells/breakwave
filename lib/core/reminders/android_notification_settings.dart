// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: android_notification_settings.dart
// Purpose: BW-NOTIFY-01B safe Android notification/app-settings handoff.
// ------------------------------------------------------------

import 'package:flutter/services.dart';

class AndroidNotificationSettings {
  static const MethodChannel _channel =
      MethodChannel('breakwave/notification_settings');

  static Future<bool> openNotificationSettings() async {
    try {
      return await _channel.invokeMethod<bool>(
            'openNotificationSettings',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openAppSettings() async {
    try {
      return await _channel.invokeMethod<bool>(
            'openAppSettings',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
