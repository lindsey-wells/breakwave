// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_intro_step_details.dart
// Purpose: Real content for onboarding steps one through four.
// Notes: BW-87B6P3B2A1 writes only to the onboarding draft.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';
import '../../../core/recovery/recovery_mode.dart';

class OnboardingIntroStepDetails
    extends StatelessWidget {
  const OnboardingIntroStepDetails({
    super.key,
    required this.step,
    required this.draft,
    required this.loading,
    required this.enabled,
    required this.onModeChanged,
    required this.onSupportNeedChanged,
  });

  final int step;
  final OnboardingDraft draft;
  final bool loading;
  final bool enabled;
  final ValueChanged<RecoveryMode>
      onModeChanged;
  final void Function(
    String value,
    bool selected,
  ) onSupportNeedChanged;

  static const List<String> supportNeeds =
      <String>[
    'Interrupt urges quickly',
    'Understand my patterns',
    'Prepare for risky times',
    'Build a practical recovery plan',
    'Stay encouraged after setbacks',
  ];

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (step) {
      case 0:
        return _buildWelcome(context);
      case 1:
        return _buildPrivacy(context);
      case 2:
        return _buildRecoveryMode(context);
      case 3:
        return _buildSupportNeeds(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcome(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    return Column(
      key: const Key(
        'onboarding-welcome-details',
      ),
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Why this exists',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'BreakWave began with a simple belief: '
          'help should be within reach before a '
          'private urge becomes a private decision.',
        ),
        const SizedBox(height: 18),
        const _InfoLine(
          icon: Icons.waves_rounded,
          title: 'Fast help when the wave rises',
          body:
              'Open Rescue immediately instead of '
              'trying to outthink the urge alone.',
        ),
        const SizedBox(height: 14),
        const _InfoLine(
          icon: Icons.schedule_rounded,
          title: 'Preparation before pressure',
          body:
              'Identify risky windows and choose '
              'your next move ahead of time.',
        ),
        const SizedBox(height: 14),
        const _InfoLine(
          icon: Icons.favorite_outline,
          title: 'Honesty without shame',
          body:
              'Notice patterns, learn from them, '
              'and keep moving forward.',
        ),
        const SizedBox(height: 18),
        Text(
          'BreakWave is not therapy, medical '
          'treatment, or a cure. It is a private '
          'recovery support tool for practical '
          'next steps.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPrivacy(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    return Column(
      key: const Key(
        'onboarding-privacy-details',
      ),
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'What stays private',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const _InfoLine(
          icon: Icons.phone_android_rounded,
          title: 'Local by default',
          body:
              'Your setup, logs, plans, and progress '
              'are stored on this device.',
        ),
        const SizedBox(height: 14),
        const _InfoLine(
          icon: Icons.visibility_off_outlined,
          title: 'No automatic sharing',
          body:
              'BreakWave does not silently send your '
              'recovery information to another person.',
        ),
        const SizedBox(height: 14),
        const _InfoLine(
          icon: Icons.preview_outlined,
          title: 'Preview before sharing',
          body:
              'Recovery reports require your exact '
              'choices and a preview before anything '
              'leaves the app.',
        ),
        const SizedBox(height: 14),
        const _InfoLine(
          icon: Icons.tune_rounded,
          title: 'You remain in control',
          body:
              'You can change your recovery mode, '
              'privacy settings, and saved plans later.',
        ),
        const SizedBox(height: 18),
        Text(
          'BreakWave is not an emergency service. '
          'Immediate danger or a medical emergency '
          'requires local emergency help.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRecoveryMode(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    return Column(
      key: const Key(
        'onboarding-recovery-mode-details',
      ),
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose the voice that fits you',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This changes the language and guidance '
          'you see. Neither choice changes access '
          'to Rescue.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        for (
          final RecoveryMode mode
          in RecoveryMode.values
        ) ...<Widget>[
          _ModeChoiceCard(
            mode: mode,
            selected:
                draft.recoveryMode == mode,
            enabled: enabled,
            onSelected: () {
              onModeChanged(mode);
            },
          ),
          if (mode != RecoveryMode.values.last)
            const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        Text(
          draft.recoveryMode == null
              ? 'Choose one recovery path to continue.'
              : 'You can change this later from '
                  'BreakWave settings.',
          style: theme.textTheme.bodySmall
              ?.copyWith(
            fontWeight:
                draft.recoveryMode == null
                    ? FontWeight.w800
                    : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportNeeds(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    return Column(
      key: const Key(
        'onboarding-support-needs-details',
      ),
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Select everything that would help',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These choices personalize setup. They '
          'do not diagnose you or assign a treatment.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              supportNeeds.map(
            (String need) {
              final bool selected =
                  draft.supportNeeds
                      .contains(need);

              return FilterChip(
                key: ValueKey<String>(
                  'support-need-$need',
                ),
                label: Text(need),
                selected: selected,
                onSelected: enabled
                    ? (bool value) {
                        onSupportNeedChanged(
                          need,
                          value,
                        );
                      }
                    : null,
              );
            },
          ).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          draft.supportNeeds.isEmpty
              ? 'Choose at least one area to continue.'
              : '${draft.supportNeeds.length} '
                  '${draft.supportNeeds.length == 1 ? 'area' : 'areas'} '
                  'selected.',
          style: theme.textTheme.bodySmall
              ?.copyWith(
            fontWeight:
                draft.supportNeeds.isEmpty
                    ? FontWeight.w800
                    : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ModeChoiceCard
    extends StatelessWidget {
  const _ModeChoiceCard({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final RecoveryMode mode;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: mode.title,
      child: Material(
        color: selected
            ? colorScheme.primary
                .withOpacity(0.18)
            : colorScheme.surface
                .withOpacity(0.55),
        borderRadius:
            BorderRadius.circular(20),
        child: InkWell(
          key: ValueKey<String>(
            'onboarding-mode-${mode.storageValue}',
          ),
          onTap:
              enabled ? onSelected : null,
          borderRadius:
              BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? colorScheme.secondary
                    : colorScheme.onSurface
                        .withOpacity(0.18),
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  mode ==
                          RecoveryMode.christian
                      ? Icons.menu_book_outlined
                      : Icons.psychology_outlined,
                  color: selected
                      ? colorScheme.secondary
                      : colorScheme.onSurface
                          .withOpacity(0.82),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        mode.title,
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mode.description,
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: selected
                      ? colorScheme.secondary
                      : colorScheme.onSurface
                          .withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(body),
            ],
          ),
        ),
      ],
    );
  }
}
