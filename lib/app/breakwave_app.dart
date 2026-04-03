// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app.dart
// Purpose: Root MaterialApp wrapper for BreakWave.
// Notes: Shell-first deterministic scaffold for BW-06.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../core/recovery/recovery_mode_gate.dart';
import '../core/theme/breakwave_theme.dart';
import '../features/shell/presentation/breakwave_shell.dart';

class BreakWaveApp extends StatelessWidget {
  const BreakWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakWave',
      debugShowCheckedModeBanner: false,
      theme: BreakWaveTheme.dark(),
      darkTheme: BreakWaveTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const RecoveryModeGate(
        child: BreakWaveShell(),
      ),
    );
  }
}
