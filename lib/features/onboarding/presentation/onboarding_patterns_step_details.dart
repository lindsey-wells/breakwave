// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_patterns_step_details.dart
// Purpose: Draft-only onboarding trigger and risky-time selection.
// Notes: BW-87B6P3B2B keeps all unfinished answers out of live stores.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';
import '../../../core/triggers/trigger_catalog.dart';

class OnboardingTriggersStepDetails extends StatefulWidget {
  const OnboardingTriggersStepDetails({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onChanged,
  });

  final OnboardingDraft draft;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  @override
  State<OnboardingTriggersStepDetails> createState() =>
      _OnboardingTriggersStepDetailsState();
}

class _OnboardingTriggersStepDetailsState
    extends State<OnboardingTriggersStepDetails> {
  final TextEditingController _customController =
      TextEditingController();
  late List<String> _selectedTriggers;

  @override
  void initState() {
    super.initState();
    _selectedTriggers =
        List<String>.from(widget.draft.triggers);
  }

  @override
  void didUpdateWidget(
    covariant OnboardingTriggersStepDetails oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.draft.triggers !=
        widget.draft.triggers) {
      _selectedTriggers =
          List<String>.from(widget.draft.triggers);
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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
    String value,
    bool selected,
  ) {
    final List<String> updated =
        List<String>.from(_selectedTriggers);

    if (selected) {
      if (!_containsIgnoreCase(updated, value)) {
        updated.add(value);
      }
    } else {
      updated.removeWhere(
        (String item) =>
            item.trim().toLowerCase() ==
            value.trim().toLowerCase(),
      );
    }

    setState(() {
      _selectedTriggers = updated;
    });

    widget.onChanged(updated);
  }

  void _addCustomTrigger() {
    if (!widget.enabled) return;

    final String value = _customController.text.trim();

    if (value.isEmpty) return;

    if (_containsIgnoreCase(_selectedTriggers, value)) {
      _customController.clear();
      _showMessage('That trigger is already selected.');
      return;
    }

    final List<String> updated = <String>[
      ..._selectedTriggers,
      value,
    ];

    setState(() {
      _selectedTriggers = updated;
    });

    widget.onChanged(updated);
    _customController.clear();
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> customTriggers =
        _selectedTriggers.where(
      (String trigger) => !_containsIgnoreCase(
        BreakWaveTriggerCatalog.triggers,
        trigger,
      ),
    ).toList();

    return Column(
      key: const Key('onboarding-triggers-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose the signals that fit',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These are clues, not diagnoses. Select any that help you '
          'notice the wave earlier. You can continue without choosing one.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (
              final String trigger
              in BreakWaveTriggerCatalog.triggers
            )
              _SelectableChip(
                key: ValueKey<String>(
                  'onboarding-trigger-$trigger',
                ),
                label: trigger,
                semanticLabel: '$trigger trigger',
                selected: _containsIgnoreCase(
                  _selectedTriggers,
                  trigger,
                ),
                enabled: widget.enabled,
                onSelected: (bool selected) {
                  _toggle(trigger, selected);
                },
              ),
            for (final String trigger in customTriggers)
              _SelectableChip(
                key: ValueKey<String>(
                  'onboarding-custom-trigger-$trigger',
                ),
                label: trigger,
                semanticLabel: '$trigger custom trigger',
                selected: true,
                enabled: widget.enabled,
                onSelected: (bool selected) {
                  _toggle(trigger, selected);
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          key: const Key('onboarding-custom-trigger-field'),
          controller: _customController,
          enabled: widget.enabled,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addCustomTrigger(),
          decoration: const InputDecoration(
            labelText: 'Add your own trigger',
            hintText: 'Example: Unstructured evenings',
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('onboarding-add-custom-trigger'),
            onPressed:
                widget.enabled ? _addCustomTrigger : null,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add custom trigger'),
          ),
        ),
      ],
    );
  }
}

class OnboardingRiskyTimesStepDetails extends StatefulWidget {
  const OnboardingRiskyTimesStepDetails({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onChanged,
  });

  final OnboardingDraft draft;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  @override
  State<OnboardingRiskyTimesStepDetails> createState() =>
      _OnboardingRiskyTimesStepDetailsState();
}

class _OnboardingRiskyTimesStepDetailsState
    extends State<OnboardingRiskyTimesStepDetails> {
  late List<String> _selectedRiskyTimes;

  @override
  void initState() {
    super.initState();
    _selectedRiskyTimes =
        List<String>.from(widget.draft.riskyTimes);
  }

  @override
  void didUpdateWidget(
    covariant OnboardingRiskyTimesStepDetails oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.draft.riskyTimes !=
        widget.draft.riskyTimes) {
      _selectedRiskyTimes =
          List<String>.from(widget.draft.riskyTimes);
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
    String value,
    bool selected,
  ) {
    final List<String> updated =
        List<String>.from(_selectedRiskyTimes);

    if (selected) {
      if (!_containsIgnoreCase(updated, value)) {
        updated.add(value);
      }
    } else {
      updated.removeWhere(
        (String item) =>
            item.trim().toLowerCase() ==
            value.trim().toLowerCase(),
      );
    }

    setState(() {
      _selectedRiskyTimes = updated;
    });

    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: const Key('onboarding-risky-times-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Prepare for the windows you recognize',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These choices do not predict a relapse. They simply help you '
          'prepare for situations where extra support may be useful. '
          'You can continue without choosing one.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (
              final String riskyTime
              in BreakWaveTriggerCatalog.riskyTimes
            )
              _SelectableChip(
                key: ValueKey<String>(
                  'onboarding-risky-time-$riskyTime',
                ),
                label: riskyTime,
                semanticLabel: '$riskyTime risky time',
                selected: _containsIgnoreCase(
                  _selectedRiskyTimes,
                  riskyTime,
                ),
                enabled: widget.enabled,
                onSelected: (bool selected) {
                  _toggle(riskyTime, selected);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: FilterChip(
        label: Text(label),
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
