// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: main.dart
// Purpose: App entrypoint for BreakWave.
// Notes: Initializes local notifications for BW-22.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'app/breakwave_app.dart';
import 'core/reminders/breakwave_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BreakWaveNotifications.initialize();
  runApp(const BreakWaveApp());
}
