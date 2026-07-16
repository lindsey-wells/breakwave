// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_launch_gate.dart
// Purpose: Passive onboarding migration hook at app launch.
// Notes: BW-87B6P2 never blocks or changes the visible flow.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    _resolvePassiveMigration();
  }

  Future<void>
      _resolvePassiveMigration() async {
    try {
      await OnboardingStateStore
          .resolveForLaunch();
    } catch (_) {
      // Onboarding bookkeeping must never prevent
      // Rescue, recovery mode, or the app shell
      // from opening.
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
