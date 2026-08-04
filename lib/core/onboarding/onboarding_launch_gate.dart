// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_launch_gate.dart
// Purpose: Migration-safe onboarding decision at app launch.
// Notes: Existing users bypass onboarding; fresh users can resume it.
// Notes: BW-ONBOARD-01B2 offers the tutorial after explicit onboarding completion.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../../features/onboarding/presentation/onboarding_launch_loading.dart';
import '../../features/onboarding/presentation/onboarding_rescue_route.dart';
import '../../features/premium/presentation/breakwave_plus_screen.dart';
import '../../features/tutorial/presentation/teach_me_breakwave_invitation_dialog.dart';
import '../../features/tutorial/presentation/teach_me_breakwave_screen.dart';
import '../tutorial/breakwave_tutorial_invitation_store.dart';
import 'onboarding_state.dart';
import 'onboarding_state_store.dart';

class OnboardingLaunchGate extends StatefulWidget {
  const OnboardingLaunchGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<OnboardingLaunchGate> createState() =>
      _OnboardingLaunchGateState();
}

class _OnboardingLaunchGateState extends State<OnboardingLaunchGate> {
  bool _loading = true;
  bool _showOnboarding = false;
  bool _reviewPlusPending = false;
  bool _postOnboardingFlowActive = false;
  int _initialStep = 0;

  @override
  void initState() {
    super.initState();
    _resolvePassiveMigration();
  }

  Future<void> _resolvePassiveMigration() async {
    try {
      OnboardingState state =
          await OnboardingStateStore.resolveForLaunch();

      if (state.status == OnboardingStatus.notStarted) {
        state = await OnboardingStateStore.begin(step: 0);
      }

      if (!mounted) return;

      setState(() {
        _initialStep = state.currentStep;
        _showOnboarding = state.shouldShowOnboarding;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      // Onboarding bookkeeping must never prevent Rescue,
      // recovery mode, or the app shell from opening.
      setState(() {
        _showOnboarding = false;
        _loading = false;
      });
    }
  }

  void _handleFinished(OnboardingStatus status) {
    if (!mounted) return;

    final bool completed = status == OnboardingStatus.completed;
    final bool openPlus = completed && _reviewPlusPending;

    setState(() {
      _showOnboarding = false;
      _reviewPlusPending = false;
    });

    if (!completed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runPostOnboardingFlow(openPlus: openPlus);
    });
  }

  Future<void> _runPostOnboardingFlow({
    required bool openPlus,
  }) async {
    if (!mounted || _postOnboardingFlowActive) return;
    _postOnboardingFlowActive = true;

    try {
      // Preserve the user's explicit onboarding choice: Plus information
      // opens first, and the optional tour invitation waits until it closes.
      if (openPlus) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const BreakWavePlusScreen(),
          ),
        );
      }

      if (!mounted) return;

      final bool shouldOffer =
          await BreakWaveTutorialInvitationStore.shouldOffer();
      if (!shouldOffer || !mounted) return;

      final BreakWaveTutorialInvitationChoice? choice =
          await showTeachMeBreakWaveInvitation(context);
      if (choice == null || !mounted) return;

      try {
        await BreakWaveTutorialInvitationStore.save(choice);
      } catch (_) {
        // A local preference failure must not trap the user or block the tour.
      }

      if (choice == BreakWaveTutorialInvitationChoice.accepted && mounted) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const TeachMeBreakWaveScreen(),
          ),
        );
      }
    } catch (_) {
      // Post-onboarding education must never block the app shell or Rescue.
    } finally {
      _postOnboardingFlowActive = false;
    }
  }

  void _handleReviewPlusRequested() {
    _reviewPlusPending = true;
  }

  Widget _buildChild() {
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return OnboardingLaunchLoading(
        onOpenRescue: () {
          openOnboardingRescue(context);
        },
      );
    }

    if (_showOnboarding) {
      return OnboardingFlowScreen(
        initialStep: _initialStep,
        onFinished: _handleFinished,
        onReviewPlusRequested: _handleReviewPlusRequested,
      );
    }

    return _buildChild();
  }
}
