// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_reflection_user_experience_test.dart
// Purpose: BW-LOG-01B2 Reflection UX widget coverage.
// ------------------------------------------------------------

import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/log/presentation/widgets/log_cbt_reflection_card.dart';
import 'package:breakwave/features/log/presentation/widgets/log_entry_type_section.dart';
import 'package:breakwave/features/log/presentation/widgets/log_save_card.dart';
import 'package:breakwave/features/log/presentation/widgets/recent_log_entries_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  testWidgets(
    'Reflection selector has its own icon and selection callback',
    (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        _host(
          LogEntryTypeSection(
            selectedType: 'Urge',
            onSelected: (String value) {
              selected = value;
            },
          ),
        ),
      );

      final Finder reflectionChip = find.byKey(
        const ValueKey<String>('log-entry-type-Reflection'),
      );
      expect(reflectionChip, findsOneWidget);
      expect(
        find.byIcon(Icons.lightbulb_outline_rounded),
        findsOneWidget,
      );

      await tester.tap(reflectionChip);
      expect(selected, 'Reflection');
    },
  );

  testWidgets(
    'Reflection history badge appears without intensity',
    (WidgetTester tester) async {
      const LogEntry entry = LogEntry.reflection(
        id: 'reflection-1',
        triggers: <String>['Boredom'],
        notes: 'I noticed the pattern before acting.',
        createdAtIso: '2026-07-30T18:00:00.000',
      );

      await tester.pumpWidget(
        _host(
          RecentLogEntriesCard(
            entries: const <LogEntry>[entry],
            totalEntryCount: 1,
            showAllEntries: false,
            highlightedEntryId: null,
            onToggleShowAll: () {},
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      );

      expect(
        find.byKey(
          const ValueKey<String>('log-entry-badge-reflection'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Intensity'), findsNothing);
    },
  );

  testWidgets(
    'Reflection draft summary does not invent intensity',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          LogSaveCard(
            entryType: 'Reflection',
            intensity: null,
            triggerCount: 0,
            savedEntryCount: 4,
            isSaving: false,
            isEditing: false,
            lastSaveMessage: null,
            onSave: () async {},
            onCancelEdit: () {},
          ),
        ),
      );

      expect(
        find.text('Current draft: Reflection • 0 triggers selected'),
        findsOneWidget,
      );
      expect(find.textContaining('intensity'), findsNothing);
    },
  );

  testWidgets(
    'Reflection card uses calm nonjudgmental prompts',
    (WidgetTester tester) async {
      final TextEditingController thought = TextEditingController();
      final TextEditingController action = TextEditingController();
      final TextEditingController consequence = TextEditingController();
      final TextEditingController plan = TextEditingController();
      final TextEditingController other = TextEditingController();
      addTearDown(thought.dispose);
      addTearDown(action.dispose);
      addTearDown(consequence.dispose);
      addTearDown(plan.dispose);
      addTearDown(other.dispose);

      await tester.pumpWidget(
        _host(
          LogCbtReflectionCard(
            isReflectionEntry: true,
            thoughtController: thought,
            actionTakenController: action,
            consequenceController: consequence,
            betterPlanController: plan,
            replacementActions: const <String>[],
            selectedReplacementAction: null,
            onReplacementSelected: (_) {},
            otherReplacementActionController: other,
            showOtherReplacementField: false,
            onOpenRescue: () {},
            onOpenSupport: () {},
          ),
        ),
      );

      expect(find.text('Simple reflection'), findsOneWidget);
      expect(
        find.text(
          'Capture what you noticed and the next choice you want to make.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Add reflection details'));
      await tester.pumpAndSettle();

      expect(
        find.text('Notice the pattern without judging yourself.'),
        findsOneWidget,
      );
      expect(find.text('Thought or pattern noticed'), findsOneWidget);
    },
  );
}
