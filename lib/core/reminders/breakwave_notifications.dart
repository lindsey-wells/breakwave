// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_notifications.dart
// Purpose: BW-22 local reminders and risky-time nudges.
// Notes: Schedules local notifications for daily check-in and risky-time support.
// ------------------------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../triggers/triggers_selection.dart';
import 'reminder_settings.dart';

class BreakWaveNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 2201;
  static const int riskyNudgeId = 2202;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    } catch (_) {
      // Leave tz.local as-is if timezone lookup fails.
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initializationSettings,
    );

    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> rescheduleAll({
    required ReminderSettings settings,
    required TriggersSelection triggersSelection,
  }) async {
    await initialize();

    await _plugin.cancel(id: dailyReminderId);
    await _plugin.cancel(id: riskyNudgeId);

    if (settings.dailyReminderEnabled) {
      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: 'BreakWave check-in',
        body: 'Take 20 seconds to name today honestly.',
        scheduledDate: _nextInstance(settings.dailyHour, settings.dailyMinute),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (settings.riskyNudgeEnabled) {
      final List<String> preview = <String>[];
      for (final String item in <String>[
        ...triggersSelection.selectedTriggers,
        ...triggersSelection.selectedRiskyTimes,
      ]) {
        if (!preview.contains(item)) {
          preview.add(item);
        }
        if (preview.length == 2) break;
      }

      final String body = preview.isEmpty
          ? 'Protect the next stretch before the wave rises.'
          : 'Watch for ${preview.join(' • ')}. Protect the next stretch early.';

      await _plugin.zonedSchedule(
        id: riskyNudgeId,
        title: 'BreakWave watch-for nudge',
        body: body,
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
        channelDescription: 'Daily check-ins and risky-time nudges',
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
