// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: faith_depth_pack_screen.dart
// Purpose: BW-26 faith depth pack v1.
// Notes: Premium Christian depth screen for BreakWave Plus.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/premium/premium_state.dart';
import '../../../core/premium/premium_state_store.dart';
import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../premium/presentation/breakwave_plus_screen.dart';
import '../domain/faith_depth_content.dart';
import '../domain/faith_depth_pack.dart';

class FaithDepthPackScreen extends StatefulWidget {
  const FaithDepthPackScreen({super.key});

  @override
  State<FaithDepthPackScreen> createState() => _FaithDepthPackScreenState();
}

class _FaithDepthPackScreenState extends State<FaithDepthPackScreen> {
  bool _loading = true;
  bool _isPlusUnlocked = false;
  RecoveryMode _mode = RecoveryMode.secular;

  @override
  void initState() {
    super.initState();
    PremiumStateStore.changes.addListener(_handlePremiumChange);
    _load();
  }

  @override
  void dispose() {
    PremiumStateStore.changes.removeListener(_handlePremiumChange);
    super.dispose();
  }

  void _handlePremiumChange() {
    _load();
  }

  Future<void> _load() async {
    final PremiumState premium = await PremiumStateStore.load();
    final RecoveryMode mode =
        await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;

    if (!mounted) return;

    setState(() {
      _isPlusUnlocked = premium.isPlusUnlocked;
      _mode = mode;
      _loading = false;
    });
  }

  Future<void> _openPlus() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const BreakWavePlusScreen(),
      ),
    );

    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faith depth pack'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
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
                          'BreakWave Plus Christian depth',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This pack goes beyond immediate rescue. It is built for grace-forward Christian reflection that helps you face shame, secrecy, loneliness, and integrity without drifting into denial or despair.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isPlusUnlocked)
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
                            'Locked in BreakWave Plus',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Core rescue stays free. This pack belongs to the deeper transformation layer inside BreakWave Plus.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _openPlus,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Open BreakWave Plus'),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_mode != RecoveryMode.christian)
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
                            'Christian mode required',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'This pack is intentionally Christian. Switch BreakWave to the Christian recovery path to use the full content as written.',
                          ),
                        ],
                      ),
                    )
                  else
                    ...FaithDepthPack.cards.map(
                      (FaithDepthContent card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FaithDepthCard(card: card),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _FaithDepthCard extends StatelessWidget {
  const _FaithDepthCard({
    required this.card,
  });

  final FaithDepthContent card;

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
            card.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _FaithBlock(
            label: 'Anchor',
            body: card.anchor,
          ),
          const SizedBox(height: 12),
          _FaithBlock(
            label: 'Reflection',
            body: card.reflection,
          ),
          const SizedBox(height: 12),
          _FaithBlock(
            label: 'Practice',
            body: card.practice,
          ),
          const SizedBox(height: 12),
          _FaithBlock(
            label: 'Prayer',
            body: card.prayer,
          ),
        ],
      ),
    );
  }
}

class _FaithBlock extends StatelessWidget {
  const _FaithBlock({
    required this.label,
    required this.body,
  });

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
