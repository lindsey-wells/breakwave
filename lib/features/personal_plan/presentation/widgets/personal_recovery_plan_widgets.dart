// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_widgets.dart
// Purpose: Reusable presentation-only widgets for the personal plan.
// Notes: BW-MOD-01B extracts UI without changing behavior or wording.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class PersonalPlanListField extends StatelessWidget {
  const PersonalPlanListField({
    required this.title,
    required this.helper,
    required this.controller,
    required this.suggestions,
    required this.onToggleSuggestion,
    super.key,
  });

  final String title;
  final String helper;
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onToggleSuggestion;

  List<String> get _selected {
    return controller.text
        .split(RegExp(r'[\n,]'))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
  }

  bool _contains(String suggestion) {
    return _selected.any(
      (String value) =>
          value.toLowerCase() == suggestion.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(helper),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map(
                (String suggestion) {
                  return FilterChip(
                    label: Text(suggestion),
                    selected: _contains(suggestion),
                    onSelected: (_) =>
                        onToggleSuggestion(suggestion),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Your list',
                hintText: 'One item per line',
              ),
              minLines: 2,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
            ),
          ],
        );
      },
    );
  }
}

class PersonalPlanSectionTitle extends StatelessWidget {
  const PersonalPlanSectionTitle(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class PersonalPlanCard extends StatelessWidget {
  const PersonalPlanCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
