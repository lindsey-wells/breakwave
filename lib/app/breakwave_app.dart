// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app.dart
// Purpose: Root MaterialApp wrapper for BreakWave.
// Notes: Shell-first deterministic scaffold for BW-02.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../features/shell/presentation/breakwave_shell.dart';

class BreakWaveApp extends StatelessWidget {
  const BreakWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakWave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const BreakWaveShell(),
    );
  }
}
