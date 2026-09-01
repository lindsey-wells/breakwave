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
import 'core/performance/breakwave_performance_probe.dart';
import 'core/privacy/privacy_settings.dart';
import 'core/privacy/privacy_settings_store.dart';
import 'core/privacy/screen_privacy_service.dart';
import 'core/reminders/breakwave_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Stopwatch? qaStartupTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  if (BreakWavePerformanceProbe.enabled) {
    BreakWavePerformanceProbe.installFrameTimingObserver();
  }

  final Stopwatch? notificationTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  try {
    await BreakWaveNotifications.initialize();
  } catch (_) {
    // Notification init is optional. Never let it block app launch.
  } finally {
    if (notificationTimer != null) {
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'notifications_initialize',
        stopwatch: notificationTimer,
      );
    }
  }

  final Stopwatch? privacyTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  try {
    final PrivacySettings privacy = await PrivacySettingsStore.load();
    await ScreenPrivacyService.setScreenPrivacyEnabled(
      privacy.blockScreenshotsAndScreenRecording,
    );
  } catch (_) {
    // Screen privacy is a best-effort shield. Never let it block app launch.
  } finally {
    if (privacyTimer != null) {
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'privacy_initialize',
        stopwatch: privacyTimer,
      );
    }
  }

  // WP-03V-T2 Test Store QA is an explicit build-only lane. Await
  // RevenueCat there so the Billing QA console opens against a configured
  // SDK. Production keeps the existing non-blocking bootstrap behavior.
  if (BreakWaveBillingQaConfig.enabled) {
    final Stopwatch revenueCatTimer =
        BreakWavePerformanceProbe.startTimer();
    await RevenueCatBootstrap.initialize();
    BreakWavePerformanceProbe.recordElapsed(
      category: 'startup',
      name: 'qa_revenuecat_initialize',
      stopwatch: revenueCatTimer,
    );
  }

  final Stopwatch? firstFrameTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  runApp(const BreakWaveApp());

  if (firstFrameTimer != null && qaStartupTimer != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'runApp_to_first_frame',
        stopwatch: firstFrameTimer,
      );
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'qa_entry_to_first_frame',
        stopwatch: qaStartupTimer,
      );
    });
  }

  if (!BreakWaveBillingQaConfig.enabled) {
    unawaited(RevenueCatBootstrap.initialize());
  }
}
