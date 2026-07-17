// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_flow_screen.dart
// Purpose: Resumable ten-step onboarding navigation shell.
// Notes: BW-87B6P3B1 adds progress, back, skip, and Rescue.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_completion_service.dart';
import '../../../core/onboarding/onboarding_draft.dart';
import '../../../core/onboarding/onboarding_draft_store.dart';
import '../../../core/onboarding/onboarding_state.dart';
import '../../../core/onboarding/onboarding_state_store.dart';
import '../../../core/recovery/recovery_mode.dart';
import '../../../core/ui/wave_surface.dart';
import 'onboarding_access_step_details.dart';
import 'onboarding_actions_step_details.dart';
import 'onboarding_intro_step_details.dart';
import 'onboarding_patterns_step_details.dart';
import 'onboarding_reasons_step_details.dart';
import 'onboarding_rescue_route.dart';
import 'onboarding_summary_step_details.dart';

class OnboardingFlowScreen
    extends StatefulWidget {
  const OnboardingFlowScreen({
    super.key,
    required this.initialStep,
    required this.onFinished,
    this.onReviewPlusRequested,
  });

  final int initialStep;
  final ValueChanged<OnboardingStatus>
      onFinished;
  final VoidCallback? onReviewPlusRequested;

  @override
  State<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState
    extends State<OnboardingFlowScreen> {
  static const OnboardingCompletionService
      _completionService =
      OnboardingCompletionService();

  final ScrollController _contentScrollController =
      ScrollController();

  static const List<_OnboardingShellStep>
      _steps = <_OnboardingShellStep>[
    _OnboardingShellStep(
      icon: Icons.waving_hand_outlined,
      title: 'Welcome to BreakWave',
      body:
          'BreakWave is built for the moment an urge '
          'starts rising—not after it has already '
          'taken over.',
    ),
    _OnboardingShellStep(
      icon: Icons.shield_outlined,
      title: 'Privacy comes first',
      body:
          'Your recovery setup stays local to this '
          'device. You remain in control of what '
          'you save and share.',
    ),
    _OnboardingShellStep(
      icon: Icons.record_voice_over_outlined,
      title: 'Your recovery voice',
      body:
          'Choose whether BreakWave should support '
          'you with practical secular language or '
          'an explicitly Christian approach.',
    ),
    _OnboardingShellStep(
      icon: Icons.support_agent_outlined,
      title: 'What support helps?',
      body:
          'BreakWave can focus on fast interruption, '
          'pattern awareness, planning, encouragement, '
          'or a combination of those needs.',
    ),
    _OnboardingShellStep(
      icon: Icons.favorite_border,
      title: 'What are you protecting?',
      body:
          'Your reasons matter most when the wave '
          'starts bargaining. Keep the important '
          'things close and specific.',
    ),
    _OnboardingShellStep(
      icon: Icons.visibility_outlined,
      title: 'Notice your triggers',
      body:
          'Seeing stress, loneliness, boredom, '
          'scrolling, fatigue, and other signals '
          'earlier creates room to choose differently.',
    ),
    _OnboardingShellStep(
      icon: Icons.schedule_outlined,
      title: 'Find your risky windows',
      body:
          'Certain times, places, and situations may '
          'make the old pattern easier to enter. '
          'Preparation reduces surprise.',
    ),
    _OnboardingShellStep(
      icon: Icons.alt_route_outlined,
      title: 'Choose interruption moves',
      body:
          'Simple physical actions can break momentum: '
          'leave the room, put down the phone, walk, '
          'reset, or contact someone safe.',
    ),
    _OnboardingShellStep(
      icon: Icons.assignment_outlined,
      title: 'Build your starter plan',
      body:
          'BreakWave will bring your reasons, '
          'triggers, risky windows, and next actions '
          'together into one practical starting plan.',
    ),
    _OnboardingShellStep(
      icon: Icons.water_outlined,
      title: 'Choose how to continue',
      body:
          'Core Rescue and recovery tools remain '
          'available free. BreakWave Plus will add '
          'deeper planning, insights, and guided tools.',
    ),
  ];

  late int _step;
  bool _busy = false;
  bool _draftLoading = true;
  int _draftRevision = 0;
  Future<void> _draftSaveQueue =
      Future<void>.value();
  OnboardingDraft _draft =
      OnboardingDraft.empty;

  @override
  void initState() {
    super.initState();

    _step = widget.initialStep.clamp(
      0,
      OnboardingState.totalSteps - 1,
    );

    _loadDraft();
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  void _resetContentScroll() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_contentScrollController.hasClients) {
          return;
        }

        _contentScrollController.jumpTo(0);
      },
    );
  }

  Future<void> _loadDraft() async {
    try {
      final OnboardingDraft loaded =
          await OnboardingDraftStore.load();

      if (!mounted) return;

      setState(() {
        _draft = loaded;
        _draftLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _draft = OnboardingDraft.empty;
        _draftLoading = false;
      });
    }
  }

  Future<void> _replaceDraft(
    OnboardingDraft next,
  ) async {
    if (_draftLoading) return;

    final int revision = ++_draftRevision;

    setState(() {
      _draft = next;
    });

    _draftSaveQueue = _draftSaveQueue.then(
      (_) async {
        try {
          final OnboardingDraft saved =
              await OnboardingDraftStore.save(
            next,
          );

          if (!mounted ||
              revision != _draftRevision) {
            return;
          }

          setState(() {
            _draft = saved;
          });
        } catch (_) {
          if (!mounted ||
              revision != _draftRevision) {
            return;
          }

          _showError(
            'BreakWave could not save that setup '
            'choice yet. Your current choices remain '
            'on this screen; please try Continue again.',
          );
        }
      },
    );

    await _draftSaveQueue;
  }

  Future<void> _setRecoveryMode(
    RecoveryMode mode,
  ) async {
    final List<String> actions =
        mode == RecoveryMode.christian
            ? _draft.interruptionActions
            : _draft.interruptionActions
                .where(
                  (String action) =>
                      action != 'Pray for one minute',
                )
                .toList();

    await _replaceDraft(
      _draft.copyWith(
        recoveryMode: mode,
        interruptionActions: actions,
      ),
    );
  }

  Future<void> _setSupportNeed(
    String value,
    bool selected,
  ) async {
    final List<String> updated =
        List<String>.from(
      _draft.supportNeeds,
    );

    if (selected) {
      if (!updated.contains(value)) {
        updated.add(value);
      }
    } else {
      updated.remove(value);
    }

    await _replaceDraft(
      _draft.copyWith(
        supportNeeds: updated,
      ),
    );
  }

  Future<void> _setTriggers(
    List<String> values,
  ) async {
    await _replaceDraft(
      _draft.copyWith(triggers: values),
    );
  }

  Future<void> _setRiskyTimes(
    List<String> values,
  ) async {
    await _replaceDraft(
      _draft.copyWith(riskyTimes: values),
    );
  }

  Future<void> _setInterruptionActions(
    List<String> values,
  ) async {
    await _replaceDraft(
      _draft.copyWith(
        interruptionActions: values,
      ),
    );
  }

  Future<void> _setAccessChoice(
    OnboardingAccessChoice value,
  ) async {
    await _replaceDraft(
      _draft.copyWith(accessChoice: value),
    );
  }

  Future<void> _setReasons(
    List<String> reasons,
    String currentFocus,
  ) async {
    await _replaceDraft(
      _draft.copyWith(
        reasons: reasons,
        currentFocus: currentFocus,
      ),
    );
  }

  void _setWhyText(
    String value,
  ) {
    if (_draftLoading) return;

    // Invalidate any older queued save snapshot so it
    // cannot overwrite text typed after that save began.
    _draftRevision++;

    setState(() {
      _draft = _draft.copyWith(
        whyText: value,
      );
    });
  }

  bool _isCurrentFocusValid() {
    final String requested =
        _draft.currentFocus
            .trim()
            .toLowerCase();

    if (requested.isEmpty) return false;

    return _draft.reasons.any(
      (String reason) =>
          reason.trim().toLowerCase() ==
          requested,
    );
  }

  bool get _canContinueCurrentStep {
    if (_draftLoading) return false;

    switch (_step) {
      case 2:
        return _draft.recoveryMode != null;
      case 3:
        return _draft.supportNeeds.isNotEmpty;
      case 4:
        return _draft.reasons.isNotEmpty &&
            _isCurrentFocusValid();
      case 9:
        return _draft.accessChoice !=
            OnboardingAccessChoice.undecided;
      default:
        return true;
    }
  }

  bool get _isLastStep =>
      _step == _steps.length - 1;

  double get _progress =>
      (_step + 1) / _steps.length;

  Future<void> _moveToStep(
    int nextStep,
  ) async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      await _draftSaveQueue;

      OnboardingDraft savedDraft =
          _draft;

      if (_draft.hasAnyAnswer) {
        savedDraft =
            await OnboardingDraftStore.save(
          _draft,
        );
      }

      await OnboardingStateStore.saveProgress(
        step: nextStep,
      );

      if (!mounted) return;

      setState(() {
        _draft = savedDraft;
        _step = nextStep;
      });

      _resetContentScroll();
    } catch (_) {
      if (!mounted) return;

      _showError(
        'BreakWave could not save your '
        'setup progress. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _continue() async {
    if (_isLastStep) {
      await _finish();
      return;
    }

    await _moveToStep(_step + 1);
  }

  Future<void> _back() async {
    if (_step == 0 || _busy) return;

    await _moveToStep(_step - 1);
  }

  Future<bool> _handleSystemBack() async {
    if (_busy) return false;

    if (_step > 0) {
      await _back();
    }

    return false;
  }

  Future<void> _finish() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      await _draftSaveQueue;

      if (_draft.hasAnyAnswer) {
        await OnboardingDraftStore.save(
          _draft,
        );
      }

      final OnboardingCompletionResult result =
          await _completionService.complete();

      if (!mounted) return;

      if (result.shouldReviewPlus) {
        widget.onReviewPlusRequested?.call();
      }

      widget.onFinished(
        OnboardingStatus.completed,
      );
    } catch (_) {
      if (!mounted) return;

      _showError(
        'BreakWave could not finish setup yet. '
        'Your progress is still saved.',
      );

      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _confirmSkip() async {
    if (_busy) return;

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Skip setup for now?',
          ),
          content: const Text(
            'You can continue into BreakWave '
            'without finishing onboarding. '
            'Previously saved recovery data '
            'will not be erased.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Keep setting up'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('Skip onboarding'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _completionService.skip();

      if (!mounted) return;

      widget.onFinished(
        OnboardingStatus.skipped,
      );
    } catch (_) {
      if (!mounted) return;

      _showError(
        'BreakWave could not skip setup yet. '
        'Please try again.',
      );

      setState(() {
        _busy = false;
      });
    }
  }

  void _showError(
    String message,
  ) {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    final _OnboardingShellStep current =
        _steps[_step];

    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BreakWave setup'),
          actions: <Widget>[
            TextButton(
              onPressed:
                  _busy ? null : _confirmSkip,
              child: const Text('Skip setup'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Step ${_step + 1} '
                            'of ${_steps.length}',
                            style: theme
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                              color:
                                  colorScheme.primary,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${(_progress * 100).round()}%',
                          style:
                              theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 9,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: const Key(
                    'onboarding-content-list',
                  ),
                  controller:
                      _contentScrollController,
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    24,
                  ),
                  children: <Widget>[
                    WaveSurface(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: colorScheme
                                  .primary
                                  .withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              current.icon,
                              size: 31,
                              color:
                                  colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            current.title,
                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            current.body,
                            style: theme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              height: 1.5,
                            ),
                          ),
                          if (_step <= 3) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingIntroStepDetails(
                              step: _step,
                              draft: _draft,
                              loading: _draftLoading,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onModeChanged:
                                  _setRecoveryMode,
                              onSupportNeedChanged:
                                  _setSupportNeed,
                            ),
                          ],
                          if (_step == 4) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingReasonsStepDetails(
                              draft: _draft,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onReasonsChanged:
                                  _setReasons,
                              onWhyChanged:
                                  _setWhyText,
                            ),
                          ],
                          if (_step == 5) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingTriggersStepDetails(
                              draft: _draft,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onChanged: _setTriggers,
                            ),
                          ],
                          if (_step == 6) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingRiskyTimesStepDetails(
                              draft: _draft,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onChanged: _setRiskyTimes,
                            ),
                          ],
                          if (_step == 7) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingActionsStepDetails(
                              draft: _draft,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onChanged:
                                  _setInterruptionActions,
                            ),
                          ],
                          if (_step == 8) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingSummaryStepDetails(
                              draft: _draft,
                            ),
                          ],
                          if (_step == 9) ...<Widget>[
                            const SizedBox(height: 22),
                            OnboardingAccessStepDetails(
                              draft: _draft,
                              enabled:
                                  !_busy &&
                                  !_draftLoading,
                              onChanged: _setAccessChoice,
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            'You can review and change '
                            'your setup later.',
                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: colorScheme
                                  .onSurface
                                  .withOpacity(0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key(
                    'onboarding-open-rescue-button',
                  ),
                  onPressed: _busy
                      ? null
                      : () async {
                          await openOnboardingRescue(
                            context,
                          );
                        },
                  icon: const Icon(
                    Icons.waves_rounded,
                  ),
                  label: const Text(
                    'Need help now? Open Rescue',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  if (_step > 0) ...<Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _busy ? null : _back,
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        label: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: _step > 0 ? 1 : 2,
                    child: FilledButton.icon(
                        onPressed:
                            (_busy ||
                                    !_canContinueCurrentStep)
                                ? null
                                : _continue,
                      icon: Icon(
                        _isLastStep
                            ? Icons.check_rounded
                            : Icons
                                .arrow_forward_rounded,
                      ),
                      label: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 3,
                        ),
                        child: Text(
                          _busy
                              ? 'Saving...'
                              : _isLastStep
                                  ? 'Finish setup'
                                  : 'Continue',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingShellStep {
  const _OnboardingShellStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
