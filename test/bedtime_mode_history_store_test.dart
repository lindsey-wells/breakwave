import 'dart:convert';

import 'package:breakwave/core/bedtime/bedtime_mode_entry.dart';
import 'package:breakwave/core/bedtime/bedtime_mode_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  String encoded({
    required String dateKey,
    required bool isRisky,
    required String savedAtIso,
  }) {
    return jsonEncode(
      BedtimeModeEntry(
        dateKey: dateKey,
        isRisky: isRisky,
        savedAtIso: savedAtIso,
      ).toMap(),
    );
  }

  test(
    'loadEntries includes legacy single-record bedtime context',
    () async {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        BedtimeModeStore.storageKey,
        encoded(
          dateKey: '2026-08-19',
          isRisky: true,
          savedAtIso: '2026-08-19T22:00:00.000',
        ),
      );

      final List<BedtimeModeEntry> entries =
          await BedtimeModeStore.loadEntries();

      expect(entries, hasLength(1));
      expect(entries.single.dateKey, '2026-08-19');
      expect(entries.single.isRisky, isTrue);
    },
  );

  test(
    'loadEntries keeps one latest entry per date',
    () async {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setStringList(
        BedtimeModeStore.historyStorageKey,
        <String>[
          encoded(
            dateKey: '2026-08-18',
            isRisky: false,
            savedAtIso: '2026-08-18T21:00:00.000',
          ),
          encoded(
            dateKey: '2026-08-18',
            isRisky: true,
            savedAtIso: '2026-08-18T23:00:00.000',
          ),
          encoded(
            dateKey: '2026-08-17',
            isRisky: false,
            savedAtIso: '2026-08-17T22:00:00.000',
          ),
        ],
      );

      final List<BedtimeModeEntry> entries =
          await BedtimeModeStore.loadEntries();

      expect(entries, hasLength(2));
      expect(entries.first.dateKey, '2026-08-18');
      expect(entries.first.isRisky, isTrue);
      expect(entries.last.dateKey, '2026-08-17');
    },
  );

  test(
    'saveTodayRisk preserves previous legacy night before replacement',
    () async {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        BedtimeModeStore.storageKey,
        encoded(
          dateKey: '2000-01-01',
          isRisky: true,
          savedAtIso: '2000-01-01T22:00:00.000',
        ),
      );

      await BedtimeModeStore.saveTodayRisk(false);

      final List<BedtimeModeEntry> entries =
          await BedtimeModeStore.loadEntries();

      expect(
        entries.any(
          (BedtimeModeEntry item) =>
              item.dateKey == '2000-01-01' &&
              item.isRisky,
        ),
        isTrue,
      );

      final BedtimeModeEntry? today =
          await BedtimeModeStore.loadTodayEntry();
      expect(today, isNotNull);
      expect(today!.isRisky, isFalse);
    },
  );

  test(
    'saveTodayRisk retains original current-night storage contract',
    () async {
      await BedtimeModeStore.saveTodayRisk(true);

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();
      final String? raw =
          prefs.getString(BedtimeModeStore.storageKey);

      expect(raw, isNotNull);

      final BedtimeModeEntry current =
          BedtimeModeEntry.fromMap(
        Map<String, dynamic>.from(
          jsonDecode(raw!) as Map,
        ),
      );

      expect(current.dateKey, BedtimeModeStore.todayKey());
      expect(current.isRisky, isTrue);
    },
  );

  test(
    'clear removes current-night and bedtime-history storage',
    () async {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        BedtimeModeStore.storageKey,
        encoded(
          dateKey: '2026-08-19',
          isRisky: true,
          savedAtIso: '2026-08-19T22:00:00.000',
        ),
      );
      await prefs.setStringList(
        BedtimeModeStore.historyStorageKey,
        <String>[
          encoded(
            dateKey: '2026-08-19',
            isRisky: true,
            savedAtIso: '2026-08-19T22:00:00.000',
          ),
        ],
      );

      await BedtimeModeStore.clear();

      expect(
        prefs.getString(BedtimeModeStore.storageKey),
        isNull,
      );
      expect(
        prefs.getStringList(BedtimeModeStore.historyStorageKey),
        isNull,
      );
    },
  );
}
