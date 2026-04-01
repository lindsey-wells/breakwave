/// ------------------------------------------------------------
/// Cube23 Collaboration Header
/// Project: BreakWave
/// File: breakwave_app.dart
/// Purpose: Root MaterialApp wrapper for BreakWave.
/// Notes: Shell-first deterministic scaffold for BW-01.
/// ------------------------------------------------------------

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
      ),
      home: const BreakWaveShell(),
    );
  }
}
