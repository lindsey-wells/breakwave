// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_check_in_card.dart
// Purpose: BW-19 daily check-in and control signal card.
// Notes: Home-level daily recovery check-in focused on engagement, not perfection.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/checkin/daily_check_in_entry.dart';
import '../../../core/checkin/daily_check_in_store.dart';

class DailyCheckInCard extends StatefulWidget {
  const DailyCheckInCard({super.key});

  @override
  State<DailyCheckInCard> createState() => _DailyCheckInCardState();
}

class _DailyCheckInCardState extends State<DailyCheckInCard> {
  static const List<String> _statuses = <String>[
    'Steady',
    'Vulnerable',
    'Fought through',
    'Slipped',
  ];

  bool _loading = true;
  bool _saving = false;
  String? _todayStatus;
  int _recentCheckInCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final DailyCheckInEntry? todayEntry = await DailyCheckInStore.loadTodayEntry();
    final List<DailyCheckInEntry> entries = await DailyCheckInStore.loadEntries();

    if (!mounted) return;

    setState(() {
      _todayStatus = todayEntry?.status;
      _recentCheckInCount = _countRecentEntries(entries, days: 7);
      _loading = false;
    });
  }

  int _countRecentEntries(List<DailyCheckInEntry> entries, {required int days}) {
    final DateTime now = DateTime.now();
    final Set<String> validKeys = <String>{};

    for (int i = 0; i < days; i += 1) {
      validKeys.add(DailyCheckInStore.dateKeyFor(now.subtract(Duration(days: i))));
    }

    return entries.where((DailyCheckInEntry entry) => validKeys.contains(entry.dateKey)).length;
  }

  String _controlSignalText() {
    if (_recentCheckInCount == 0) {
      return 'Control signal: no recent check-ins yet. Start with honesty today.';
    }
    if (_recentCheckInCount <= 2) {
      return 'Control signal: re-engaging. Showing up still counts.';
    }
    if (_recentCheckInCount <= 4) {
      return 'Control signal: staying connected. Daily contact is helping.';
    }
    return 'Control signal: building steadier control through repeated check-ins.';
  }

  Future<void> _saveStatus(String status) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await DailyCheckInStore.saveTodayStatus(status);
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved today as: $status'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save today\'s check-in right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily check-in',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _todayStatus == null
                      ? 'How would you describe today so far?'
                      : 'Today: $_todayStatus',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _controlSignalText(),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _statuses.map((String status) {
                    return ChoiceChip(
                      label: Text(status),
                      selected: _todayStatus == status,
                      onSelected: _saving
                          ? null
                          : (bool selected) {
                              if (!selected) return;
                              _saveStatus(status);
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
