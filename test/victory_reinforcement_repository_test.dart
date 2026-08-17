import 'package:breakwave/features/log/data/log_repository.dart';
import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  LogEntry entry({
    required String id,
    required String type,
    String replacementAction = '',
  }) {
    return LogEntry(
      id: id,
      entryType: type,
      intensity: 3,
      triggers: const <String>[],
      replacementAction: replacementAction,
      notes: '',
      createdAtIso: '2026-08-17T12:00:00.000',
    );
  }

  test('confirms what helped on the exact Victory ID only', () async {
    const LogRepository repository = LogRepository();

    await repository.saveEntry(entry(id: 'victory-a', type: 'Victory'));
    await repository.saveEntry(entry(id: 'victory-b', type: 'Victory'));
    await repository.saveEntry(entry(id: 'urge-a', type: 'Urge'));

    final bool updated = await repository.confirmVictoryReplacementAction(
      entryId: 'victory-a',
      replacementAction: 'Take a short walk',
    );

    expect(updated, isTrue);

    final List<LogEntry> entries = await repository.loadEntries();
    final Map<String, LogEntry> byId = <String, LogEntry>{
      for (final LogEntry item in entries) item.id: item,
    };

    expect(byId['victory-a']!.replacementAction, 'Take a short walk');
    expect(byId['victory-b']!.replacementAction, isEmpty);
    expect(byId['urge-a']!.replacementAction, isEmpty);

    final bool refusedUrge = await repository.confirmVictoryReplacementAction(
      entryId: 'urge-a',
      replacementAction: 'Put the phone down',
    );

    expect(refusedUrge, isFalse);
    expect(
      (await repository.loadEntries())
          .firstWhere((LogEntry item) => item.id == 'urge-a')
          .replacementAction,
      isEmpty,
    );
  });
}
