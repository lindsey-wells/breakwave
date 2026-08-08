// BW-22 verifier copy contract:
// Daily check-in reminder
// Risky-time nudge
// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: reminder_settings_card.dart
// Purpose: BW-22 reminder settings card.
// Notes: BW-34 hardens reminder save feedback and permission handling.
// Notes: BW-86B3 adds saved-state clarity and stronger reminder copy.
// Notes: BW-86B4 improves reminder time picker contrast and timing clarity.
// Notes: BW-NOTIFY-01A adds test delivery and reminder-readiness feedback.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/reminders/android_notification_settings.dart';
import '../../../../core/reminders/breakwave_notifications.dart';
import '../../../../core/reminders/notification_readiness.dart';
import '../../../../core/reminders/notification_reliability.dart';
import '../../../../core/reminders/reminder_settings.dart';
import '../../../../core/reminders/reminder_settings_store.dart';
import '../../../../core/triggers/triggers_selection.dart';
import '../../../../core/triggers/triggers_store.dart';

class ReminderSettingsCard extends StatefulWidget {
  const ReminderSettingsCard({
    super.key,
    this.readinessLoader,
    this.testNotificationSender,
    this.reliabilityProofScheduler,
    this.notificationSettingsOpener,
    this.appSettingsOpener,
    this.exactAlarmRequester,
    this.exactAlarmRescheduler,
  });

  final Future<NotificationReadiness> Function()? readinessLoader;
  final Future<TestNotificationResult> Function()? testNotificationSender;
  final Future<ScheduledProofResult> Function()? reliabilityProofScheduler;
  final Future<bool> Function()? notificationSettingsOpener;
  final Future<bool> Function()? appSettingsOpener;
  final Future<bool> Function()? exactAlarmRequester;
  final Future<bool> Function()? exactAlarmRescheduler;

  @override
  State<ReminderSettingsCard> createState() =>
      _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends State<ReminderSettingsCard> {
  bool _loading = true;
  bool _saving = false;
  bool _readinessLoading = false;
  bool _testingNotification = false;
  bool _schedulingProof = false;
  bool _openingNotificationSettings = false;
  bool _openingAppSettings = false;
  bool _requestingExactAlarm = false;

  ReminderSettings _settings = ReminderSettings.defaults;
  TriggersSelection _triggers = TriggersSelection.empty;
  NotificationReadiness? _readiness;

  String? _savedStatusMessage;
  String? _lastRefreshStatus;
  String? _testStatusMessage;
  bool _testStatusSuccess = false;
  String? _proofStatusMessage;
  bool _proofStatusSuccess = false;
  String? _exactAlarmStatusMessage;
  bool _exactAlarmStatusSuccess = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ReminderSettings settings = await ReminderSettingsStore.load();
    final TriggersSelection triggers =
        await TriggersStore.loadSelection();

    if (!mounted) return;

    setState(() {
      _settings = settings;
      _triggers = triggers;
      _loading = false;
    });

    await _refreshReadiness(showLoading: false);
  }

  Future<void> _refreshReadiness({
    bool showLoading = true,
  }) async {
    if (_readinessLoading) return;

    if (showLoading && mounted) {
      setState(() {
        _readinessLoading = true;
      });
    }

    NotificationReadiness readiness;
    try {
      final loader =
          widget.readinessLoader ?? BreakWaveNotifications.readReadiness;
      readiness = await loader();
    } catch (_) {
      readiness = const NotificationReadiness(
        initialized: false,
        timeZoneReady: false,
        timeZoneIdentifier: null,
        permissionStatus: NotificationPermissionStatus.unavailable,
        errorMessage: 'Unable to read notification readiness.',
      );
    }

    if (!mounted) return;

    setState(() {
      _readiness = readiness;
      _readinessLoading = false;
    });
  }

  Future<void> _sendTestNotification() async {
    if (_testingNotification) return;

    setState(() {
      _testingNotification = true;
      _testStatusMessage = null;
    });

    TestNotificationResult result;
    try {
      final sender = widget.testNotificationSender ??
          BreakWaveNotifications.sendTestNotification;
      result = await sender();
    } catch (_) {
      result = TestNotificationResult(
        outcome: TestNotificationOutcome.failed,
        readiness: _readiness ??
            const NotificationReadiness(
              initialized: false,
              timeZoneReady: false,
              timeZoneIdentifier: null,
              permissionStatus:
                  NotificationPermissionStatus.unavailable,
            ),
      );
    }

    if (!mounted) return;

    final String message;
    final bool success;

    switch (result.outcome) {
      case TestNotificationOutcome.shown:
        message =
            'Test notification sent. Check your notification shade.';
        success = true;
      case TestNotificationOutcome.permissionDenied:
        message =
            'Notifications are turned off. Allow them in Android settings, then try again.';
        success = false;
      case TestNotificationOutcome.unavailable:
        message =
            'Notification status is unavailable on this device.';
        success = false;
      case TestNotificationOutcome.failed:
        message = 'Unable to send a test notification right now.';
        success = false;
    }

    setState(() {
      _readiness = result.readiness;
      _testingNotification = false;
      _testStatusMessage = message;
      _testStatusSuccess = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _requestExactAlarmAccess() async {
    if (_requestingExactAlarm) return;

    setState(() {
      _requestingExactAlarm = true;
      _exactAlarmStatusMessage = null;
    });

    bool granted = false;
    bool refreshed = false;
    try {
      final requester = widget.exactAlarmRequester ??
          BreakWaveNotifications.requestExactAlarmAccess;
      granted = await requester();

      if (granted) {
        final refresher = widget.exactAlarmRescheduler ??
            () => BreakWaveNotifications.safeRescheduleAll(
                  settings: _settings,
                  triggersSelection: _triggers,
                );
        refreshed = await refresher();
      }
    } catch (_) {
      granted = false;
      refreshed = false;
    }

    if (!mounted) return;

    final String message;
    if (granted && refreshed) {
      message =
          'Precise timing allowed. Saved reminders were refreshed.';
    } else if (granted) {
      message =
          'Precise timing allowed. Reminder refresh may need another try.';
    } else {
      message =
          'Precise timing was not enabled. BreakWave will keep using standard Android scheduling.';
    }

    setState(() {
      _requestingExactAlarm = false;
      _exactAlarmStatusMessage = message;
      _exactAlarmStatusSuccess = granted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _scheduleReliabilityProof() async {
    if (_schedulingProof) return;

    setState(() {
      _schedulingProof = true;
      _proofStatusMessage = null;
    });

    ScheduledProofResult result;
    try {
      final scheduler = widget.reliabilityProofScheduler ??
          BreakWaveNotifications.scheduleReliabilityProof;
      result = await scheduler();
    } catch (_) {
      result = ScheduledProofResult(
        outcome: ScheduledProofOutcome.failed,
        readiness: _readiness ??
            const NotificationReadiness(
              initialized: false,
              timeZoneReady: false,
              timeZoneIdentifier: null,
              permissionStatus:
                  NotificationPermissionStatus.unavailable,
            ),
      );
    }

    if (!mounted) return;

    final String message;
    final bool success;
    switch (result.outcome) {
      case ScheduledProofOutcome.scheduled:
        final DateTime? scheduledFor = result.scheduledFor;
        final String target = scheduledFor == null
            ? 'about 5 minutes from now'
            : TimeOfDay.fromDateTime(scheduledFor).format(context);
        message =
            'Scheduled check set for about $target. Lock or background BreakWave and watch for it. Android may deliver it later.';
        success = true;
      case ScheduledProofOutcome.permissionDenied:
        message =
            'Notifications are turned off. Open Android notification settings, allow them, then schedule the check again.';
        success = false;
      case ScheduledProofOutcome.unavailable:
        message =
            'Scheduled delivery status is unavailable on this device right now.';
        success = false;
      case ScheduledProofOutcome.failed:
        message = 'Unable to schedule the delivery check right now.';
        success = false;
    }

    setState(() {
      _readiness = result.readiness;
      _schedulingProof = false;
      _proofStatusMessage = message;
      _proofStatusSuccess = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openNotificationSettings() async {
    if (_openingNotificationSettings) return;
    setState(() {
      _openingNotificationSettings = true;
    });

    final opener = widget.notificationSettingsOpener ??
        AndroidNotificationSettings.openNotificationSettings;
    final bool opened = await opener();

    if (!mounted) return;
    setState(() {
      _openingNotificationSettings = false;
    });

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open Android notification settings on this device.',
          ),
        ),
      );
    }
  }

  Future<void> _openAppSettings() async {
    if (_openingAppSettings) return;
    setState(() {
      _openingAppSettings = true;
    });

    final opener =
        widget.appSettingsOpener ?? AndroidNotificationSettings.openAppSettings;
    final bool opened = await opener();

    if (!mounted) return;
    setState(() {
      _openingAppSettings = false;
    });

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open Android app settings on this device.',
          ),
        ),
      );
    }
  }

  String _timeText(int hour, int minute) {
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Future<TimeOfDay?> _showBreakWaveTimePicker({
    required TimeOfDay initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: helpText,
      builder: (BuildContext context, Widget? child) {
        final ThemeData theme = Theme.of(context);
        final ColorScheme colorScheme = theme.colorScheme;

        return Theme(
          data: theme.copyWith(
            textSelectionTheme: theme.textSelectionTheme.copyWith(
              cursorColor: colorScheme.primary,
              selectionColor: colorScheme.primaryContainer,
              selectionHandleColor: colorScheme.primary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
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

    return preview.isEmpty
        ? 'No watch-for patterns saved yet.'
        : preview.join(' • ');
  }

  void _clearSavedStatus() {
    if (_savedStatusMessage != null) {
      _savedStatusMessage = null;
    }
  }

  Future<void> _pickDailyTime() async {
    final TimeOfDay? picked = await _showBreakWaveTimePicker(
      initialTime: TimeOfDay(
        hour: _settings.dailyHour,
        minute: _settings.dailyMinute,
      ),
      helpText: 'Choose daily check-in time',
    );

    if (picked == null) return;

    setState(() {
      _clearSavedStatus();
      _settings = _settings.copyWith(
        dailyHour: picked.hour,
        dailyMinute: picked.minute,
      );
    });
  }

  Future<void> _pickRiskyTime() async {
    final TimeOfDay? picked = await _showBreakWaveTimePicker(
      initialTime: TimeOfDay(
        hour: _settings.riskyHour,
        minute: _settings.riskyMinute,
      ),
      helpText: 'Choose watch-for nudge time',
    );

    if (picked == null) return;

    setState(() {
      _clearSavedStatus();
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
          _settings.dailyReminderEnabled ||
              _settings.riskyNudgeEnabled;

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

      setState(() {
        _lastRefreshStatus = permissionOk && rescheduled
            ? 'Completed this session'
            : 'Needs another try';
        _savedStatusMessage = message == 'Reminder settings saved.'
            ? 'Reminder settings saved. Daily check-ins and watch-for nudges will use the times you chose.'
            : '$message Android may still delay delivery if battery saver is active.';
      });

      await _refreshReadiness(showLoading: false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _lastRefreshStatus = 'Needs another try';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Unable to save reminder settings right now.'),
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

  Widget _readinessRow({
    required String label,
    required String value,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readinessPanel() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final NotificationReadiness? readiness = _readiness;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Notification readiness',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_readinessLoading && readiness == null) ...<Widget>[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ] else ...<Widget>[
            _readinessRow(
              label: 'Notification service',
              value: readiness?.serviceLabel ?? 'Checking',
            ),
            _readinessRow(
              label: 'Permission',
              value: readiness?.permissionLabel ?? 'Checking',
            ),
            _readinessRow(
              label: 'Device time zone',
              value: readiness?.timeZoneLabel ?? 'Checking',
            ),
            _readinessRow(
              label: 'Daily check-in',
              value: _settings.dailyReminderEnabled
                  ? _timeText(
                      _settings.dailyHour,
                      _settings.dailyMinute,
                    )
                  : 'Off',
            ),
            _readinessRow(
              label: 'Watch-for nudge',
              value: _settings.riskyNudgeEnabled
                  ? _timeText(
                      _settings.riskyHour,
                      _settings.riskyMinute,
                    )
                  : 'Off',
            ),
            _readinessRow(
              label: 'Last schedule refresh',
              value: _lastRefreshStatus ?? 'Not checked this session',
            ),
          ],
          if (readiness?.errorMessage != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              readiness!.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'A test checks immediate delivery only. Android may still delay scheduled reminders because of battery or background limits.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                key: const Key('notification-readiness-refresh'),
                onPressed: _readinessLoading
                    ? null
                    : () => _refreshReadiness(),
                icon: const Icon(Icons.refresh),
                label: Text(
                  _readinessLoading ? 'Checking...' : 'Refresh status',
                ),
              ),
              FilledButton.tonalIcon(
                key: const Key('notification-test-send'),
                onPressed: _testingNotification
                    ? null
                    : _sendTestNotification,
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(
                  _testingNotification
                      ? 'Sending...'
                      : 'Send test notification',
                ),
              ),
            ],
          ),
          if (_testStatusMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              key: const Key('notification-test-status'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testStatusSuccess
                    ? colorScheme.primaryContainer.withOpacity(0.35)
                    : colorScheme.errorContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _testStatusMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 14),
          const SizedBox(height: 18),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 14),
          Text(
            'Precise reminder timing',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Android can give BreakWave special Alarms & reminders access. When allowed, BreakWave can use exact timing designed to fire during low-power idle. If you leave it off, reminders continue with standard Android scheduling.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This improves reminder timing but does not override every manufacturer battery restriction.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            key: const Key('notification-exact-alarm-request'),
            onPressed:
                _requestingExactAlarm ? null : _requestExactAlarmAccess,
            icon: const Icon(Icons.alarm_on_outlined),
            label: Text(
              _requestingExactAlarm
                  ? 'Opening Android settings...'
                  : 'Allow precise timing',
            ),
          ),
          if (_exactAlarmStatusMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              key: const Key('notification-exact-alarm-status'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _exactAlarmStatusSuccess
                    ? colorScheme.primaryContainer.withOpacity(0.35)
                    : colorScheme.errorContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _exactAlarmStatusMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          Text(
            'Scheduled delivery proof',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule one private check for about 5 minutes from now. Then lock or background BreakWave and watch for it. This does not change your saved reminder times.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            key: const Key('notification-proof-schedule'),
            onPressed:
                _schedulingProof ? null : _scheduleReliabilityProof,
            icon: const Icon(Icons.schedule_send_outlined),
            label: Text(
              _schedulingProof
                  ? 'Scheduling...'
                  : 'Schedule 5-minute check',
            ),
          ),
          if (_proofStatusMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              key: const Key('notification-proof-status'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _proofStatusSuccess
                    ? colorScheme.primaryContainer.withOpacity(0.35)
                    : colorScheme.errorContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _proofStatusMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Restart/update proof: schedule the check, then restart the phone or reinstall/update BreakWave before it arrives. The check should still arrive, although Android may delay it.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Android delivery controls',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BreakWave is configured to restore scheduled reminders after a phone restart or app update. Android can still delay them because of battery or background limits.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                key: const Key('notification-settings-open'),
                onPressed: _openingNotificationSettings
                    ? null
                    : _openNotificationSettings,
                icon: const Icon(Icons.notifications_outlined),
                label: Text(
                  _openingNotificationSettings
                      ? 'Opening...'
                      : 'Notification settings',
                ),
              ),
              OutlinedButton.icon(
                key: const Key('app-settings-open'),
                onPressed:
                    _openingAppSettings ? null : _openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: Text(
                  _openingAppSettings
                      ? 'Opening...'
                      : 'App settings',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'For battery controls, open App settings and review Battery/background use as your Android version allows. Use Allow precise timing above when exact reminder delivery matters.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest.withOpacity(0.45),
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
                  'Use a daily check-in and one watch-for nudge around the times you choose.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily check-in reminder'),
                    subtitle: Text(
                      _timeText(
                        _settings.dailyHour,
                        _settings.dailyMinute,
                      ),
                    ),
                    value: _settings.dailyReminderEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _clearSavedStatus();
                        _settings = _settings.copyWith(
                          dailyReminderEnabled: value,
                        );
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _pickDailyTime,
                    child:
                        const Text('Choose daily check-in time'),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Watch-for nudge'),
                    subtitle: Text(
                      _timeText(
                        _settings.riskyHour,
                        _settings.riskyMinute,
                      ),
                    ),
                    value: _settings.riskyNudgeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _clearSavedStatus();
                        _settings = _settings.copyWith(
                          riskyNudgeEnabled: value,
                        );
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _pickRiskyTime,
                    child:
                        const Text('Choose risky-time nudge time'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Watch-for preview: ${_watchPreview()}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Android may delay scheduled reminders slightly when Battery Saver or background limits are active.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                _readinessPanel(),
                if (_savedStatusMessage != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer
                          .withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: colorScheme.primary),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.check_circle_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _savedStatusMessage!,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _saving
                          ? 'Saving...'
                          : _savedStatusMessage == null
                              ? 'Save reminder settings'
                              : 'Saved reminder settings',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
