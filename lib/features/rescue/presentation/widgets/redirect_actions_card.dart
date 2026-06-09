// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: redirect_actions_card.dart
// Purpose: BW-65 Rescue next right action selector.
// Notes: Keeps one clear replacement action active during Rescue.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/recovery/recovery_mode.dart';
import '../../../../core/recovery/recovery_mode_store.dart';
import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_actions.dart';
import '../../../../core/support/support_contact_store.dart';

class RedirectActionsCard extends StatefulWidget {
  const RedirectActionsCard({
    super.key,
    required this.selectedAction,
    required this.onActionSelected,
  });

  final String? selectedAction;
  final ValueChanged<String?> onActionSelected;

  @override
  State<RedirectActionsCard> createState() => _RedirectActionsCardState();
}

class _RedirectActionsCardState extends State<RedirectActionsCard> {
  SupportContact? _contact;
  RecoveryMode _mode = RecoveryMode.secular;

  static const List<String> _baseActions = <String>[
    'Put the phone down',
    'Leave the room',
    'Open your why',
    'Text someone safe',
    'Cold water reset',
    'Take a short walk',
  ];

  @override
  void initState() {
    super.initState();
    SupportContactStore.changes.addListener(_loadContact);
    RecoveryModeStore.changes.addListener(_loadMode);
    _loadContact();
    _loadMode();
  }

  @override
  void dispose() {
    SupportContactStore.changes.removeListener(_loadContact);
    RecoveryModeStore.changes.removeListener(_loadMode);
    super.dispose();
  }

  Future<void> _loadContact() async {
    final SupportContact? contact = await SupportContactStore.loadContact();
    if (!mounted) return;
    setState(() {
      _contact = contact;
    });
  }

  Future<void> _loadMode() async {
    final RecoveryMode mode =
        await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;
    if (!mounted) return;
    setState(() {
      _mode = mode;
    });
  }

  List<String> get _actions {
    if (_mode == RecoveryMode.christian) {
      return const <String>[
        ..._baseActions,
        'Pray for one minute',
      ];
    }

    return _baseActions;
  }

  void _showActionNudge(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<bool> _textSomeoneSafe() async {
    final SupportContact? contact = _contact;
    if (contact == null || !contact.hasPhone) {
      _showActionNudge('Save a trusted contact with a phone number in Support first.');
      return false;
    }

    final bool ok = await SupportContactActions.sendStrugglingText(contact);
    if (!mounted) return ok;

    _showActionNudge(
      ok ? 'Opening your messaging app.' : 'Unable to open text message right now.',
    );

    return ok;
  }

  Future<void> _selectAction(String action) async {
    if (action == 'Text someone safe') {
      final bool ok = await _textSomeoneSafe();
      if (!ok) return;
    } else {
      _showActionNudge(_nudgeForAction(action));
    }

    widget.onActionSelected(
      widget.selectedAction == action ? null : action,
    );
  }

  String _nudgeForAction(String action) {
    switch (action) {
      case 'Put the phone down':
        return 'Good move. Put the phone down now and create distance.';
      case 'Leave the room':
        return 'Good move. Change rooms now and reduce privacy.';
      case 'Open your why':
        return 'Good move. Look at your reason and let it interrupt the urge.';
      case 'Cold water reset':
        return 'Good move. Use cold water to break momentum and reset your body.';
      case 'Take a short walk':
        return 'Good move. Walk for a minute and interrupt the pattern physically.';
      case 'Pray for one minute':
        return 'Good move. Pray slowly and choose the next faithful step.';
      default:
        return 'Good move. Take the next right action now.';
    }
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
            'Next Right Action',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose one immediate action that changes your body, your device access, your location, or your support level.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Do not replace the urge with another harmful habit. Choose a clean next move that protects your future self.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _actions.map((String action) {
              final bool isSelected = widget.selectedAction == action;

              return ChoiceChip(
                label: Text(action),
                selected: isSelected,
                showCheckmark: true,
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
                onSelected: (_) => _selectAction(action),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
