// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_rescue_route.dart
// Purpose: Open real Rescue without abandoning onboarding.
// Notes: Closing Rescue returns to the same onboarding step.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../rescue/presentation/rescue_screen.dart';

Future<void> openOnboardingRescue(
  BuildContext context,
) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (
        BuildContext routeContext,
      ) {
        void showSetupMessage(
          String destination,
        ) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(
            routeContext,
          );

          messenger.hideCurrentSnackBar();

          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '$destination opens after you finish '
                'or skip setup. Rescue remains '
                'available right now.',
              ),
            ),
          );
        }

        return RescueScreen(
          onReturnHome: () {
            Navigator.of(
              routeContext,
            ).maybePop();
          },
          onOpenSupport: () {
            showSetupMessage('Support');
          },
          onOpenLog: () {
            showSetupMessage('Log');
          },
        );
      },
    ),
  );
}
