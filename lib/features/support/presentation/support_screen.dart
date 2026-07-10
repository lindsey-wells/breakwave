// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-55 grouped Support tab cleanup.
// Notes: BW-73A declutters Support with collapsible launch-ready groups.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/breakwave_app_bar.dart';
import '../../faith/presentation/faith_depth_pack_screen.dart';
import '../../premium/presentation/breakwave_plus_screen.dart';
import '../../premium/presentation/premium_gate_tile.dart';
import 'widgets/breakwave_contact_links_card.dart';
import 'widgets/cbt_informed_support_card.dart';
import 'widgets/professional_help_card.dart';
import 'widgets/custom_why_settings_card.dart';
import 'widgets/educate_me_entry_card.dart';
import 'widgets/education_resources_card.dart';
import 'widgets/email_app_handoff_card.dart';
import 'widgets/email_capture_settings_card.dart';
import 'widgets/email_export_card.dart';
import 'widgets/emergency_help_card.dart';
import 'widgets/privacy_lock_settings_card.dart';
import 'widgets/privacy_settings_card.dart';
import 'widgets/recovery_mode_settings_card.dart';
import 'widgets/reminder_settings_card.dart';
import 'widgets/support_categories_card.dart';
import 'widgets/support_contact_card.dart';
import 'widgets/support_quick_actions_card.dart';
import 'widgets/trusted_accountability_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BreakWaveAppBar(sectionTitle: 'Support'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
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
                          'Get support before the wave gets stronger.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Set up trusted help, privacy, recovery mode, and deeper tools from one organized place.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const _SupportGroup(
                    eyebrow: 'Recovery model',
                    title: 'Cognitive behavioral tools, not shame',
                    subtitle:
                        'Understand the recovery approach behind BreakWave before the support tools.',
                    icon: Icons.psychology_alt_outlined,
                    initiallyExpanded: true,
                    children: <Widget>[
                      CbtInformedSupportCard(),
                      ProfessionalHelpCard(),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Get help now',
                    title: 'Reduce isolation fast',
                    subtitle:
                        'Reach a trusted person, open emergency options, or copy a support message.',
                    icon: Icons.support_agent_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      EmergencyHelpCard(),
                      SupportContactCard(),
                      SupportQuickActionsCard(),
                      TrustedAccountabilityCard(),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Your recovery setup',
                    title: 'Personalize how BreakWave supports you',
                    subtitle:
                        'Choose your recovery mode, save your why, and set reminders.',
                    icon: Icons.tune_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      RecoveryModeSettingsCard(),
                      CustomWhySettingsCard(),
                      ReminderSettingsCard(),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _SupportGroup(
                    eyebrow: 'BreakWave Plus',
                    title: 'Go deeper than emergency interruption',
                    subtitle:
                        'Explore longer-term insight, guided tools, and premium depth.',
                    icon: Icons.workspace_premium_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      const _BreakWavePlusPreviewCard(),
                      const PremiumGateTile(
                        title: 'Deeper insights and exports',
                        description:
                            'Explore longer recovery history, deeper insight surfaces, advanced charts, and export tools in BreakWave Plus.',
                      ),
                      PremiumGateTile(
                        title: 'Faith depth pack',
                        description:
                            'Unlock grace-forward Christian depth on shame, secrecy, loneliness, and rebuilding integrity.',
                        onUnlockedTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FaithDepthPackScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Privacy and safety',
                    title: 'Protect sensitive recovery details',
                    subtitle:
                        'Control app lock, notification privacy, Home visibility, and screen privacy.',
                    icon: Icons.lock_outline,
                    initiallyExpanded: false,
                    children: <Widget>[
                      PrivacyLockSettingsCard(),
                      PrivacySettingsCard(),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Learn and resources',
                    title: 'Understand the pattern and choose next steps',
                    subtitle:
                        'Education resources and next-step learning surfaces.',
                    icon: Icons.menu_book_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      SupportCategoriesCard(),
                      EducationResourcesCard(),
                      EducateMeEntryCard(),
                    ],
                  ),


                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Contact BreakWave',
                    title: 'Send feedback or stay connected',
                    subtitle:
                        'Email preferences, manual feedback handoff, and public links.',
                    icon: Icons.email_outlined,
                    initiallyExpanded: false,
                    children: <Widget>[
                      EmailCaptureSettingsCard(),
                      EmailAppHandoffCard(),
                      BreakWaveContactLinksCard(),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const _SupportGroup(
                    eyebrow: 'Advanced',
                    title: 'Data export tools',
                    subtitle:
                        'Manual export tools for saved email-consent data.',
                    icon: Icons.ios_share_outlined,
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
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _SupportGroup({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Icon(icon),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              eyebrow,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(subtitle),
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
  const _BreakWavePlusPreviewCard();

  void _openPlus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BreakWavePlusScreen(),
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
            'Free gives users immediate help. Plus is the deeper transformation layer for insights, guided routines, accountability, premium Christian depth, and longer-term recovery tools.',
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _openPlus(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('View Plus features'),
            ),
          ),
        ],
      ),
    );
  }
}
