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

Future<void> _reconcileScreenPrivacyAfterNativeLaunch(
  bool enabled,
) async {
  final Stopwatch? privacyShieldTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  try {
    await ScreenPrivacyService.setScreenPrivacyEnabled(enabled);
  } catch (_) {
    // Android already applied the launch guard. Reconciliation is best effort.
  } finally {
    if (privacyShieldTimer != null) {
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'privacy_screen_shield_reconcile',
        stopwatch: privacyShieldTimer,
      );
    }
  }
}

Future<void> _warmNotificationsAfterFirstFrame() async {
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
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Stopwatch? qaStartupTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  if (BreakWavePerformanceProbe.enabled) {
    BreakWavePerformanceProbe.installFrameTimingObserver();
  }

  final Stopwatch? privacyTimer =
      BreakWavePerformanceProbe.enabled
          ? BreakWavePerformanceProbe.startTimer()
          : null;

  try {
    final Stopwatch? privacySettingsTimer =
        BreakWavePerformanceProbe.enabled
            ? BreakWavePerformanceProbe.startTimer()
            : null;
    final PrivacySettings privacy = await PrivacySettingsStore.load();
    if (privacySettingsTimer != null) {
      BreakWavePerformanceProbe.recordElapsed(
        category: 'startup',
        name: 'privacy_settings_load',
        stopwatch: privacySettingsTimer,
      );
    }

    // Android applies the launch guard before FlutterActivity.onCreate.
    // Reconcile the actual Flutter preference without holding the first frame.
    unawaited(
      _reconcileScreenPrivacyAfterNativeLaunch(
        privacy.blockScreenshotsAndScreenRecording,
      ),
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (firstFrameTimer != null && qaStartupTimer != null) {
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
    }

    unawaited(_warmNotificationsAfterFirstFrame());
  });

  if (!BreakWaveBillingQaConfig.enabled) {
    unawaited(RevenueCatBootstrap.initialize());
  }
}
