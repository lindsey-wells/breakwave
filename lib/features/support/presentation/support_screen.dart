// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-55 grouped Support tab cleanup.
// Notes: Organizes Support into launch-ready sections instead of one long settings stack.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/section_header.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
                          'Get support before the wave gets louder.',
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

                  const SectionHeader(
                    eyebrow: 'Get help now',
                    title: 'Reduce isolation fast',
                  ),
                  const SupportContactCard(),
                  const SizedBox(height: 16),
                  const SupportQuickActionsCard(),
                  const SizedBox(height: 16),
                  const EmergencyHelpCard(),
                  const SizedBox(height: 16),
                  const TrustedAccountabilityCard(),

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'Your recovery setup',
                    title: 'Personalize how BreakWave supports you',
                  ),
                  const RecoveryModeSettingsCard(),
                  const SizedBox(height: 16),
                  const CustomWhySettingsCard(),
                  const SizedBox(height: 16),
                  const EducateMeEntryCard(),

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'BreakWave Plus',
                    title: 'Go deeper than emergency interruption',
                  ),
                  const _BreakWavePlusPreviewCard(),
                  const SizedBox(height: 16),
                  const PremiumGateTile(
                    title: 'Deeper insights and exports',
                    description:
                        'Explore longer recovery history, deeper insight surfaces, advanced charts, and export tools in BreakWave Plus.',
                  ),
                  const SizedBox(height: 16),
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

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'Privacy and safety',
                    title: 'Protect sensitive recovery details',
                  ),
                  const PrivacyLockSettingsCard(),
                  const SizedBox(height: 16),
                  const PrivacySettingsCard(),
                  const SizedBox(height: 16),
                  const ReminderSettingsCard(),

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'Learn and resources',
                    title: 'Understand the pattern and choose next steps',
                  ),
                  const CbtInformedSupportCard(),
                  const SizedBox(height: 16),
                  const ProfessionalHelpCard(),
                  const SizedBox(height: 16),
                  const SupportCategoriesCard(),
                  const SizedBox(height: 16),
                  const EducationResourcesCard(),

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'Contact BreakWave',
                    title: 'Send feedback or stay connected',
                  ),
                  const EmailCaptureSettingsCard(),
                  const SizedBox(height: 16),
                  const EmailAppHandoffCard(),
                  const SizedBox(height: 16),
                  const BreakWaveContactLinksCard(),

                  const SizedBox(height: 24),
                  const SectionHeader(
                    eyebrow: 'Advanced',
                    title: 'Data export tools',
                  ),
                  const EmailExportCard(),
                ],
              ),
            ),
          ),
        ),
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
            'BreakWave Plus Preview',
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
