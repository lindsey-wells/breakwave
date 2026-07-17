// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_summary_step_details.dart
// Purpose: Read-only starter recovery setup summary.
// Notes: Reads only the temporary onboarding draft.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';
import '../../../core/recovery/recovery_mode.dart';

class OnboardingSummaryStepDetails extends StatelessWidget {
  const OnboardingSummaryStepDetails({
    super.key,
    required this.draft,
  });

  final OnboardingDraft draft;

  String get _modeLabel {
    if (draft.recoveryMode == RecoveryMode.secular) {
      return 'Secular recovery path';
    }

    if (draft.recoveryMode == RecoveryMode.christian) {
      return 'Christian recovery path';
    }

    return 'Not selected';
  }

  String _displayInterruptionAction(
    String value,
  ) {
    const String otherPrefix = 'Other: ';

    if (!value.startsWith(otherPrefix)) {
      return value;
    }

    final String custom =
        value.substring(otherPrefix.length).trim();

    return custom.isEmpty ? 'Other' : custom;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: const Key('onboarding-summary-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Your starting plan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This brings together what you chose so far. Use Back to '
          'change anything before finishing setup.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        _SummarySection(
          title: 'Recovery mode',
          child: Text(_modeLabel),
        ),
        _SummarySection(
          title: 'Support needs',
          child: _SummaryValues(
            values: draft.supportNeeds,
            emptyText: 'No support needs selected.',
          ),
        ),
        _SummarySection(
          title: 'Selected reasons',
          child: _SummaryValues(
            values: draft.reasons,
            emptyText: 'No reasons selected.',
          ),
        ),
        _SummarySection(
          title: 'Current Focus',
          child: Text(
            draft.currentFocus.trim().isEmpty
                ? 'Not selected.'
                : draft.currentFocus.trim(),
          ),
        ),
        _SummarySection(
          title: 'Personal Why',
          child: Text(
            draft.whyText.trim().isEmpty
                ? 'Not added (optional).'
                : draft.whyText.trim(),
          ),
        ),
        _SummarySection(
          title: 'Triggers',
          child: _SummaryValues(
            values: draft.triggers,
            emptyText: 'None selected yet (optional).',
          ),
        ),
        _SummarySection(
          title: 'Risky times',
          child: _SummaryValues(
            values: draft.riskyTimes,
            emptyText: 'None selected yet (optional).',
          ),
        ),
        _SummarySection(
          title: 'Interruption actions',
          child: _SummaryValues(
            values: draft.interruptionActions
                .map(_displayInterruptionAction)
                .toList(),
            emptyText: 'None selected yet (optional).',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'This is a starter recovery setup—not a diagnosis, treatment '
          'plan, or guarantee. Rescue remains available whenever a wave rises.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SummaryValues extends StatelessWidget {
  const _SummaryValues({
    required this.values,
    required this.emptyText,
  });

  final List<String> values;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Text(emptyText);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (String value) => Chip(
              label: Text(value),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}
