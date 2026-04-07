// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_card_engine.dart
// Purpose: BW-16/BW-17/BW-18 rescue card engine.
// Notes: Renders Christian or secular rescue cards based on recovery mode.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/recovery/recovery_mode.dart';
import '../../../../core/recovery/recovery_mode_store.dart';
import '../../domain/christian_rescue_card_pack.dart';
import '../../domain/rescue_card_content.dart';
import '../../domain/secular_rescue_card_pack.dart';

class RescueCardEngine extends StatefulWidget {
  const RescueCardEngine({super.key});

  @override
  State<RescueCardEngine> createState() => _RescueCardEngineState();
}

class _RescueCardEngineState extends State<RescueCardEngine> {
  List<RescueCardContent> _cards = const <RescueCardContent>[];
  int _currentIndex = 0;
  bool _loading = true;
  RecoveryMode _mode = RecoveryMode.secular;

  @override
  void initState() {
    super.initState();
        RecoveryModeStore.changes.addListener(_handleModeChange);
_loadCards();
  }

  Future<void> _loadCards() async {
    final RecoveryMode mode =
        await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;

    final List<RescueCardContent> cards =
        mode == RecoveryMode.christian
            ? ChristianRescueCardPack.cards
            : SecularRescueCardPack.cards;

    if (!mounted) return;

    setState(() {
      _mode = mode;
      _cards = cards;
      _currentIndex = 0;
      _loading = false;
    });
  }

  void _nextCard() {
    if (_cards.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _handleModeChange() {
    _loadMode();
  }

  @override
  void dispose() {
    RecoveryModeStore.changes.removeListener(_handleModeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: const Text('No rescue cards available.'),
      );
    }

    final RescueCardContent card = _cards[_currentIndex];
    final bool isChristian = _mode == RecoveryMode.christian;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isChristian ? 'Christian Rescue Card' : 'Secular Rescue Card',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_currentIndex + 1} of ${_cards.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Text(
            card.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _SectionBlock(
            label: 'Calm line',
            body: card.calmLine,
          ),
          const SizedBox(height: 12),
          _SectionBlock(
            label: 'Reframe',
            body: card.reframe,
          ),
          const SizedBox(height: 12),
          _SectionBlock(
            label: 'Immediate action',
            body: card.immediateAction,
          ),
          const SizedBox(height: 12),
          _SectionBlock(
            label: 'Next step',
            body: card.nextStep,
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: _nextCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                isChristian
                    ? 'Show another Christian rescue card'
                    : 'Show another secular rescue card',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.label,
    required this.body,
  });

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
