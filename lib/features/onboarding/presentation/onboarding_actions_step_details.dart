// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_actions_step_details.dart
// Purpose: Draft-only interruption-action selection for onboarding.
// Notes: Selections prepare the plan; they do not execute actions here.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';
import '../../../core/recovery/recovery_mode.dart';

class OnboardingActionsStepDetails extends StatefulWidget {
  const OnboardingActionsStepDetails({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onChanged,
  });

  final OnboardingDraft draft;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  @override
  State<OnboardingActionsStepDetails> createState() =>
      _OnboardingActionsStepDetailsState();
}

class _OnboardingActionsStepDetailsState
    extends State<OnboardingActionsStepDetails> {
  static const String _otherLabel = 'Other';
  static const String _otherPrefix = 'Other: ';
  static const String _prayerAction = 'Pray for one minute';

  static const List<String> _baseActions = <String>[
    'Open Rescue',
    'Leave the room',
    'Text someone safe',
    'Take a short walk',
    'Cold water reset',
    'Put the phone down',
    _otherLabel,
  ];

  final TextEditingController _otherController =
      TextEditingController();
  late List<String> _selectedActions;
  bool _editingOther = false;

  @override
  void initState() {
    super.initState();
    _selectedActions =
        List<String>.from(widget.draft.interruptionActions);
    _editingOther =
        _savedOtherAction == _otherLabel;
    _syncOtherController();
  }

  @override
  void didUpdateWidget(
    covariant OnboardingActionsStepDetails oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.draft.interruptionActions !=
        widget.draft.interruptionActions) {
      _selectedActions =
          List<String>.from(widget.draft.interruptionActions);

      if (_savedOtherAction == _otherLabel) {
        _editingOther = true;
      } else if (_savedOtherAction == null) {
        _editingOther = false;
      }

      _syncOtherController();
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  List<String> get _availableActions {
    if (widget.draft.recoveryMode == RecoveryMode.christian) {
      return const <String>[
        ..._baseActions,
        _prayerAction,
      ];
    }

    return _baseActions;
  }

  bool _isOther(String value) {
    return value == _otherLabel || value.startsWith(_otherPrefix);
  }

  String? get _savedOtherAction {
    for (final String action in _selectedActions) {
      if (_isOther(action)) return action;
    }

    return null;
  }

  bool get _isOtherSelected => _savedOtherAction != null;

  String? get _customOtherLabel {
    final String? saved = _savedOtherAction;

    if (saved == null ||
        !saved.startsWith(_otherPrefix)) {
      return null;
    }

    final String custom =
        saved.substring(_otherPrefix.length).trim();

    return custom.isEmpty ? null : custom;
  }

  bool get _hasCustomOther =>
      _customOtherLabel != null;

  void _syncOtherController() {
    final String? saved = _savedOtherAction;
    final String custom = saved != null && saved.startsWith(_otherPrefix)
        ? saved.substring(_otherPrefix.length)
        : '';

    if (_otherController.text != custom) {
      _otherController.value = TextEditingValue(
        text: custom,
        selection: TextSelection.collapsed(
          offset: custom.length,
        ),
      );
    }
  }

  bool _containsIgnoreCase(
    Iterable<String> values,
    String requested,
  ) {
    final String key = requested.trim().toLowerCase();

    return values.any(
      (String value) => value.trim().toLowerCase() == key,
    );
  }

  void _toggle(
    String action,
    bool selected,
  ) {
    final List<String> updated =
        List<String>.from(_selectedActions);

    if (action == _otherLabel) {
      updated.removeWhere(_isOther);

      if (selected) {
        updated.add(_otherLabel);
      }
    } else if (selected) {
      if (!_containsIgnoreCase(updated, action)) {
        updated.add(action);
      }
    } else {
      updated.removeWhere(
        (String item) =>
            item.trim().toLowerCase() ==
            action.trim().toLowerCase(),
      );
    }

    setState(() {
      _selectedActions = updated;

      if (action == _otherLabel) {
        _editingOther = selected;

        if (!selected) {
          _otherController.clear();
        }
      }
    });

    widget.onChanged(updated);
  }

  void _saveOtherAction() {
    if (!widget.enabled) return;

    final String custom =
        _otherController.text.trim();

    if (custom.isEmpty) {
      _showMessage(
        'Enter the interruption action you want to add.',
      );
      return;
    }

    final List<String> updated =
        List<String>.from(_selectedActions)
          ..removeWhere(_isOther)
          ..add('$_otherPrefix$custom');

    FocusScope.of(context).unfocus();

    setState(() {
      _selectedActions = updated;
      _editingOther = false;
    });

    widget.onChanged(updated);
  }

  void _editOtherAction() {
    if (!widget.enabled) return;

    _syncOtherController();

    setState(() {
      _editingOther = true;
    });
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildActionChip(String action) {
    final String? customOther =
        action == _otherLabel
            ? _customOtherLabel
            : null;

    final String displayAction =
        customOther ?? action;

    final String chipKey =
        customOther == null
            ? 'onboarding-action-$action'
            : 'onboarding-custom-action-$customOther';

    return _ActionChip(
      key: ValueKey<String>(chipKey),
      action: displayAction,
      selected: action == _otherLabel
          ? _isOtherSelected
          : _containsIgnoreCase(
              _selectedActions,
              action,
            ),
      enabled: widget.enabled,
      onSelected: (bool selected) {
        _toggle(action, selected);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: const Key('onboarding-actions-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pick practical moves you could take',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose any clean actions that could interrupt momentum. '
          'Nothing is opened, messaged, or contacted from this screen, '
          'and you can continue without choosing one.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '“Text someone safe” stores only the action label here. '
          'No phone number or contact information is requested.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final String action in _availableActions)
              _buildActionChip(action),
          ],
        ),
        if (_isOtherSelected &&
            (_editingOther || !_hasCustomOther))
          ...<Widget>[
          const SizedBox(height: 18),
          TextField(
            key: const Key(
              'onboarding-other-action-field',
            ),
            controller: _otherController,
            enabled: widget.enabled,
            maxLength: 80,
            textCapitalization:
                TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              _saveOtherAction();
            },
            decoration: const InputDecoration(
              labelText:
                  'Name your other interruption action',
              hintText:
                  'Example: Step outside for fresh air',
              helperText:
                  'Tap Add custom action before continuing.',
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key(
                'onboarding-add-custom-action',
              ),
              onPressed: widget.enabled
                  ? _saveOtherAction
                  : null,
              icon: Icon(
                _hasCustomOther
                    ? Icons.save_outlined
                    : Icons.add_rounded,
              ),
              label: Text(
                _hasCustomOther
                    ? 'Update custom action'
                    : 'Add custom action',
              ),
            ),
          ),
        ],
        if (_hasCustomOther &&
            !_editingOther) ...<Widget>[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key(
                'onboarding-edit-custom-action',
              ),
              onPressed: widget.enabled
                  ? _editOtherAction
                  : null,
              icon: const Icon(Icons.edit_outlined),
              label: const Text(
                'Edit custom action',
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Do not replace one harmful habit with another. Choose actions '
          'that create distance, safety, movement, support, or clarity.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    super.key,
    required this.action,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String action;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$action interruption action',
      child: FilterChip(
        label: Text(action),
        selected: selected,
        showCheckmark: true,
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        side: BorderSide(
          color: selected
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
        onSelected: enabled ? onSelected : null,
      ),
    );
  }
}
