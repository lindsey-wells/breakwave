// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_screen.dart
// Purpose: BW-03 rescue foundation screen for BreakWave.
// Notes: BW-76A keeps Rescue active after a still-strong outcome.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/education/contextual_first_visit_education.dart';
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
  final VoidCallback onOpenLog;

  const RescueScreen({
    super.key,
    required this.onReturnHome,
    required this.onOpenSupport,
    required this.onOpenLog,
  });

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  final LogRepository _repository = const LogRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rememberWhyKey = GlobalKey();
  final GlobalKey _redirectActionsKey = GlobalKey();
  final GlobalKey _calmResetKey = GlobalKey();
  final GlobalKey _outcomeFollowUpKey = GlobalKey();

  int _selectedIntensity = 3;
  String? _selectedNextAction;
  String? _completedNextAction;
  bool _showStillStrongFollowUp = false;
  bool _showWaveSavedFollowUp = false;

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

  String? get _redirectBridgeAction =>
      _selectedNextAction ?? _completedNextAction;

  void _scrollToOutcomeFollowUpAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollTo(_outcomeFollowUpKey);
    });
  }

  Future<void> _handleWaveTimerOutcomeSaved(
    String entryType,
    String _outcomeTag,
  ) async {
    if (!mounted) return;

    if (entryType == 'Slip') {
      setState(() {
        _selectedNextAction = null;
        _completedNextAction = null;
        _showStillStrongFollowUp = false;
        _showWaveSavedFollowUp = false;
      });
      widget.onOpenSupport();
      return;
    }

    setState(() {
      if (entryType == 'Victory') {
        _completedNextAction = _selectedNextAction;
        _selectedNextAction = null;
        _showStillStrongFollowUp = false;
        _showWaveSavedFollowUp = true;
      } else {
        _completedNextAction = null;
        _showStillStrongFollowUp = true;
        _showWaveSavedFollowUp = false;
      }
    });

    _scrollToOutcomeFollowUpAfterBuild();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final BuildContext? targetContext = key.currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
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
          _completedNextAction = nextAction;
          _selectedNextAction = null;
          _showStillStrongFollowUp = false;
          _showWaveSavedFollowUp = true;
        });
      } else if (entryType == 'Urge') {
        setState(() {
          _completedNextAction = null;
          _showStillStrongFollowUp = true;
          _showWaveSavedFollowUp = false;
        });
      } else if (entryType == 'Slip') {
        setState(() {
          _completedNextAction = null;
          _showStillStrongFollowUp = false;
          _showWaveSavedFollowUp = false;
        });
      }

      if (entryType == 'Victory' || entryType == 'Urge') {
        _scrollToOutcomeFollowUpAfterBuild();
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
      snackBarText: 'Wave saved. You made it through this wave.',
      returnHome: false,
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

  Widget _buildWaveSavedFollowUpCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? redirectAction = _redirectBridgeAction;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Wave saved',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You made it through this wave. This victory was saved to your Log.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Protect the next few minutes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (redirectAction == null) ...<Widget>[
              Text(
                'Choose one next right action before returning to the same environment.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _scrollTo(_redirectActionsKey),
                icon: const Icon(Icons.directions_walk_outlined),
                label: const Text('Choose a next right action'),
              ),
            ] else ...<Widget>[
              Text(
                'Your next right action: $redirectAction',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Do that now. Keep the interruption going before returning to the same environment.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _scrollTo(_redirectActionsKey),
                icon: const Icon(Icons.swap_horiz_outlined),
                label: const Text('Choose a different action'),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.onOpenLog,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Open Log'),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: widget.onReturnHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Return Home'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showWaveSavedFollowUp = false;
                  _completedNextAction = null;
                });
              },
              icon: const Icon(Icons.waves_outlined),
              label: const Text('Stay in Rescue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStillStrongFollowUpCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The wave is still here',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Stay with Rescue. Choose one clean next move before you go back to the same setup.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _scrollTo(_calmResetKey),
              icon: const Icon(Icons.self_improvement_outlined),
              label: const Text('Return to Calm Reset'),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_redirectActionsKey),
              icon: const Icon(Icons.directions_walk_outlined),
              label: const Text('Choose a redirect action'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onOpenSupport,
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Open Support'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BreakWaveAppBar(sectionTitle: 'Rescue'),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                  const SizedBox(height: 12),
                  const ContextualFirstVisitEducationCard(
                    surface: BreakWaveEducationSurface.rescue,
                    eyebrow: 'First visit • Interrupt + Redirect',
                    title: 'Use Rescue when the wave is rising',
                    body:
                        'Name the intensity, bring your Personal Why into view, '
                        'then choose one next right action. You do not need to '
                        'Log anything before using Rescue.',
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _rememberWhyKey,
                    child: RememberWhyCard(onOpenSupport: widget.onOpenSupport),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Interrupt now',
                    title: 'Use one immediate redirect',
                  ),
                  KeyedSubtree(
                    key: _redirectActionsKey,
                    child: RedirectActionsCard(
                      selectedAction: _selectedNextAction,
                      onActionSelected: _setNextAction,
                      onOpenWhy: () => _scrollTo(_rememberWhyKey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Ride the wave',
                    title: 'Slow the surge before it gets louder',
                  ),
                  WaveTimerCard(
                    onReturnHome: widget.onReturnHome,
                    onOutcomeSaved: _handleWaveTimerOutcomeSaved,
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _calmResetKey,
                    child: const CalmResetCard(),
                  ),
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
                  if (_showWaveSavedFollowUp ||
                      _showStillStrongFollowUp)
                    SizedBox(
                      key: _outcomeFollowUpKey,
                      height: 0,
                    ),
                    if (_showWaveSavedFollowUp) ...<Widget>[
                      const SizedBox(height: 16),
                      _buildWaveSavedFollowUpCard(context),
                    ],
                  if (_showStillStrongFollowUp) ...<Widget>[
                    const SizedBox(height: 16),
                    _buildStillStrongFollowUpCard(context),
                  ],
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
