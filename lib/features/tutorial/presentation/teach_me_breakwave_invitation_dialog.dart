// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: teach_me_breakwave_invitation_dialog.dart
// Purpose: Optional one-time tutorial invitation after onboarding.
// Notes: Declining never removes the replayable Support entry.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/tutorial/breakwave_tutorial_invitation_store.dart';

Future<BreakWaveTutorialInvitationChoice?>
    showTeachMeBreakWaveInvitation(BuildContext context) {
  return showDialog<BreakWaveTutorialInvitationChoice>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        icon: const Icon(Icons.school_outlined),
        title: const Text('Would you like a quick tour?'),
        content: const Text(
          'See how Rescue, Log, your recovery plan, and other tools work. '
          'You can skip this now and replay the tour later from Support.',
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('tutorial-invitation-decline'),
            onPressed: () {
              Navigator.of(dialogContext).pop(
                BreakWaveTutorialInvitationChoice.declined,
              );
            },
            child: const Text("I'll explore myself"),
          ),
          FilledButton(
            key: const Key('tutorial-invitation-accept'),
            onPressed: () {
              Navigator.of(dialogContext).pop(
                BreakWaveTutorialInvitationChoice.accepted,
              );
            },
            child: const Text('Show me'),
          ),
        ],
      );
    },
  );
}
