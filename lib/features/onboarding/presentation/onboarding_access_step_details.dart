// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_access_step_details.dart
// Purpose: Honest Free-versus-Plus onboarding choice.
// Notes: The selection is navigation intent and never entitlement.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/onboarding/onboarding_draft.dart';

class OnboardingAccessStepDetails extends StatelessWidget {
  const OnboardingAccessStepDetails({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onChanged,
  });

  final OnboardingDraft draft;
  final bool enabled;
  final ValueChanged<OnboardingAccessChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: const Key('onboarding-access-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose what happens after setup',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Continue Free always remains available. Reviewing Plus only '
          'opens an information screen after setup.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        _AccessChoiceCard(
          key: const Key('onboarding-access-continue-free'),
          title: 'Continue Free',
          subtitle: 'Enter BreakWave with the protected recovery core.',
          selected: draft.accessChoice ==
              OnboardingAccessChoice.continueFree,
          enabled: enabled,
          icon: Icons.verified_user_outlined,
          bullets: const <String>[
            'Rescue and basic urge interruption',
            'Basic logging and access to your own recovery data',
            'Privacy controls and essential support resources',
            'Base secular or Christian recovery language',
          ],
          onTap: () {
            onChanged(OnboardingAccessChoice.continueFree);
          },
        ),
        const SizedBox(height: 14),
        _AccessChoiceCard(
          key: const Key('onboarding-access-review-plus'),
          title: 'Review BreakWave Plus',
          subtitle:
              'Finish setup, then open the honest Plus information screen.',
          selected: draft.accessChoice ==
              OnboardingAccessChoice.reviewPlus,
          enabled: enabled,
          icon: Icons.auto_awesome_outlined,
          bullets: const <String>[
            'Deeper recovery insights and structured planning',
            'Guided routines and accountability reports',
            'Multi-step journeys and advanced recovery tools',
            'Base Christian mode remains free',
          ],
          onTap: () {
            onChanged(OnboardingAccessChoice.reviewPlus);
          },
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.36),
          ),
          child: const Text(
            'Plus purchasing is not available yet. There is no price, '
            'trial, checkout, purchase, restore, or subscription action '
            'on this screen. Choosing Review Plus does not unlock Plus.',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          draft.accessChoice == OnboardingAccessChoice.undecided
              ? 'Choose Continue Free or Review BreakWave Plus to finish setup.'
              : 'Your choice is saved as navigation intent only.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: draft.accessChoice ==
                    OnboardingAccessChoice.undecided
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AccessChoiceCard extends StatelessWidget {
  const _AccessChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.bullets,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final IconData icon;
  final List<String> bullets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected
            ? colorScheme.primaryContainer.withOpacity(0.82)
            : colorScheme.surfaceContainerHighest.withOpacity(0.36),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : icon,
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 12),
                for (final String bullet in bullets) ...<Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_rounded,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(bullet)),
                    ],
                  ),
                  if (bullet != bullets.last)
                    const SizedBox(height: 7),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
