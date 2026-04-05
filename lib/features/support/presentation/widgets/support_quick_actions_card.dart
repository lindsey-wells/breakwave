// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_quick_actions_card.dart
// Purpose: BW-21 support quick actions card.
// Notes: Copies discreet support messages for the saved trusted contact.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/support/support_contact.dart';
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool hasContact = _contact != null;

    final List<_QuickAction> actions = <_QuickAction>[
      const _QuickAction(
        label: 'Copy "I’m struggling"',
        message: 'I’m struggling right now. Please check on me when you can.',
      ),
      const _QuickAction(
        label: 'Copy "Please check on me"',
        message: 'Please check on me soon. I could use support right now.',
      ),
      const _QuickAction(
        label: 'Copy "Can you call me?"',
        message: 'Can you call me when you can? I need some support right now.',
      ),
    ];

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
                      ? 'Ready for ${_contact!.name} • ${_contact!.contactLine}'
                      : 'Save a trusted contact first, then copy a ready-to-send support message.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final _QuickAction action in actions) ...<Widget>[
                  FilledButton.tonal(
                    onPressed: hasContact ? () => _copyMessage(action.message) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(action.label),
                    ),
                  ),
                  if (action != actions.last) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;
}
