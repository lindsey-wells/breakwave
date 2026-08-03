// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-55 grouped Support tab cleanup.
// Notes: BW-73A declutters Support with collapsible launch-ready groups.
// Notes: BW-87B4C passes real guided-routine navigation actions into Plus.
// Notes: BW-SUPPORT-01B puts immediate support first and expands it by default.
// Notes: BW-SUPPORT-01C creates a compact task-based Support structure.
// Notes: BW-ONBOARD-01B1 adds the replayable tutorial entry first.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/breakwave_app_bar.dart';
import '../../../core/ui/wave_surface.dart';
import '../../guided_routines/domain/recovery_routine.dart';
import '../../premium/presentation/breakwave_plus_screen.dart';
import 'widgets/breakwave_contact_links_card.dart';
import 'widgets/cbt_informed_support_card.dart';
import 'widgets/custom_why_settings_card.dart';
import 'widgets/educate_me_entry_card.dart';
import 'widgets/education_resources_card.dart';
import 'widgets/email_app_handoff_card.dart';
import 'widgets/email_capture_settings_card.dart';
import 'widgets/email_export_card.dart';
import 'widgets/emergency_help_card.dart';
import 'widgets/privacy_lock_settings_card.dart';
import 'widgets/privacy_settings_card.dart';
import 'widgets/professional_help_card.dart';
import 'widgets/recovery_mode_settings_card.dart';
import 'widgets/reminder_settings_card.dart';
import 'widgets/support_categories_card.dart';
import 'widgets/support_contact_card.dart';
import 'widgets/support_quick_actions_card.dart';
import 'widgets/teach_me_breakwave_entry_card.dart';
import 'widgets/trusted_accountability_card.dart';
import 'widgets/who_we_are_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({
    super.key,
    this.onRoutineActionRequested,
  });

  final ValueChanged<RoutineActionTarget>? onRoutineActionRequested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BreakWaveAppBar(sectionTitle: 'Support'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const WaveSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Support Harbor',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find the right support for this moment.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Immediate help stays first. Everything else is grouped by what you want to do next.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const _SupportGroup(
                    key: Key('support-help-now-group'),
                    title: 'Get help now',
                    subtitle:
                        'Emergency guidance, trusted contact setup, and ready-to-send support messages.',
                    icon: Icons.support_agent_outlined,
                    initiallyExpanded: true,
                    children: <Widget>[
                      EmergencyHelpCard(),
                      SupportContactCard(),
                      SupportQuickActionsCard(),
                      TrustedAccountabilityCard(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const _SupportGroup(
                    key: Key('support-recovery-setup-group'),
                    title: 'Set up your recovery',
                    subtitle:
                        'Choose your recovery voice, keep your reasons close, and plan reminders.',
                    icon: Icons.tune_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      RecoveryModeSettingsCard(),
                      CustomWhySettingsCard(),
                      ReminderSettingsCard(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const _SupportGroup(
                    key: Key('support-learn-breakwave-group'),
                    title: 'Learn how BreakWave helps',
                    subtitle:
                        'Understand urges, recovery patterns, and when professional support may help.',
                    icon: Icons.school_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      // BW-ONBOARD-01B inserts the replayable tutorial first here.
                      TeachMeBreakWaveEntryCard(),
                      CbtInformedSupportCard(),
                      ProfessionalHelpCard(),
                      SupportCategoriesCard(),
                      EducationResourcesCard(),
                      EducateMeEntryCard(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const _SupportGroup(
                    key: Key('support-privacy-safety-group'),
                    title: 'Privacy and safety',
                    subtitle:
                        'Control app lock, notification privacy, Home visibility, and screen protection.',
                    icon: Icons.lock_outline,
                    initiallyExpanded: false,
                    children: <Widget>[
                      PrivacyLockSettingsCard(),
                      PrivacySettingsCard(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _SupportGroup(
                    key: const Key('support-plus-group'),
                    title: 'Explore BreakWave Plus',
                    subtitle:
                        'Preview longer-term planning, insight, and guided recovery tools.',
                    icon: Icons.workspace_premium_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      _BreakWavePlusPreviewCard(
                        onRoutineActionRequested: onRoutineActionRequested,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const _SupportGroup(
                    key: Key('support-about-contact-group'),
                    title: 'About and contact',
                    subtitle:
                        'Meet the people behind BreakWave, send feedback, or stay connected.',
                    icon: Icons.people_outline,
                    initiallyExpanded: false,
                    children: <Widget>[
                      WhoWeAreCard(),
                      EmailCaptureSettingsCard(),
                      EmailAppHandoffCard(),
                      BreakWaveContactLinksCard(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const _SupportGroup(
                    key: Key('support-more-tools-group'),
                    title: 'More tools',
                    subtitle:
                        'Manage data export and other less-frequent support settings.',
                    icon: Icons.more_horiz_rounded,
                    initiallyExpanded: false,
                    children: <Widget>[
                      EmailExportCard(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportGroup extends StatelessWidget {
  const _SupportGroup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.initiallyExpanded,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final BorderRadius borderRadius = BorderRadius.circular(22);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        maintainState: true,
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 22,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        children: <Widget>[
          for (int index = 0; index < children.length; index++) ...<Widget>[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BreakWavePlusPreviewCard extends StatelessWidget {
  const _BreakWavePlusPreviewCard({
    this.onRoutineActionRequested,
  });

  final ValueChanged<RoutineActionTarget>? onRoutineActionRequested;

  void _openPlus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BreakWavePlusScreen(
          onRoutineActionRequested: onRoutineActionRequested,
        ),
      ),
    );
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
            'BreakWave Plus',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'BreakWave Plus is being built for deeper planning, insights, and guided routines. Subscriptions remain unavailable until those tools are ready and tested.',
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _openPlus(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Preview Plus roadmap'),
            ),
          ),
        ],
      ),
    );
  }
}
