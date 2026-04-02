// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_screen.dart
// Purpose: BW-05 support foundation screen for BreakWave.
// Notes: Neutral support scaffold for BW-05.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'widgets/education_resources_card.dart';
import 'widgets/emergency_help_card.dart';
import 'widgets/support_categories_card.dart';
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
                  Text(
                    'Support makes the wave smaller.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use this space to reach for practical help, reduce isolation, and strengthen your next good decision.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
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
