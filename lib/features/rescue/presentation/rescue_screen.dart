// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_screen.dart
// Purpose: BW-03 rescue foundation screen for BreakWave.
// Notes: Neutral rescue flow scaffold for BW-03.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'widgets/calm_reset_card.dart';
import 'widgets/redirect_actions_card.dart';
import 'widgets/support_escalation_card.dart';
import 'widgets/urge_intensity_section.dart';
import 'widgets/wave_completion_card.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  int _selectedIntensity = 3;

  void _setIntensity(int value) {
    setState(() {
      _selectedIntensity = value;
    });
  }

  String get _intensityLabel {
    switch (_selectedIntensity) {
      case 1:
        return 'Low';
      case 2:
        return 'Shaky';
      case 3:
        return 'Strong';
      case 4:
        return 'High Risk';
      case 5:
        return 'Critical';
      default:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rescue'),
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
                  Text(
                    'Take the next steady step.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are in Rescue mode. Slow this moment down, lower the pressure, and interrupt the pattern.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current intensity: $_intensityLabel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  UrgeIntensitySection(
                    selectedIntensity: _selectedIntensity,
                    onSelected: _setIntensity,
                  ),
                  const SizedBox(height: 16),
                  const CalmResetCard(),
                  const SizedBox(height: 16),
                  const RedirectActionsCard(),
                  const SizedBox(height: 16),
                  const WaveCompletionCard(),
                  const SizedBox(height: 16),
                  const SupportEscalationCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
