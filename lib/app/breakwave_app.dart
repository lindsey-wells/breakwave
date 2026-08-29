// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app.dart
// Purpose: Root MaterialApp wrapper for BreakWave.
// Notes: WP-03V-T1 owns one shared production billing composition.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../core/billing/breakwave_billing_composition.dart';
import '../core/billing/breakwave_billing_scope.dart';
import '../core/onboarding/onboarding_launch_gate.dart';
import '../core/recovery/recovery_mode_gate.dart';
import '../core/theme/breakwave_theme.dart';
import '../features/shell/presentation/breakwave_shell.dart';

class BreakWaveApp extends StatefulWidget {
  const BreakWaveApp({
    super.key,
    this.billingComposition,
  });

  final BreakWaveBillingComposition? billingComposition;

  @override
  State<BreakWaveApp> createState() => _BreakWaveAppState();
}

class _BreakWaveAppState extends State<BreakWaveApp> {
  late final bool _ownsBillingComposition;
  late final BreakWaveBillingComposition _billingComposition;

  @override
  void initState() {
    super.initState();

    _ownsBillingComposition =
        widget.billingComposition == null;

    _billingComposition =
        widget.billingComposition ??
            BreakWaveBillingComposition.production();
  }

  @override
  void dispose() {
    if (_ownsBillingComposition) {
      _billingComposition.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakWave',
      debugShowCheckedModeBanner: false,
      theme: BreakWaveTheme.dark(),
      darkTheme: BreakWaveTheme.dark(),
      themeMode: ThemeMode.dark,
      home: BreakWaveBillingScope(
        composition: _billingComposition,
        child: const OnboardingLaunchGate(
          child: RecoveryModeGate(
            child: BreakWaveShell(),
          ),
        ),
      ),
    );
  }
}
