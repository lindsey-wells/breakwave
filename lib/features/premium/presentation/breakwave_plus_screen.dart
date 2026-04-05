// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_screen.dart
// Purpose: BW-25 BreakWave Plus paywall shell.
// Notes: Local scaffold only. No real billing integration yet.
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
                ? 'Saved paywall variant: annual with 7-day trial.'
                : 'Saved paywall variant: annual without trial.',
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

  Future<void> _debugUnlock() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await PremiumStateStore.setPlusUnlocked(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BreakWave Plus unlocked locally for scaffold testing.'),
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
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakWave Plus'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Container(
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
                    'Free immediate relief. Paid ongoing transformation.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Core help stays free forever. BreakWave Plus is for deeper insight, planning, accountability, and guided growth.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'BreakWave Plus Annual',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('\$59.99/year • shown first by default'),
                  const SizedBox(height: 14),
                  Text(
                    'BreakWave Plus Monthly',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('\$8.99/month • secondary option'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'BreakWave Plus includes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• full rescue card engine library'),
                  Text('• custom rescue plans'),
                  Text('• deeper recovery insights'),
                  Text('• advanced charts and longer history'),
                  Text('• accountability tools'),
                  Text('• check-in templates'),
                  Text('• premium guided routines'),
                  Text('• premium Christian content packs'),
                  Text('• home widgets'),
                  Text('• advanced privacy lock modes'),
                  Text('• exports'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                    'Offer test variant',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Use this scaffold to compare annual no-trial versus annual 7-day trial before locking the launch default.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _saving ? null : () => _setVariant('annual_no_trial'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Set annual no-trial variant'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: _saving ? null : () => _setVariant('annual_trial'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Set annual 7-day trial variant'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _saving ? null : _debugUnlock,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Debug unlock BreakWave Plus'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
