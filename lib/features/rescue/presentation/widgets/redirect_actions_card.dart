// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: redirect_actions_card.dart
// Purpose: BW-65 Rescue next right action selector.
// Notes: Keeps one clear replacement action active during Rescue.
// Notes: BW-82C makes Open your why actionable and adds Other capture.
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
    required this.onOpenWhy,
  });

  final String? selectedAction;
  final ValueChanged<String?> onActionSelected;
  final VoidCallback onOpenWhy;

  @override
  State<RedirectActionsCard> createState() => _RedirectActionsCardState();
}

class _RedirectActionsCardState extends State<RedirectActionsCard> {
  final TextEditingController _otherActionController = TextEditingController();

  SupportContact? _contact;
  RecoveryMode _mode = RecoveryMode.secular;

  static const String _otherLabel = 'Other';

  static const List<String> _baseActions = <String>[
    'Put the phone down',
    'Leave the room',
    'Open your why',
    'Text someone safe',
    'Cold water reset',
    'Take a short walk',
    _otherLabel,
  ];

  @override
  void initState() {
    super.initState();
    SupportContactStore.changes.addListener(_loadContact);
    RecoveryModeStore.changes.addListener(_loadMode);
    _syncOtherActionController();
    _loadContact();
    _loadMode();
  }

  @override
  void didUpdateWidget(covariant RedirectActionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedAction != widget.selectedAction) {
      _syncOtherActionController();
    }
  }

  @override
  void dispose() {
    SupportContactStore.changes.removeListener(_loadContact);
    RecoveryModeStore.changes.removeListener(_loadMode);
    _otherActionController.dispose();
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

  bool _isOtherAction(String? action) {
    return action == _otherLabel || (action?.startsWith('Other: ') ?? false);
  }

  bool get _isOtherSelected => _isOtherAction(widget.selectedAction);

  String get _customOtherAction {
    final String? action = widget.selectedAction;

    if (action != null && action.startsWith('Other: ')) {
      return action.substring('Other: '.length);
    }

    return '';
  }

  void _syncOtherActionController() {
    if (_isOtherSelected) {
      final String customAction = _customOtherAction;
      if (_otherActionController.text != customAction) {
        _otherActionController.text = customAction;
      }
    } else if (_otherActionController.text.isNotEmpty) {
      _otherActionController.clear();
    }
  }

  void _setOtherActionText(String value) {
    final String customAction = value.trim();

    widget.onActionSelected(
      customAction.isEmpty ? _otherLabel : 'Other: $customAction',
    );
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
    final bool isSelected =
        action == _otherLabel ? _isOtherSelected : widget.selectedAction == action;

    if (action == _otherLabel) {
      _showActionNudge(_nudgeForAction(action));

      if (isSelected) {
        _otherActionController.clear();
        widget.onActionSelected(null);
      } else {
        widget.onActionSelected(_otherLabel);
      }

      return;
    }

    if (action == 'Text someone safe') {
      final bool ok = await _textSomeoneSafe();
      if (!ok) return;
    } else if (action == 'Open your why') {
      widget.onOpenWhy();
      _showActionNudge(_nudgeForAction(action));
    } else {
      _showActionNudge(_nudgeForAction(action));
    }

    if (_otherActionController.text.isNotEmpty) {
      _otherActionController.clear();
    }

    widget.onActionSelected(isSelected ? null : action);
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
      case _otherLabel:
        return 'Good move. Name the clean next action that protects your future self.';
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
              final bool isSelected =
                  action == _otherLabel ? _isOtherSelected : widget.selectedAction == action;

              return ChoiceChip(
                label: Text(action),
                selected: isSelected,
                showCheckmark: true,
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                ),
                onSelected: (_) => _selectAction(action),
              );
            }).toList(),
          ),
          if (_isOtherSelected) ...<Widget>[
            const SizedBox(height: 14),
            TextField(
              controller: _otherActionController,
              textInputAction: TextInputAction.done,
              onChanged: _setOtherActionText,
              decoration: const InputDecoration(
                labelText: 'Name the next right action',
                hintText: 'Example: call sponsor, go outside, put phone in kitchen',
                helperText: 'Optional. Blank saves as Other.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
