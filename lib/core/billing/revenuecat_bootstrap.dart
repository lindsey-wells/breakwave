// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: revenuecat_bootstrap.dart
// Purpose: Optional Android RevenueCat SDK bootstrap.
// Notes: WP-03S only. No purchase UI or entitlement authority.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatBootstrap {
  RevenueCatBootstrap._();

  static const String _androidPublicSdkKey =
      String.fromEnvironment(
    'BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY',
  );

  static bool get hasAndroidPublicSdkKey =>
      _androidPublicSdkKey.trim().isNotEmpty;

  static Future<void> initialize() async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        !hasAndroidPublicSdkKey) {
      return;
    }

    try {
      if (await Purchases.isConfigured) {
        return;
      }

      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info,
      );

      final PurchasesConfiguration configuration =
          PurchasesConfiguration(_androidPublicSdkKey);

      configuration.entitlementVerificationMode =
          EntitlementVerificationMode.informational;

      await Purchases.configure(configuration);
    } catch (_) {
      // RevenueCat initialization is optional at app launch.
      // Billing failure must never become recovery failure.
    }
  }
}
