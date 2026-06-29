// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_screen.dart
// Purpose: BW-54 BreakWave Plus value wall.
// Notes: Plus value screen for planned upgrade access.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/premium/premium_state_store.dart';

class BreakWavePlusScreen extends StatefulWidget {
  const BreakWavePlusScreen({super.key});

  @override
  State<BreakWavePlusScreen> createState() => _BreakWavePlusScreenState();
}

class _BreakWavePlusScreenState extends State<BreakWavePlusScreen> {
  bool _saving = false;

  Future<void> _setVariant(String variant) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await PremiumStateStore.setOfferVariant(variant);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            variant == 'annual_trial'
                ? 'Saved Plus offer: annual with 7-day trial.'
                : 'Saved Plus offer: annual without trial.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _enablePlusPreview() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await PremiumStateStore.setPlusUnlocked(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BreakWave Plus unlocked.'),
        ),
      );

      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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
                    'Free immediate relief. Paid ongoing transformation.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BreakWave Plus does not gate immediate relief. BreakWave keeps urgent help free and unlocks deeper tools for planning, insight, accountability, and long-term growth. BreakWave Plus is for users who want deeper insight, a personal plan, stronger accountability, and guided recovery structure.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _enablePlusPreview,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Explore BreakWave Plus'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
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
                    body: 'Rescue, basic logging, recent history, privacy basics, recovery mode, and support resources stay available.',
                  ),
                  SizedBox(height: 12),
                  _Bullet(
                    title: 'BreakWave Plus',
                    body: 'Unlock the deeper transformation layer: insights, guided plans, premium Christian depth, accountability templates, exports, and advanced privacy tools.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'BreakWave Plus includes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  _FeaturePillar(
                    title: 'Deep Insights',
                    body: 'Longer history, trigger trends, risky-time patterns, weekly summaries, and clearer “what usually happens before a slip” views.',
                  ),
                  _FeaturePillar(
                    title: 'Custom Rescue Plan',
                    body: 'A personal plan built around your triggers, danger times, reasons, redirect actions, trusted person, and after-slip reset.',
                  ),
                  _FeaturePillar(
                    title: 'Guided Recovery Routines',
                    body: 'Morning reset, bedtime protection, after-slip recovery, loneliness plan, stress plan, and phone-boundary routines.',
                  ),
                  _FeaturePillar(
                    title: 'Accountability Tools',
                    body: 'Trusted-person check-ins, shareable summaries, honesty templates, victory reports, and “I need help now” messages.',
                  ),
                  _FeaturePillar(
                    title: 'Premium Christian Depth',
                    body: 'Grace-forward paths for shame, secrecy, loneliness, rebuilding integrity, and nighttime temptation.',
                  ),
                  _FeaturePillar(
                    title: 'Advanced Privacy and Exports',
                    body: 'Longer export options, advanced privacy controls, and deeper data tools once billing and release systems are live.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Planned Plus options',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  _PlanRow(
                    title: 'BreakWave Plus Annual',
                    price: '\$59.99/year',
                    note: 'Planned best-value option.',
                  ),
                  SizedBox(height: 12),
                  _PlanRow(
                    title: 'BreakWave Plus Monthly',
                    price: '\$8.99/month',
                    note: 'Planned flexible option.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No weekly plan. No lifetime plan at launch.',
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
                    'Planned launch offer',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Compare planned annual offer options before the launch default is finalized.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _saving
                        ? null
                        : () => _setVariant('annual_no_trial'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Select annual no-trial'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: _saving
                        ? null
                        : () => _setVariant('annual_trial'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Select annual 7-day trial'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Purchase status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'BreakWave Plus purchasing is not active yet. Immediate support tools remain free while paid upgrade access is finalized.',
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
