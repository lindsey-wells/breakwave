// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: redirect_actions_card.dart
// Purpose: Rescue redirect actions for BreakWave.
// Notes: BW-37 makes "Text someone safe" a real action.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_actions.dart';
import '../../../../core/support/support_contact_store.dart';

class RedirectActionsCard extends StatefulWidget {
  const RedirectActionsCard({super.key});

  @override
  State<RedirectActionsCard> createState() => _RedirectActionsCardState();
}

class _RedirectActionsCardState extends State<RedirectActionsCard> {
  SupportContact? _contact;

  @override
  void initState() {
    super.initState();
    SupportContactStore.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    SupportContactStore.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final SupportContact? contact = await SupportContactStore.loadContact();
    if (!mounted) return;
    setState(() {
      _contact = contact;
    });
  }

  void _showActionNudge(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _textSomeoneSafe() async {
    final SupportContact? contact = _contact;
    if (contact == null || !contact.hasPhone) {
      _showActionNudge('Save a trusted contact with a phone number in Support first.');
      return;
    }

    final bool ok = await SupportContactActions.sendStrugglingText(contact);
    if (!mounted) return;

    _showActionNudge(
      ok ? 'Opening your messaging app.' : 'Unable to open text message right now.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Fast Redirect Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pick one immediate action that changes your body, your device access, or your location.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              ActionChip(
                label: const Text('Put the phone down'),
                onPressed: () => _showActionNudge('Good move. Put the phone down now and create distance.'),
              ),
              ActionChip(
                label: const Text('Leave the room'),
                onPressed: () => _showActionNudge('Good move. Change rooms now and reduce privacy.'),
              ),
              ActionChip(
                label: const Text('Take a short walk'),
                onPressed: () => _showActionNudge('Good move. Walk for a minute and interrupt the pattern physically.'),
              ),
              ActionChip(
                label: const Text('Cold water reset'),
                onPressed: () => _showActionNudge('Good move. Use cold water to break momentum and reset your body.'),
              ),
              ActionChip(
                label: const Text('Text someone safe'),
                onPressed: _textSomeoneSafe,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
