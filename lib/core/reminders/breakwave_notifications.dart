// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_notifications.dart
// Purpose: BW-22/BW-24 local reminders and risky-time nudges.
// Notes: BW-75A hardens local notification permissions, timezone handling,
// and neutral reminder copy without making reminders exact alarms.
// Notes: BW-86B3 strengthens check-in and danger-window nudge copy.
// Notes: BW-NOTIFY-01A adds privacy-aware test delivery and readiness status.
// ------------------------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../privacy/privacy_settings.dart';
import '../privacy/privacy_settings_store.dart';
import '../triggers/triggers_selection.dart';
import 'notification_readiness.dart';
import 'notification_reliability.dart';
import 'reminder_settings.dart';

class BreakWaveNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 2201;
  static const int riskyNudgeId = 2202;
  static const int testNotificationId = 2203;
  static const int reliabilityProofId = 2204;

  static const String notificationIconName = 'ic_stat_breakwave';
  static const String fallbackNotificationIconName = '@mipmap/ic_launcher';

  static bool _initialized = false;
  static Future<void>? _initializationFuture;
  static bool _timeZoneReady = false;
  static String? _timeZoneIdentifier;

  static Future<void> initialize() {
    if (_initialized) {
      return Future<void>.value();
    }

    final Future<void>? pendingInitialization =
        _initializationFuture;
    if (pendingInitialization != null) {
      return pendingInitialization;
    }

    final Future<void> initialization = _initializeOnce();
    _initializationFuture = initialization;
    return initialization;
  }

  static Future<void> _initializeOnce() async {
    try {
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
    } finally {
      _initializationFuture = null;
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      final String identifier = currentTimeZone.identifier;
      tz.setLocalLocation(tz.getLocation(identifier));
      _timeZoneIdentifier = identifier;
      _timeZoneReady = true;
    } catch (_) {
      _timeZoneIdentifier = null;
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

  static Future<NotificationReadiness> readReadiness() async {
    String? errorMessage;
    final bool initialized = await safeInitialize();
    bool? notificationsEnabled;

    if (initialized) {
      try {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        notificationsEnabled = await android?.areNotificationsEnabled();
      } catch (_) {
        errorMessage = 'Unable to read Android notification permission.';
      }
    } else {
      errorMessage = 'Unable to initialize the notification service.';
    }

    final NotificationPermissionStatus permissionStatus;
    if (notificationsEnabled == true) {
      permissionStatus = NotificationPermissionStatus.enabled;
    } else if (notificationsEnabled == false) {
      permissionStatus = NotificationPermissionStatus.disabled;
    } else {
      permissionStatus = NotificationPermissionStatus.unavailable;
    }

    return NotificationReadiness(
      initialized: initialized,
      timeZoneReady: _timeZoneReady,
      timeZoneIdentifier: _timeZoneIdentifier,
      permissionStatus: permissionStatus,
      errorMessage: errorMessage,
    );
  }

  static Future<TestNotificationResult> sendTestNotification() async {
    final bool permissionGranted = await safeRequestPermissions();
    NotificationReadiness readiness = await readReadiness();

    if (!permissionGranted ||
        readiness.permissionStatus ==
            NotificationPermissionStatus.disabled) {
      return TestNotificationResult(
        outcome: TestNotificationOutcome.permissionDenied,
        readiness: readiness,
      );
    }

    if (!readiness.initialized) {
      return TestNotificationResult(
        outcome: TestNotificationOutcome.failed,
        readiness: readiness,
      );
    }

    if (readiness.permissionStatus ==
        NotificationPermissionStatus.unavailable) {
      return TestNotificationResult(
        outcome: TestNotificationOutcome.unavailable,
        readiness: readiness,
      );
    }

    try {
      final PrivacySettings privacy = await PrivacySettingsStore.load();
      final TestNotificationCopy copy = TestNotificationCopy.forPrivacy(
        discreetNotifications: privacy.discreetNotifications,
      );

      await _showNowWithIconFallback(
        id: testNotificationId,
        title: copy.title,
        body: copy.body,
      );

      readiness = await readReadiness();
      return TestNotificationResult(
        outcome: TestNotificationOutcome.shown,
        readiness: readiness,
      );
    } catch (_) {
      readiness = await readReadiness();
      return TestNotificationResult(
        outcome: TestNotificationOutcome.failed,
        readiness: readiness,
      );
    }
  }

  static Future<void> _showNowWithIconFallback({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(useCustomIcon: true),
      );
    } catch (_) {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(useCustomIcon: false),
      );
    }
  }

  static Future<bool> canScheduleExactAlarms() async {
    try {
      await initialize();
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final bool? allowed = await android?.canScheduleExactNotifications();
      return allowed ?? true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestExactAlarmAccess() async {
    try {
      await initialize();
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? alreadyAllowed =
          await android?.canScheduleExactNotifications();
      if (alreadyAllowed != false) {
        return alreadyAllowed ?? true;
      }

      final bool? granted =
          await android?.requestExactAlarmsPermission();
      if (granted != null) {
        return granted;
      }
      return canScheduleExactAlarms();
    } catch (_) {
      return false;
    }
  }

  static Future<AndroidScheduleMode> _preferredScheduleMode() async {
    final bool exactAllowed = await canScheduleExactAlarms();
    return exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<ScheduledProofResult> scheduleReliabilityProof({
    Duration delay = const Duration(minutes: 5),
  }) async {
    final bool permissionGranted = await safeRequestPermissions();
    NotificationReadiness readiness = await readReadiness();

    if (!permissionGranted ||
        readiness.permissionStatus ==
            NotificationPermissionStatus.disabled) {
      return ScheduledProofResult(
        outcome: ScheduledProofOutcome.permissionDenied,
        readiness: readiness,
      );
    }

    if (!readiness.initialized) {
      return ScheduledProofResult(
        outcome: ScheduledProofOutcome.failed,
        readiness: readiness,
      );
    }

    if (!readiness.timeZoneReady ||
        readiness.permissionStatus ==
            NotificationPermissionStatus.unavailable) {
      return ScheduledProofResult(
        outcome: ScheduledProofOutcome.unavailable,
        readiness: readiness,
      );
    }

    try {
      final PrivacySettings privacy = await PrivacySettingsStore.load();
      final ScheduledProofCopy copy = ScheduledProofCopy.forPrivacy(
        discreetNotifications: privacy.discreetNotifications,
      );
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(delay);

      await _plugin.cancel(id: reliabilityProofId);
      await _scheduleOneShotWithIconFallback(
        id: reliabilityProofId,
        title: copy.title,
        body: copy.body,
        scheduledDate: scheduledDate,
      );

      readiness = await readReadiness();
      return ScheduledProofResult(
        outcome: ScheduledProofOutcome.scheduled,
        readiness: readiness,
        scheduledFor: scheduledDate,
      );
    } catch (_) {
      readiness = await readReadiness();
      return ScheduledProofResult(
        outcome: ScheduledProofOutcome.failed,
        readiness: readiness,
      );
    }
  }

  static Future<void> _scheduleOneShotWithIconFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      await _scheduleOneShot(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        useCustomIcon: true,
      );
    } catch (_) {
      await _scheduleOneShot(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        useCustomIcon: false,
      );
    }
  }

  static Future<void> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required bool useCustomIcon,
  }) async {
    final AndroidScheduleMode scheduleMode =
        await _preferredScheduleMode();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details(
        useCustomIcon: useCustomIcon,
      ),
      androidScheduleMode: scheduleMode,
    );
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
  }) async {
    final AndroidScheduleMode scheduleMode =
        await _preferredScheduleMode();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details(
        useCustomIcon: useCustomIcon,
      ),
      androidScheduleMode: scheduleMode,
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
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
