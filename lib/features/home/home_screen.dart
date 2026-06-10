// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: Legacy HomeScreen compatibility surface.
// Notes: BW-67 removes stale bootstrap copy and dead launch-risk actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'BreakWave is ready. Use the main app shell to access Home, Rescue, Log, and Support.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
