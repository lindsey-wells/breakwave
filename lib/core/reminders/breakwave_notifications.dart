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

  static const String notificationIconName =
      'ic_stat_breakwave';
  static const String fallbackNotificationIconName =
      '@mipmap/ic_launcher';

  static bool _initialized = false;
  static bool _timeZoneReady = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimeZone();

    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      fallbackNotificationIconName,
    );

    final InitializationSettings initializationSettings =
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
      await _scheduleWithIconFallback(
        id: dailyReminderId,
        title:
            privacy.discreetNotifications ? 'Check-in' : 'BreakWave check-in',
        body: privacy.discreetNotifications
            ? 'Take a brief pause.'
            : 'Pause for 20 seconds. Open BreakWave and take one steady next step.',
        scheduledDate: _nextInstance(
          settings.dailyHour,
          settings.dailyMinute,
        ),
      );
    }

    if (settings.riskyNudgeEnabled) {
      const String fullBody = 'Danger window. Pause now. Open BreakWave and take one steady next step.';

      await _scheduleWithIconFallback(
        id: riskyNudgeId,
        title: privacy.discreetNotifications ? 'Nudge' : 'BreakWave nudge',
        body: privacy.discreetNotifications ? 'Pause now.' : fullBody,
        scheduledDate: _nextInstance(
          settings.riskyHour,
          settings.riskyMinute,
        ),
      );
    }
  }

  static Future<void> _scheduleWithIconFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      await _schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        useCustomIcon: true,
      );
    } catch (_) {
      await _schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        useCustomIcon: false,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required bool useCustomIcon,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details(
        useCustomIcon: useCustomIcon,
      ),
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static NotificationDetails _details({
    required bool useCustomIcon,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'breakwave_reminders',
        'BreakWave Reminders',
        channelDescription:
            'Daily check-ins and neutral recovery nudges',
        icon: useCustomIcon ? notificationIconName : null,
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
