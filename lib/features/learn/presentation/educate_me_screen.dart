// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: educate_me_screen.dart
// Purpose: BW-28 Educate Me learning surface v1.
// Notes: Short practical lessons plus a premium bridge to deeper guided learning.
// Notes: BW-77B replaces wrapping lesson chips with stable full-width lesson rows.
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

  void _selectLesson(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            _LessonSelectorList(
              selectedIndex: _selectedIndex,
              onSelected: _selectLesson,
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
                    content: Text('Premium guided learning is part of BreakWave Plus.'),
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

class _LessonSelectorList extends StatelessWidget {
  const _LessonSelectorList({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < LearningCardPack.starter.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == LearningCardPack.starter.length - 1 ? 0 : 10,
            ),
            child: _LessonSelectorTile(
              title: LearningCardPack.starter[index].title,
              isSelected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
          ),
      ],
    );
  }
}

class _LessonSelectorTile extends StatelessWidget {
  const _LessonSelectorTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withOpacity(0.36)
                : colorScheme.surfaceContainerHighest.withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 24,
                child: Icon(
                  isSelected ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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
