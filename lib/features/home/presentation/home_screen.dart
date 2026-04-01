// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: BW-02 home dashboard structure for BreakWave.
// Notes: Shell-first deterministic scaffold for BW-02.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'widgets/daily_encouragement_card.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/recovery_cycle_preview_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenLog;

  const HomeScreen({
    super.key,
    required this.onOpenRescue,
    required this.onOpenLog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakWave'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  HomeHeroCard(
                    onOpenRescue: onOpenRescue,
                    onOpenLog: onOpenLog,
                  ),
                  const SizedBox(height: 16),
                  const RecoveryCyclePreviewCard(),
                  const SizedBox(height: 16),
                  const DailyEncouragementCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
