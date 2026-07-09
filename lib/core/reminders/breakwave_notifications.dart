// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_notifications.dart
// Purpose: BW-22/BW-24 local reminders and risky-time nudges.
// Notes: BW-75A hardens local notification permissions, timezone handling,
// and neutral reminder copy without making reminders exact alarms.
// Notes: BW-86B3 strengthens check-in and danger-window nudge copy.
// ------------------------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../privacy/privacy_settings.dart';
import '../privacy/privacy_settings_store.dart';
import '../triggers/triggers_selection.dart';
import 'reminder_settings.dart';

class BreakWaveNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 2201;
  static const int riskyNudgeId = 2202;

  static bool _initialized = false;
  static bool _timeZoneReady = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initializationSettings,
    );

    _initialized = true;
  }

  static Future<void> _configureLocalTimeZone() async {
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
      _timeZoneReady = true;
    } catch (_) {
      _timeZoneReady = false;
    }
  }

  static Future<bool> safeInitialize() async {
    try {
      await initialize();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestPermissions() async {
    await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<bool> safeRequestPermissions() async {
    try {
      await initialize();

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> safeRescheduleAll({
    required ReminderSettings settings,
    required TriggersSelection triggersSelection,
  }) async {
    try {
      await rescheduleAll(
        settings: settings,
        triggersSelection: triggersSelection,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> rescheduleAll({
    required ReminderSettings settings,
    required TriggersSelection triggersSelection,
  }) async {
    await initialize();

    if (!_timeZoneReady) {
      await _configureLocalTimeZone();
    }

    if (!_timeZoneReady) {
      throw StateError('Unable to read device timezone for reminders.');
    }

    final PrivacySettings privacy = await PrivacySettingsStore.load();

    await _plugin.cancel(id: dailyReminderId);
    await _plugin.cancel(id: riskyNudgeId);

    if (settings.dailyReminderEnabled) {
      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title:
            privacy.discreetNotifications ? 'Check-in' : 'BreakWave check-in',
        body: privacy.discreetNotifications
            ? 'Take a brief pause.'
            : 'Pause for 20 seconds. Open BreakWave and choose one clean next step.',
        scheduledDate: _nextInstance(settings.dailyHour, settings.dailyMinute),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (settings.riskyNudgeEnabled) {
      const String fullBody = 'Danger window. Pause now. Open BreakWave and choose one clean next step.';

      await _plugin.zonedSchedule(
        id: riskyNudgeId,
        title: privacy.discreetNotifications ? 'Nudge' : 'BreakWave nudge',
        body: privacy.discreetNotifications ? 'Pause now.' : fullBody,
        scheduledDate: _nextInstance(settings.riskyHour, settings.riskyMinute),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'breakwave_reminders',
        'BreakWave Reminders',
        channelDescription: 'Daily check-ins and neutral recovery nudges',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
