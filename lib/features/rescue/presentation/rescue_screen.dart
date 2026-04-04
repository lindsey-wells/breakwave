// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_screen.dart
// Purpose: BW-03 rescue foundation screen for BreakWave.
// Notes: BW-10 completion saves and returns home.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import 'widgets/calm_reset_card.dart';
import 'widgets/redirect_actions_card.dart';
import 'widgets/support_escalation_card.dart';
import 'widgets/rescue_card_engine.dart';
import 'widgets/wave_timer_card.dart';
import 'widgets/urge_intensity_section.dart';
import 'widgets/wave_completion_card.dart';

class RescueScreen extends StatefulWidget {
  final VoidCallback onReturnHome;

  const RescueScreen({
    super.key,
    required this.onReturnHome,
  });

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  final LogRepository _repository = const LogRepository();

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

  Future<void> _completeWave() async {
    final LogEntry entry = LogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entryType: 'Victory',
      intensity: _selectedIntensity,
      triggers: const <String>['Rescue Completion'],
      notes: 'Made it through this wave from Rescue.',
      createdAtIso: DateTime.now().toIso8601String(),
    );

    try {
      await _repository.saveEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nice work. Wave saved and returning home.'),
        ),
      );

      widget.onReturnHome();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save the wave completion right now.'),
        ),
      );
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
                  WaveSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Rescue Tide',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Slow the surge. Ride the wave.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current intensity: $_intensityLabel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  WaveTimerCard(
                    onReturnHome: widget.onReturnHome,
                  ),
                  const SizedBox(height: 16),
                  const RescueCardEngine(),
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
                  WaveCompletionCard(
                    onComplete: _completeWave,
                  ),
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
