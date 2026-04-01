// BreakWave
// Created in collaboration with Cube23 Holdings LLC.

import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../theme/app_theme.dart';

class BreakWaveApp extends StatelessWidget {
  const BreakWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakWave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
