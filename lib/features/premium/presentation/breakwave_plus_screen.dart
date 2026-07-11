// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_screen.dart
// Purpose: Public BreakWave Plus value and subscription screen.
// Notes: BW-87A1 removes preview unlock and offer-testing controls.
// Notes: Pricing remains visible while purchases are disabled in testing builds.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWavePlusScreen extends StatelessWidget {
  const BreakWavePlusScreen({super.key});

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
                    'Immediate support stays free. Plus builds the longer plan.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BreakWave Plus is designed for people who want to understand their patterns over time, build a personal recovery plan, strengthen accountability, and keep making progress after the immediate wave passes.',
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
                    'Free vs Plus',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  _Bullet(
                    title: 'Free core',
                    body:
                        'Rescue, basic logging, recent history, recovery mode, privacy controls, and support resources remain available without a subscription.',
                  ),
                  SizedBox(height: 12),
                  _Bullet(
                    title: 'BreakWave Plus',
                    body:
                        'Longer history and pattern views, guided routines, custom recovery planning, accountability templates, expanded exports, and Christian depth when Christian mode is selected.',
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
                    'What Plus is built to provide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  _FeaturePillar(
                    title: 'Deeper patterns and summaries',
                    body:
                        'Longer history, trigger trends, risky-time patterns, weekly summaries, and clearer views of what commonly happens before a slip.',
                  ),
                  _FeaturePillar(
                    title: 'Your personal recovery plan',
                    body:
                        'Bring together your triggers, danger times, reasons, redirect actions, trusted person, and after-slip reset in one structured plan.',
                  ),
                  _FeaturePillar(
                    title: 'Guided recovery routines',
                    body:
                        'Use focused routines for mornings, bedtime, stress, loneliness, phone boundaries, and getting back on track after a slip.',
                  ),
                  _FeaturePillar(
                    title: 'Stronger accountability',
                    body:
                        'Use trusted-person check-ins, shareable summaries, honesty templates, victory reports, and ready-to-send support messages.',
                  ),
                  _FeaturePillar(
                    title: 'Christian recovery depth',
                    body:
                        'When Christian mode is selected, explore grace-forward paths for shame, secrecy, loneliness, integrity, and nighttime temptation.',
                  ),
                  _FeaturePillar(
                    title: 'Expanded privacy and exports',
                    body:
                        'Access longer export options, deeper data tools, and additional privacy controls as paid access becomes available.',
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
                    'Expected launch pricing',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  _PlanRow(
                    title: 'BreakWave Plus Annual',
                    price: '\$59.99/year',
                    note: 'Best value — about \$5 per month.',
                  ),
                  SizedBox(height: 12),
                  _PlanRow(
                    title: 'BreakWave Plus Monthly',
                    price: '\$8.99/month',
                    note: 'Flexible month-to-month access.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No weekly plan and no lifetime plan at launch. Pricing shown is the intended launch pricing and may change before paid access is enabled.',
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
                    'Testing build status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Subscriptions are not enabled in this testing build. No charge can occur from this screen. Core Rescue and support tools remain free.',
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
