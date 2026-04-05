// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-05 support foundation screen for BreakWave.
// Notes: Neutral support scaffold for BW-06.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import 'widgets/education_resources_card.dart';
import 'widgets/emergency_help_card.dart';
import 'widgets/support_categories_card.dart';
import 'widgets/support_contact_card.dart';
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
                          'This space should feel like safe water: practical, calm, and easy to reach when the tide gets rough.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SupportContactCard(),
                  const SizedBox(height: 16),
                  const SupportQuickActionsCard(),
                  const SizedBox(height: 16),
                  const SupportCategoriesCard(),
                  const SizedBox(height: 16),
                  const EmergencyHelpCard(),
                  const SizedBox(height: 16),
                  const TrustedAccountabilityCard(),
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
