// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_screen.dart
// Purpose: BW-03 rescue foundation screen for BreakWave.
// Notes: BW-71A makes Rescue more active with earlier action and honest outcomes.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/breakwave_app_bar.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import 'widgets/calm_reset_card.dart';
import 'widgets/redirect_actions_card.dart';
import 'widgets/remember_why_card.dart';
import 'widgets/support_escalation_card.dart';
import 'widgets/rescue_card_engine.dart';
import 'widgets/wave_timer_card.dart';
import 'widgets/urge_intensity_section.dart';
import 'widgets/wave_completion_card.dart';

class RescueScreen extends StatefulWidget {
  final VoidCallback onReturnHome;
  final VoidCallback onOpenSupport;

  const RescueScreen({
    super.key,
    required this.onReturnHome,
    required this.onOpenSupport,
  });

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  final LogRepository _repository = const LogRepository();

  int _selectedIntensity = 3;
  String? _selectedNextAction;

  void _setIntensity(int value) {
    setState(() {
      _selectedIntensity = value;
    });
  }

  void _setNextAction(String? value) {
    setState(() {
      _selectedNextAction = value;
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

  Future<void> _saveRescueOutcome({
    required String entryType,
    required String actionTaken,
    required String betterPlan,
    required String notes,
    required String snackBarText,
    required bool returnHome,
    required bool openSupport,
  }) async {
    final String? nextAction = _selectedNextAction;

    final LogEntry entry = LogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entryType: entryType,
      intensity: _selectedIntensity,
      triggers: const <String>['Rescue Completion'],
      actionTaken: nextAction == null
          ? actionTaken
          : '$actionTaken Next right action: $nextAction',
      betterPlan: nextAction == null
          ? betterPlan
          : '$betterPlan Use $nextAction earlier when this wave appears again.',
      replacementAction: nextAction ?? '',
      notes: nextAction == null
          ? notes
          : entryType == 'Victory'
              ? 'Made it through this wave from Rescue using: $nextAction.'
              : '$notes Selected next right action: $nextAction.',
      createdAtIso: DateTime.now().toIso8601String(),
    );

    try {
      await _repository.saveEntry(entry);

      if (!mounted) return;

      if (entryType == 'Victory') {
        setState(() {
          _selectedNextAction = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackBarText),
        ),
      );

      if (openSupport) {
        widget.onOpenSupport();
        return;
      }

      if (returnHome) {
        widget.onReturnHome();
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save the wave completion right now.'),
        ),
      );
    }
  }

  Future<void> _completeWave() async {
    await _saveRescueOutcome(
      entryType: 'Victory',
      actionTaken: 'Completed Rescue.',
      betterPlan: 'Repeat this Rescue path earlier next time.',
      notes: 'Made it through this wave from Rescue.',
      snackBarText: 'Nice work. Wave saved with your next right action.',
      returnHome: true,
      openSupport: false,
    );
  }

  Future<void> _logStillStrong() async {
    await _saveRescueOutcome(
      entryType: 'Urge',
      actionTaken: 'Marked the wave as still strong from Rescue.',
      betterPlan: 'Stay in Rescue, choose one next right action, and reduce privacy or isolation.',
      notes: 'Still strong after Rescue support.',
      snackBarText: 'Still strong saved. Stay with Rescue and choose one clean next move.',
      returnHome: false,
      openSupport: false,
    );
  }

  Future<void> _logSlip() async {
    await _saveRescueOutcome(
      entryType: 'Slip',
      actionTaken: 'Marked a slip from Rescue.',
      betterPlan: 'Reduce isolation, return to the plan, and use support instead of shame.',
      notes: 'Slip logged from Rescue without shame.',
      snackBarText: 'Slip saved. Opening Support so you can choose the next safe step.',
      returnHome: false,
      openSupport: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BreakWaveAppBar(sectionTitle: 'Rescue'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
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
                  const SectionHeader(
                    eyebrow: 'Start here',
                    title: 'Name the wave, then remember why',
                  ),
                  UrgeIntensitySection(
                    selectedIntensity: _selectedIntensity,
                    onSelected: _setIntensity,
                  ),
                  const SizedBox(height: 16),
                  RememberWhyCard(onOpenSupport: widget.onOpenSupport),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Interrupt now',
                    title: 'Use one immediate redirect',
                  ),
                  RedirectActionsCard(
                    selectedAction: _selectedNextAction,
                    onActionSelected: _setNextAction,
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Ride the wave',
                    title: 'Slow the surge before it gets louder',
                  ),
                  WaveTimerCard(
                    onReturnHome: widget.onReturnHome,
                  ),
                  const SizedBox(height: 16),
                  const CalmResetCard(),
                  const SizedBox(height: 16),
                  const RescueCardEngine(),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Finish honestly',
                    title: 'Mark what happened and get support',
                  ),
                  WaveCompletionCard(
                    onComplete: _completeWave,
                    onStillStrong: _logStillStrong,
                    onSlipped: _logSlip,
                  ),
                  const SizedBox(height: 16),
                  SupportEscalationCard(
                    onOpenSupport: widget.onOpenSupport,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
