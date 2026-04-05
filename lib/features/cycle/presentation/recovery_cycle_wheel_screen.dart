// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_wheel_screen.dart
// Purpose: BW-27 recovery cycle wheel v1.
// Notes: Teachable cycle model with simple stage selection.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../domain/recovery_cycle_stage.dart';

class RecoveryCycleWheelScreen extends StatefulWidget {
  const RecoveryCycleWheelScreen({super.key});

  @override
  State<RecoveryCycleWheelScreen> createState() => _RecoveryCycleWheelScreenState();
}

class _RecoveryCycleWheelScreenState extends State<RecoveryCycleWheelScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final RecoveryCycleStage stage = RecoveryCycleStages.all[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Cycle Wheel'),
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
                    'Learn the wave earlier',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The goal is not just to react at the end of the cycle. The goal is to recognize the pattern sooner and interrupt it before it gets louder.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List<Widget>.generate(
                RecoveryCycleStages.all.length,
                (int index) {
                  final RecoveryCycleStage item = RecoveryCycleStages.all[index];
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
                    stage.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CycleBlock(
                    label: 'What it is',
                    body: stage.summary,
                  ),
                  const SizedBox(height: 12),
                  _CycleBlock(
                    label: 'What usually happens here',
                    body: stage.pattern,
                  ),
                  const SizedBox(height: 12),
                  _CycleBlock(
                    label: 'Interrupt move',
                    body: stage.interruptMove,
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

class _CycleBlock extends StatelessWidget {
  const _CycleBlock({
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
