#!/usr/bin/env python3
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parent.parent

store_path = ROOT / 'lib/core/bedtime/bedtime_mode_store.dart'
entry_path = ROOT / 'lib/core/bedtime/bedtime_mode_entry.dart'
card_path = (
    ROOT
    / 'lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart'
)
home_path = ROOT / 'lib/features/home/presentation/home_screen.dart'
widget_path = ROOT / 'lib/core/widget/home_widget_sync.dart'
pattern_path = (
    ROOT
    / 'lib/features/patterns/domain/pattern_observation_engine.dart'
)
daily_context_path = (
    ROOT
    / 'lib/features/patterns/domain/daily_context_observation_engine.dart'
)
test_path = ROOT / 'test/bedtime_mode_history_store_test.dart'

for path in (
    store_path,
    entry_path,
    card_path,
    home_path,
    widget_path,
    pattern_path,
    daily_context_path,
    test_path,
):
    if not path.is_file():
        print(
            f'FAIL BW-89A8A missing file: {path.relative_to(ROOT)}'
        )
        sys.exit(1)

store = store_path.read_text(encoding='utf-8')
card = card_path.read_text(encoding='utf-8')
home = home_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')

for needle in (
    "static const String storageKey = 'bw_bedtime_mode_v1';",
    "static const String historyStorageKey = 'bw_bedtime_mode_history_v1';",
    'static Future<BedtimeModeEntry?> loadTodayEntry()',
    'static Future<List<BedtimeModeEntry>> loadEntries()',
    'static Future<void> saveTodayRisk(bool isRisky)',
    'prefs.getString(storageKey)',
    'prefs.setString(storageKey, jsonEncode(entry.toMap()))',
    'prefs.getStringList(historyStorageKey)',
    'prefs.setStringList(',
    'historyStorageKey,',
    'historyByDate[entry.dateKey] = entry;',
    'Migrate/preserve the previous single-record value before replacing it.',
    'await prefs.remove(storageKey);',
    'await prefs.remove(historyStorageKey);',
):
    if needle not in store:
        print(f'FAIL BW-89A8A storage contract missing: {needle}')
        sys.exit(1)

for needle in (
    'loadEntries includes legacy single-record bedtime context',
    'loadEntries keeps one latest entry per date',
    'saveTodayRisk preserves previous legacy night before replacement',
    'saveTodayRisk retains original current-night storage contract',
    'clear removes current-night and bedtime-history storage',
):
    if needle not in tests:
        print(f'FAIL BW-89A8A regression test missing: {needle}')
        sys.exit(1)

# Bedtime card successor presentation boundary inherited from BW-89A8B.
for needle in (
    'BedtimeModeStore.loadTodayEntry()',
    'BedtimeModeStore.saveTodayRisk(isRisky)',
    'BreakWaveHomeWidgetSync.sync()',
    "label: const Text('Tonight feels steady')",
    '_save(false);',
    "label: const Text('Tonight feels risky')",
    '_save(true);',
    'onPressed: widget.onOpenRescue',
    "Text('Open Rescue now')",
    "'Saved bedtime risk for tonight.'",
    "'Saved tonight as steady.'",
    "'Unable to save bedtime mode right now.'",
    'RecoveryMode.christian',
):
    if needle not in card:
        print(
            f'FAIL BW-89A8A bedtime control compatibility missing: {needle}'
        )
        sys.exit(1)

steady_index = card.find("label: const Text('Tonight feels steady')")
risky_index = card.find("label: const Text('Tonight feels risky')")
rescue_callback_index = card.find('onPressed: widget.onOpenRescue')
rescue_text_index = card.find("Text('Open Rescue now')")
if not (
    -1 < steady_index
    < risky_index
    < rescue_callback_index
    < rescue_text_index
):
    print(
        'FAIL BW-89A8A bedtime control order changed unexpectedly'
    )
    sys.exit(1)

# A8A's former whole-file Home SHA was broader than its actual ownership.
# Preserve the Home behavior A8A needs semantically so later Home presentation
# work can evolve without disabling Bedtime Danger Mode.
for needle in (
    "import 'widgets/bedtime_danger_mode_card.dart';",
    'BedtimeDangerModeCard(',
    'onOpenRescue: widget.onOpenRescue,',
):
    if needle not in home:
        print(
            f'FAIL BW-89A8A Home bedtime integration missing: {needle}'
        )
        sys.exit(1)

bedtime_import_index = home.find(
    "import 'widgets/bedtime_danger_mode_card.dart';"
)
bedtime_card_index = home.find('BedtimeDangerModeCard(')
bedtime_rescue_index = home.find(
    'onOpenRescue: widget.onOpenRescue,',
    bedtime_card_index,
)
if not (
    -1 < bedtime_import_index
    and -1 < bedtime_card_index < bedtime_rescue_index
):
    print(
        'FAIL BW-89A8A Home bedtime integration ordering changed'
    )
    sys.exit(1)

# Foundation-owned protected surfaces remain exact.
# home_screen.dart is intentionally NOT hash-pinned here; its A8A-owned
# semantics are asserted above.
protected = {
    'lib/core/bedtime/bedtime_mode_entry.dart':
        'cb11e965909d597363e832d2b3270264f516f1a85ae46e95972bb3542b578526',
    'lib/core/widget/home_widget_sync.dart':
        '76f2f816cb93b9ad352208cb0a34050c41e941c1ba1a95c16a392441871e87f6',
    'lib/features/patterns/domain/pattern_observation_engine.dart':
        'df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f',
    'lib/features/patterns/domain/daily_context_observation_engine.dart':
        '97dad84b8e222aec873631f26c4e7e9311ffae5c440c477e0033c6befb0b2fba',
}

for rel, expected in protected.items():
    actual = hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
    if actual != expected:
        print(
            f'FAIL BW-89A8A protected foundation drift: {rel} '
            f'expected {expected} got {actual}'
        )
        sys.exit(1)

for forbidden in (
    'LogEntry',
    'LogRepository',
    'PatternObservationEngine(',
    'DailyContextObservationEngine(',
    'BreakWaveAccessPolicy',
    'billing',
    'cloud',
):
    if forbidden in store:
        print(
            f'FAIL BW-89A8A bedtime history store has forbidden coupling: '
            f'{forbidden}'
        )
        sys.exit(1)

print(
    'PASS: BW-89A8A Bedtime History Foundation verified — '
    'history/current-night storage, bedtime controls, and Home Rescue wiring '
    'remain intact under the BW-89A9 successor Home presentation boundary.'
)
