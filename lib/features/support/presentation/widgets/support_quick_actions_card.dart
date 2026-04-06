// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_quick_actions_card.dart
// Purpose: BW-21/BW-37 support quick actions card.
// Notes: Supports direct text/email actions and keeps copy actions as fallback.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_actions.dart';
import '../../../../core/support/support_contact_store.dart';

class SupportQuickActionsCard extends StatefulWidget {
  const SupportQuickActionsCard({super.key});

  @override
  State<SupportQuickActionsCard> createState() => _SupportQuickActionsCardState();
}

class _SupportQuickActionsCardState extends State<SupportQuickActionsCard> {
  bool _loading = true;
  SupportContact? _contact;

  @override
  void initState() {
    super.initState();
    SupportContactStore.changes.addListener(_handleStoreChange);
    _load();
  }

  @override
  void dispose() {
    SupportContactStore.changes.removeListener(_handleStoreChange);
    super.dispose();
  }

  void _handleStoreChange() {
    _load();
  }

  Future<void> _load() async {
    final SupportContact? contact = await SupportContactStore.loadContact();
    if (!mounted) return;

    setState(() {
      _contact = contact;
      _loading = false;
    });
  }

  Future<void> _copyMessage(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _contact == null
              ? 'Copied message.'
              : 'Copied message for ${_contact!.name}.',
        ),
      ),
    );
  }

  Future<void> _runAction(Future<bool> Function() action, String failureText) async {
    final bool ok = await action();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Opening your messaging app.' : failureText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasContact = _contact != null;
    final bool hasPhone = _contact?.hasPhone ?? false;
    final bool hasEmail = _contact?.hasEmail ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Quick actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasContact
                      ? 'Ready for ${_contact!.name}${hasPhone ? ' • ${_contact!.phoneNumber}' : ''}${hasEmail ? '${hasPhone ? ' • ' : ' • '}${_contact!.emailAddress}' : ''}'
                      : 'Save a trusted contact first, then send a direct text or email.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                if (hasPhone) ...<Widget>[
                  FilledButton(
                    onPressed: () => _runAction(
                      () => SupportContactActions.sendStrugglingText(_contact!),
                      'Unable to open text message right now.',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('Text ${_contact!.name}: I’m struggling'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () => _runAction(
                      () => SupportContactActions.sendCheckOnMeText(_contact!),
                      'Unable to open text message right now.',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('Text ${_contact!.name}: Please check on me'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () => _runAction(
                      () => SupportContactActions.sendCallMeText(_contact!),
                      'Unable to open text message right now.',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('Text ${_contact!.name}: Can you call me?'),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                if (hasEmail) ...<Widget>[
                  OutlinedButton(
                    onPressed: () => _runAction(
                      () => SupportContactActions.sendSupportEmail(_contact!),
                      'Unable to open email right now.',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('Email ${_contact!.name} now'),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                Text(
                  'Copy fallback',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => _copyMessage(
                        'I’m struggling right now. Please check on me when you can.',
                      ),
                      child: const Text('Copy "I’m struggling"'),
                    ),
                    OutlinedButton(
                      onPressed: () => _copyMessage(
                        'Please check on me soon. I could use support right now.',
                      ),
                      child: const Text('Copy "Please check on me"'),
                    ),
                    OutlinedButton(
                      onPressed: () => _copyMessage(
                        'Can you call me when you can? I need some support right now.',
                      ),
                      child: const Text('Copy "Can you call me?"'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
