// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: educate_me_screen.dart
// Purpose: BW-28 Educate Me learning surface v1.
// Notes: Short practical lessons plus a premium bridge to deeper guided learning.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../premium/presentation/premium_gate_tile.dart';
import '../domain/learning_card_content.dart';
import '../domain/learning_card_pack.dart';

class EducateMeScreen extends StatefulWidget {
  const EducateMeScreen({super.key});

  @override
  State<EducateMeScreen> createState() => _EducateMeScreenState();
}

class _EducateMeScreenState extends State<EducateMeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final LearningCardContent card = LearningCardPack.starter[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educate Me'),
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
                    'Learn what the wave is doing',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Keep this short and useful. The aim is to understand the pattern sooner so you can interrupt it faster in real life.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List<Widget>.generate(
                LearningCardPack.starter.length,
                (int index) {
                  final LearningCardContent item = LearningCardPack.starter[index];
                  return ChoiceChip(
                    label: Text(item.title),
                    selected: _selectedIndex == index,
                    onSelected: (_) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
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
                    card.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LearnBlock(
                    label: 'What it means',
                    body: card.meaning,
                  ),
                  const SizedBox(height: 12),
                  _LearnBlock(
                    label: 'Why it matters',
                    body: card.whyItMatters,
                  ),
                  const SizedBox(height: 12),
                  _LearnBlock(
                    label: 'Next move',
                    body: card.nextMove,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PremiumGateTile(
              title: 'Guided learning and routines',
              description: 'Unlock deeper guided learning, templates, and structured recovery routines in BreakWave Plus.',
              onUnlockedTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium guided learning is coming soon.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnBlock extends StatelessWidget {
  const _LearnBlock({
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
