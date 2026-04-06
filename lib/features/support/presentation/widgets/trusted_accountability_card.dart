// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: trusted_accountability_card.dart
// Purpose: Accountability card for BreakWave.
// Notes: BW-37 replaces stub CTA with real direct contact actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_actions.dart';
import '../../../../core/support/support_contact_store.dart';

class TrustedAccountabilityCard extends StatefulWidget {
  const TrustedAccountabilityCard({super.key});

  @override
  State<TrustedAccountabilityCard> createState() => _TrustedAccountabilityCardState();
}

class _TrustedAccountabilityCardState extends State<TrustedAccountabilityCard> {
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
    final SupportContact? contact = _contact;

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
            'Trusted Person and Accountability',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (contact == null)
            Text(
              'No trusted contact is saved yet. Add one above to make accountability easier in hard moments.',
              style: theme.textTheme.bodyMedium,
            )
          else ...<Widget>[
            Text(
              'Saved contact: ${contact.name}',
              style: theme.textTheme.bodyMedium,
            ),
            if (contact.hasPhone) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Phone: ${contact.phoneNumber}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (contact.hasEmail) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Email: ${contact.emailAddress}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            if (contact.hasPhone)
              FilledButton.tonal(
                onPressed: () => _run(
                  () => SupportContactActions.sendCheckOnMeText(contact),
                  'Unable to open text message right now.',
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Text trusted contact'),
                ),
              ),
            if (contact.hasPhone && contact.hasEmail) const SizedBox(height: 10),
            if (contact.hasEmail)
              OutlinedButton(
                onPressed: () => _run(
                  () => SupportContactActions.sendSupportEmail(contact),
                  'Unable to open email right now.',
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Email trusted contact'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
