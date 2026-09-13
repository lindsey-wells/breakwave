// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_locked_screen.dart
// Purpose: IOS-G2F fail-closed locked landing and minimal Rescue-safe holding surface.
// Notes:
// - Never reads recovery data, Personal Why, Log, Support, billing, or account state.
// - Open Rescue enters rescueSafe; it never unlocks the session.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class PrivacyLockedScreen extends StatelessWidget {
  const PrivacyLockedScreen({
    super.key,
    required this.onUnlock,
    required this.onOpenRescue,
    this.rescueSafeActive = false,
    this.onBackToLock,
  });

  final VoidCallback onUnlock;
  final VoidCallback onOpenRescue;
  final bool rescueSafeActive;
  final VoidCallback? onBackToLock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    rescueSafeActive ? 'Rescue-safe access' : 'Privacy lock',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rescueSafeActive
                        ? 'Your private recovery information is still locked. For the next few breaths, inhale gently and make the exhale a little longer. You can unlock BreakWave for your personalized Rescue tools.'
                        : 'Your private recovery information is protected. Unlock BreakWave to continue, or open Rescue without exposing your private recovery data.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: onUnlock,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Unlock BreakWave'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (rescueSafeActive)
                    OutlinedButton(
                      onPressed: onBackToLock,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Back to privacy lock'),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: onOpenRescue,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Open Rescue'),
                      ),
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
