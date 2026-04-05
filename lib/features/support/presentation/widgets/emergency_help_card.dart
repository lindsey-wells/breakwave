// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: emergency_help_card.dart
// Purpose: Immediate support card for BreakWave.
// Notes: BW-37 replaces stub CTA with real trusted-contact actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_actions.dart';
import '../../../../core/support/support_contact_store.dart';

class EmergencyHelpCard extends StatefulWidget {
  const EmergencyHelpCard({super.key});

  @override
  State<EmergencyHelpCard> createState() => _EmergencyHelpCardState();
}

class _EmergencyHelpCardState extends State<EmergencyHelpCard> {
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

  Future<void> _run(Future<bool> Function() action, String failureText) async {
    final bool ok = await action();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Opening your contact app.' : failureText)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasPhone = _contact?.hasPhone ?? false;
    final bool hasEmail = _contact?.hasEmail ?? false;

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
            'Immediate support',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'When the pressure spikes, reduce isolation fast. Use your trusted contact tools right away instead of waiting for the wave to negotiate with you.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (hasPhone)
            FilledButton(
              onPressed: () => _run(
                () => SupportContactActions.sendStrugglingText(_contact!),
                'Unable to open text message right now.',
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Text trusted contact now'),
              ),
            ),
          if (hasPhone) const SizedBox(height: 10),
          if (hasEmail)
            OutlinedButton(
              onPressed: () => _run(
                () => SupportContactActions.sendSupportEmail(_contact!),
                'Unable to open email right now.',
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Email trusted contact now'),
              ),
            ),
          if (!hasPhone && !hasEmail)
            Text(
              'Save a trusted contact below to unlock direct emergency contact actions.',
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}
