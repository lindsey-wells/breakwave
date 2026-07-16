// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_launch_loading.dart
// Purpose: Safe startup while onboarding state resolves.
// Notes: Rescue remains reachable during launch loading.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class OnboardingLaunchLoading
    extends StatelessWidget {
  const OnboardingLaunchLoading({
    super.key,
    required this.onOpenRescue,
  });

  final VoidCallback onOpenRescue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Preparing BreakWave',
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your setup and recovery data '
                'stay on this device.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenRescue,
                  icon: const Icon(
                    Icons.waves_rounded,
                  ),
                  label: const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text(
                      'Need help now? Open Rescue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
