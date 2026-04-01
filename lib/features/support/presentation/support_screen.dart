/// ------------------------------------------------------------
/// Cube23 Collaboration Header
/// Project: BreakWave
/// File: support_screen.dart
/// Purpose: First-pass support screen placeholder for BreakWave.
/// Notes: Shell-first deterministic scaffold for BW-01.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Support',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tools, guidance, and help resources will live here.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Support options coming soon'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
