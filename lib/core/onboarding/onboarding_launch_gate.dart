// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_launch_gate.dart
// Purpose: Migration-safe onboarding decision at app launch.
// Notes: Existing users bypass onboarding; fresh users can resume it.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../../features/onboarding/presentation/onboarding_launch_loading.dart';
import '../../features/onboarding/presentation/onboarding_rescue_route.dart';
import 'onboarding_state.dart';
import 'onboarding_state_store.dart';

class OnboardingLaunchGate
    extends StatefulWidget {
  const OnboardingLaunchGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<OnboardingLaunchGate> createState() =>
      _OnboardingLaunchGateState();
}

class _OnboardingLaunchGateState
    extends State<OnboardingLaunchGate> {
  bool _loading = true;
  bool _showOnboarding = false;
  int _initialStep = 0;

  @override
  void initState() {
    super.initState();
    _resolvePassiveMigration();
  }

  Future<void>
      _resolvePassiveMigration() async {
    try {
      OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch();

      if (state.status ==
          OnboardingStatus.notStarted) {
        state =
            await OnboardingStateStore.begin(
          step: 0,
        );
      }

      if (!mounted) return;

      setState(() {
        _initialStep = state.currentStep;
        _showOnboarding =
            state.shouldShowOnboarding;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      // Onboarding bookkeeping must never prevent
      // Rescue, recovery mode, or the app shell
      // from opening.
      setState(() {
        _showOnboarding = false;
        _loading = false;
      });
    }
  }

  void _handleFinished(
    OnboardingStatus status,
  ) {
    if (!mounted) return;

    setState(() {
      _showOnboarding = false;
    });
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
      );
    }

    return _buildChild();
  }
}
