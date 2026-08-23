import 'package:flutter/material.dart';

class WhatHelpedBeforeCard extends StatelessWidget {
  const WhatHelpedBeforeCard({
    super.key,
    required this.actions,
  });

  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('what-helped-before-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'What helped before',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'These are actions you saved with past victories. '
              'BreakWave is remembering what you recorded—not predicting '
              'what will work next.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ...actions.map(
              (String action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'You decide whether any of these fit today.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
