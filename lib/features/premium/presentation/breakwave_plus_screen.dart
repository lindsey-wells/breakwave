// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_screen.dart
// Purpose: Honest BreakWave Plus development preview.
// Notes: BW-87B1 removes pricing and unavailable-feature sales claims.
// Notes: Subscriptions remain blocked until the paid launch gate is met.
// Notes: BW-87B2B adds a working recovery insights preview.
// Notes: BW-87B3B adds a working personal recovery plan preview.
// Notes: BW-87B4B adds the guided routine library and player preview.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../guided_routines/presentation/guided_routines_screen.dart';
import '../../insights/presentation/recovery_insights_screen.dart';
import '../../personal_plan/presentation/personal_recovery_plan_screen.dart';

class BreakWavePlusScreen extends StatelessWidget {
  const BreakWavePlusScreen({super.key});

  void _openRecoveryInsights(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RecoveryInsightsScreen(),
      ),
    );
  }

  void _openPersonalRecoveryPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PersonalRecoveryPlanScreen(),
      ),
    );
  }

  void _openGuidedRoutines(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GuidedRoutinesScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakWave Plus'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BreakWave Plus is in development.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The free BreakWave experience focuses on immediate interruption, logging, privacy, and practical support. Plus will not be sold until it provides a substantial set of working tools for longer-term recovery.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Available free in this testing build',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  _Bullet(
                    title: 'Immediate interruption',
                    body:
                        'Rescue, the wave timer, next-right-action tools, and quick urge logging remain free.',
                  ),
                  SizedBox(height: 12),
                  _Bullet(
                    title: 'Recovery foundations',
                    body:
                        'Basic logging, recent history, recovery mode, reminders, privacy controls, trusted-contact tools, and educational support remain free.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'What Plus must deliver before paid launch',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  _FeaturePillar(
                    title: 'Meaningful insights',
                    body:
                        'Working 30-day and 90-day history, trigger trends, risky-time patterns, and summaries generated from the user’s real recovery logs.',
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () =>
                          _openRecoveryInsights(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Preview recovery insights',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeaturePillar(
                    title: 'A saved personal recovery plan',
                    body:
                        'A practical plan connecting triggers, danger windows, reasons, redirect actions, trusted support, phone boundaries, and an after-slip reset.',
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () =>
                          _openPersonalRecoveryPlan(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Preview personal recovery plan',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeaturePillar(
                    title: 'Guided recovery routines',
                    body:
                        'Repeatable routines for bedtime, stress, loneliness, phone boundaries, mornings, and getting back on track—with progress that can be saved.',
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () =>
                          _openGuidedRoutines(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Preview guided routines',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeaturePillar(
                    title: 'Useful accountability tools',
                    body:
                        'Shareable recovery summaries, check-in templates, support messages, and controls that let the user decide exactly what leaves the device.',
                  ),
                  _FeaturePillar(
                    title: 'Substantial Christian depth',
                    body:
                        'Multi-step Christian recovery journeys with Scripture, reflection, action, prayer, saved progress, and direct connections to Rescue and the personal plan.',
                  ),
                  _FeaturePillar(
                    title: 'Meaningful recovery exports',
                    body:
                        'Exports of recovery history, summaries, trends, and selected accountability information—not merely email-preference data.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Our paid-launch standard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'BreakWave will not enable subscriptions until the core Plus tools work inside the app, survive release testing, and provide value people can use repeatedly—not just read once.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Monthly and annual plans will include the same core recovery features. Annual pricing will be a commitment discount, not a requirement for better recovery tools.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Current testing status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Subscriptions and purchases are not enabled. No charge can occur from this screen. The items above describe the standard Plus must meet before paid access is offered.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusCard extends StatelessWidget {
  const _PlusCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(body),
      ],
    );
  }
}

class _FeaturePillar extends StatelessWidget {
  const _FeaturePillar({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.title,
    required this.price,
    required this.note,
  });

  final String title;
  final String price;
  final String note;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(note),
      ],
    );
  }
}
