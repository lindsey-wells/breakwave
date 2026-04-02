// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: BW-02 home dashboard structure for BreakWave.
// Notes: Shell-first deterministic scaffold for BW-06.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
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
                  const WaveSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Home Current',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Steady water, clear direction.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'BreakWave is designed to feel calm, steady, and blue-led — like a wave you can learn to ride instead of fear.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
