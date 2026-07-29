// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry_visual_identity_test.dart
// Purpose: BW-LOG-01A visual identity widget coverage.
// ------------------------------------------------------------

import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/log/presentation/widgets/log_entry_type_section.dart';
import 'package:breakwave/features/log/presentation/widgets/recent_log_entries_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'entry selector gives Urge Slip and Victory distinct icons',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          LogEntryTypeSection(
            selectedType: 'Urge',
            onSelected: (_) {},
          ),
        ),
      );

      expect(
        find.byKey(
          const ValueKey<String>('log-entry-type-Urge'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('log-entry-type-Slip'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('log-entry-type-Victory'),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
      expect(
        find.byIcon(Icons.warning_amber_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.emoji_events_rounded),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'recent entry shows a type badge and five intensity dots',
    (WidgetTester tester) async {
      const LogEntry entry = LogEntry(
        id: 'entry-1',
        entryType: 'Urge',
        intensity: 3,
        triggers: <String>['Stress'],
        notes: '',
        createdAtIso: '2026-07-29T19:00:00.000',
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
          const ValueKey<String>('log-entry-badge-urge'),
        ),
        findsOneWidget,
      );
      expect(find.text('Intensity 3'), findsOneWidget);

      for (int value = 1; value <= 3; value++) {
        expect(
          find.byKey(
            ValueKey<String>(
              'log-intensity-dot-entry-1-$value-filled',
            ),
          ),
          findsOneWidget,
        );
      }

      for (int value = 4; value <= 5; value++) {
        expect(
          find.byKey(
            ValueKey<String>(
              'log-intensity-dot-entry-1-$value-empty',
            ),
          ),
          findsOneWidget,
        );
      }
    },
  );
}
