// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: main.dart
// Purpose: App entrypoint for BreakWave.
// Notes: Initializes local notifications for BW-22 and hardens launch for BW-34.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';

import 'app/breakwave_app.dart';
import 'core/billing/breakwave_billing_qa_config.dart';
import 'core/billing/revenuecat_bootstrap.dart';
import 'core/privacy/privacy_settings.dart';
import 'core/privacy/privacy_settings_store.dart';
import 'core/privacy/screen_privacy_service.dart';
import 'core/reminders/breakwave_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await BreakWaveNotifications.initialize();
  } catch (_) {
    // Notification init is optional. Never let it block app launch.
  }

  try {
    final PrivacySettings privacy = await PrivacySettingsStore.load();
    await ScreenPrivacyService.setScreenPrivacyEnabled(
      privacy.blockScreenshotsAndScreenRecording,
    );
  } catch (_) {
    // Screen privacy is a best-effort shield. Never let it block app launch.
  }

  // WP-03V-T2 Test Store QA is an explicit build-only lane. Await
  // RevenueCat there so the Billing QA console opens against a configured
  // SDK. Production keeps the existing non-blocking bootstrap behavior.
  if (BreakWaveBillingQaConfig.enabled) {
    await RevenueCatBootstrap.initialize();
  }

  runApp(const BreakWaveApp());

  if (!BreakWaveBillingQaConfig.enabled) {
    unawaited(RevenueCatBootstrap.initialize());
  }
}
