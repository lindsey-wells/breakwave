// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: reminder_settings_card.dart
// Purpose: BW-22 reminder settings card.
// Notes: BW-34 hardens reminder save feedback and permission handling.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/reminders/breakwave_notifications.dart';
import '../../../../core/reminders/reminder_settings.dart';
import '../../../../core/reminders/reminder_settings_store.dart';
import '../../../../core/triggers/triggers_selection.dart';
import '../../../../core/triggers/triggers_store.dart';

class ReminderSettingsCard extends StatefulWidget {
  const ReminderSettingsCard({super.key});

  @override
  State<ReminderSettingsCard> createState() => _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends State<ReminderSettingsCard> {
  bool _loading = true;
  bool _saving = false;
  ReminderSettings _settings = ReminderSettings.defaults;
  TriggersSelection _triggers = TriggersSelection.empty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ReminderSettings settings = await ReminderSettingsStore.load();
    final TriggersSelection triggers = await TriggersStore.loadSelection();

    if (!mounted) return;

    setState(() {
      _settings = settings;
      _triggers = triggers;
      _loading = false;
    });
  }

  String _timeText(int hour, int minute) {
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  String _watchPreview() {
    final List<String> preview = <String>[];
    for (final String item in <String>[
      ..._triggers.selectedTriggers,
      ..._triggers.selectedRiskyTimes,
    ]) {
      if (!preview.contains(item)) {
        preview.add(item);
      }
      if (preview.length == 3) break;
    }

    return preview.isEmpty ? 'No watch-for patterns saved yet.' : preview.join(' • ');
  }

  Future<void> _pickDailyTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.dailyHour,
        minute: _settings.dailyMinute,
      ),
    );

    if (picked == null) return;

    setState(() {
      _settings = _settings.copyWith(
        dailyHour: picked.hour,
        dailyMinute: picked.minute,
      );
    });
  }

  Future<void> _pickRiskyTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.riskyHour,
        minute: _settings.riskyMinute,
      ),
    );

    if (picked == null) return;

    setState(() {
      _settings = _settings.copyWith(
        riskyHour: picked.hour,
        riskyMinute: picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await ReminderSettingsStore.save(_settings);

      final bool wantsNotifications =
          _settings.dailyReminderEnabled || _settings.riskyNudgeEnabled;

      final bool permissionOk = wantsNotifications
          ? await BreakWaveNotifications.safeRequestPermissions()
          : true;

      final bool rescheduled = await BreakWaveNotifications.safeRescheduleAll(
        settings: _settings,
        triggersSelection: _triggers,
      );

      if (!mounted) return;

      final String message;
      if (permissionOk && rescheduled) {
        message = 'Reminder settings saved.';
      } else if (!permissionOk && rescheduled) {
        message =
            'Reminder settings saved locally. Notification permission may still be needed.';
      } else if (permissionOk && !rescheduled) {
        message =
            'Reminder settings saved locally. Notification refresh may need another try.';
      } else {
        message =
            'Reminder settings saved locally. Notification permission or refresh may need another try.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save reminder settings right now.'),
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
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reminders and nudges',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Use a daily check-in reminder and one watch-for nudge time to get help before the wave gets louder.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily check-in reminder'),
                  subtitle: Text(_timeText(_settings.dailyHour, _settings.dailyMinute)),
                  value: _settings.dailyReminderEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(dailyReminderEnabled: value);
                    });
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _pickDailyTime,
                    child: const Text('Choose daily reminder time'),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Risky-time nudge'),
                  subtitle: Text(_timeText(_settings.riskyHour, _settings.riskyMinute)),
                  value: _settings.riskyNudgeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(riskyNudgeEnabled: value);
                    });
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _pickRiskyTime,
                    child: const Text('Choose risky-time nudge time'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Watch-for preview: ${_watchPreview()}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save reminder settings'),
                  ),
                ),
              ],
            ),
    );
  }
}
