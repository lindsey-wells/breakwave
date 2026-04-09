// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-05 support foundation screen for BreakWave.
// Notes: Neutral support scaffold for BW-06.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/section_header.dart';
import 'widgets/education_resources_card.dart';
import 'widgets/emergency_help_card.dart';
import 'widgets/support_categories_card.dart';
import 'widgets/support_contact_card.dart';
import 'widgets/reminder_settings_card.dart';
import '../../faith/presentation/faith_depth_pack_screen.dart';
import '../../premium/presentation/premium_gate_tile.dart';
import 'widgets/privacy_settings_card.dart';
import 'widgets/educate_me_entry_card.dart';
import 'widgets/recovery_mode_settings_card.dart';
import 'widgets/privacy_lock_settings_card.dart';
import 'widgets/custom_why_settings_card.dart';
import 'widgets/support_quick_actions_card.dart';
import 'widgets/trusted_accountability_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                          'Support makes the wave smaller.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Practical, calm support you can reach quickly when the tide gets rough.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    eyebrow: 'Settings and learning',
                    title: 'Adjust how BreakWave supports you',
                  ),
                  const RecoveryModeSettingsCard(),
                  const SizedBox(height: 16),
                  const PrivacyLockSettingsCard(),
                  const SizedBox(height: 16),
                  const CustomWhySettingsCard(),
                  const SizedBox(height: 16),
                  const EducateMeEntryCard(),
                  const SizedBox(height: 16),
                  const PremiumGateTile(
                    title: 'Deeper insights and exports',
                    description: 'Unlock longer recovery history, deeper insight surfaces, advanced charts, and export tools in BreakWave Plus.',
                  ),
                  const SizedBox(height: 16),
                  PremiumGateTile(
                    title: 'Faith depth pack',
                    description: 'Unlock grace-forward Christian depth on shame, secrecy, loneliness, and rebuilding integrity.',
                    onUnlockedTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FaithDepthPackScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const PrivacySettingsCard(),
                  const SizedBox(height: 16),
                  const ReminderSettingsCard(),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Contact and quick help',
                    title: 'Reduce isolation fast',
                  ),
                  const SupportContactCard(),
                  const SizedBox(height: 16),
                  const SupportQuickActionsCard(),
                  const SizedBox(height: 16),
                  const EmergencyHelpCard(),
                  const SizedBox(height: 16),
                  const TrustedAccountabilityCard(),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    eyebrow: 'Resources',
                    title: 'Use support tools that teach and guide',
                  ),
                  const SupportCategoriesCard(),
                  const SizedBox(height: 16),
                  const EducationResourcesCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
