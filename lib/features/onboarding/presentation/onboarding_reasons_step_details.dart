// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_reasons_step_details.dart
// Purpose: Real reasons, current-focus, and Why onboarding.
// Notes: BW-87B6P3B2A2 writes only to the onboarding draft.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';

typedef OnboardingReasonsChanged =
    Future<void> Function(
  List<String> reasons,
  String currentFocus,
);

class OnboardingReasonsStepDetails
    extends StatefulWidget {
  const OnboardingReasonsStepDetails({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onReasonsChanged,
    required this.onWhyChanged,
  });

  final OnboardingDraft draft;
  final bool enabled;
  final OnboardingReasonsChanged
      onReasonsChanged;
  final ValueChanged<String> onWhyChanged;

  static const List<String> presetReasons =
      <String>[
    'I want mental clarity.',
    'I want to stop feeding shame and secrecy.',
    'I want to protect my relationships.',
    'I want to break the habit loop.',
    'I want to use my time better.',
    'I want to live with integrity.',
  ];

  @override
  State<OnboardingReasonsStepDetails>
      createState() =>
          _OnboardingReasonsStepDetailsState();
}

class _OnboardingReasonsStepDetailsState
    extends State<OnboardingReasonsStepDetails> {
  late final TextEditingController
      _customReasonController;

  late final TextEditingController
      _whyController;

  @override
  void initState() {
    super.initState();

    _customReasonController =
        TextEditingController();

    _whyController = TextEditingController(
      text: widget.draft.whyText,
    );
  }

  @override
  void didUpdateWidget(
    OnboardingReasonsStepDetails oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final String incoming =
        widget.draft.whyText;

    if (incoming !=
            oldWidget.draft.whyText &&
        incoming != _whyController.text) {
      _whyController.value =
          TextEditingValue(
        text: incoming,
        selection:
            TextSelection.collapsed(
          offset: incoming.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    _whyController.dispose();

    super.dispose();
  }

  bool _containsReason(
    Iterable<String> values,
    String requested,
  ) {
    final String key =
        requested.trim().toLowerCase();

    return values.any(
      (String value) =>
          value.trim().toLowerCase() ==
          key,
    );
  }

  String? _canonicalReason(
    Iterable<String> values,
    String requested,
  ) {
    final String key =
        requested.trim().toLowerCase();

    for (final String value in values) {
      if (value.trim().toLowerCase() ==
          key) {
        return value;
      }
    }

    return null;
  }

  Future<void> _toggleReason(
    String reason,
    bool selected,
  ) async {
    final List<String> updated =
        List<String>.from(
      widget.draft.reasons,
    );

    if (selected) {
      if (!_containsReason(
        updated,
        reason,
      )) {
        updated.add(reason);
      }
    } else {
      updated.removeWhere(
        (String value) =>
            value.trim().toLowerCase() ==
            reason.trim().toLowerCase(),
      );
    }

    String focus =
        widget.draft.currentFocus;

    final String? canonicalFocus =
        _canonicalReason(
      updated,
      focus,
    );

    if (updated.isEmpty) {
      focus = '';
    } else if (canonicalFocus == null) {
      focus = updated.first;
    } else {
      focus = canonicalFocus;
    }

    await widget.onReasonsChanged(
      updated,
      focus,
    );
  }

  Future<void> _addCustomReason() async {
    final String reason =
        _customReasonController.text
            .trim();

    if (reason.isEmpty) return;

    final List<String> updated =
        List<String>.from(
      widget.draft.reasons,
    );

    final String? existing =
        _canonicalReason(
      updated,
      reason,
    );

    String focus =
        widget.draft.currentFocus;

    if (existing == null) {
      updated.add(reason);

      if (focus.trim().isEmpty) {
        focus = reason;
      }
    }

    _customReasonController.clear();

    await widget.onReasonsChanged(
      updated,
      focus,
    );
  }

  Future<void> _setCurrentFocus(
    String reason,
  ) async {
    await widget.onReasonsChanged(
      List<String>.from(
        widget.draft.reasons,
      ),
      reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final List<String> customReasons =
        widget.draft.reasons
            .where(
              (String reason) =>
                  !_containsReason(
                OnboardingReasonsStepDetails
                    .presetReasons,
                reason,
              ),
            )
            .toList();

    final int selectedCount =
        widget.draft.reasons.length;

    return Column(
      key: const Key(
        'onboarding-reasons-details',
      ),
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose what you are protecting',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose one or more. Your current focus '
          'will be the reason BreakWave keeps '
          'closest on Home.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (
              final String reason
              in OnboardingReasonsStepDetails
                  .presetReasons
            )
              FilterChip(
                key: ValueKey<String>(
                  'onboarding-reason-$reason',
                ),
                label: Text(reason),
                selected: _containsReason(
                  widget.draft.reasons,
                  reason,
                ),
                onSelected: widget.enabled
                    ? (bool selected) async {
                        await _toggleReason(
                          reason,
                          selected,
                        );
                      }
                    : null,
              ),
            for (
              final String reason
              in customReasons
            )
              FilterChip(
                key: ValueKey<String>(
                  'onboarding-custom-reason-$reason',
                ),
                label: Text(reason),
                selected: true,
                onSelected: widget.enabled
                    ? (bool selected) async {
                        await _toggleReason(
                          reason,
                          selected,
                        );
                      }
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          selectedCount == 0
              ? 'Choose at least one reason to continue.'
              : '$selectedCount '
                  '${selectedCount == 1 ? 'reason' : 'reasons'} '
                  'selected.',
          style: theme.textTheme.bodySmall
              ?.copyWith(
            fontWeight: selectedCount == 0
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Add your own reason',
          style: theme.textTheme.titleSmall
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key(
            'onboarding-custom-reason-field',
          ),
          controller:
              _customReasonController,
          enabled: widget.enabled,
          textCapitalization:
              TextCapitalization.sentences,
          textInputAction:
              TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Custom reason',
            hintText:
                'Example: I want my evenings back.',
          ),
          onSubmitted: (_) async {
            await _addCustomReason();
          },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key(
            'onboarding-add-custom-reason',
          ),
          onPressed: widget.enabled
              ? () async {
                  await _addCustomReason();
                }
              : null,
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'Add custom reason',
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Current focus',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.draft.reasons.isEmpty)
          Text(
            'Select at least one reason before '
            'choosing your current focus.',
            style: theme.textTheme.bodyMedium,
          )
        else
          ...widget.draft.reasons.map(
            (String reason) =>
                RadioListTile<String>(
              key: ValueKey<String>(
                'onboarding-focus-$reason',
              ),
              contentPadding:
                  EdgeInsets.zero,
              value: reason,
              groupValue:
                  widget.draft.currentFocus,
              title: Text(reason),
              onChanged: widget.enabled
                  ? (String? value) async {
                      if (value == null) return;

                      await _setCurrentFocus(
                        value,
                      );
                    }
                  : null,
            ),
          ),
        const SizedBox(height: 26),
        Text(
          'Write your own Why',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A short sentence can help when an urge '
          'starts bargaining. This is optional and '
          'stays private on your device.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key(
            'onboarding-why-field',
          ),
          controller: _whyController,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 5,
          maxLength: 280,
          textCapitalization:
              TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'My Why',
            hintText:
                'Example: I want to be present, honest, and free.',
            alignLabelWithHint: true,
          ),
          onChanged: widget.onWhyChanged,
        ),
      ],
    );
  }
}
