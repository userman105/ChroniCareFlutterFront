import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../widgets/alarm_screen.dart';
import '../cubit/health_cubit.dart';
import '../main_activity/blood_log/blood_log_screen.dart';
import '../main_activity/glucose_log/glucose_log_screen.dart';
import '../main_activity/med_log/medication_log_screen.dart';
import '../main_activity/weight_log/weight_log_screen.dart';

// ─── REQUIRED MANIFEST PERMISSIONS ──────────────────────────────────────────
// Add ALL of these to AndroidManifest.xml inside <manifest>:
//
//   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
//   <uses-permission android:name="android.permission.WAKE_LOCK"/>
//   <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
//   <uses-permission android:name="android.permission.VIBRATE"/>
//   <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
//   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
//   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
//   <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
//
// Add inside <application>:
//   <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
//             android:exported="false"/>
//   <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
//             android:exported="true">
//     <intent-filter>
//       <action android:name="android.intent.action.BOOT_COMPLETED"/>
//       <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
//     </intent-filter>
//   </receiver>
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  // Background isolate — keep minimal, no UI access
  debugPrint('[NS-BG] background response: ${response.actionId}');
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _alarmChannelId = 'reminders_alarm_channel';
  static const _dayChannelId   = 'reminders_day_channel';

  static GlobalKey<NavigatorState>? navigatorKey;
  static HealthCubit? cubit;

  // ─── INIT ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    final String tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // ← iOS critical alerts (bypass silent mode)
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ── Request permissions ONCE, with null-safety ──
    if (androidPlugin != null) {
      final notifGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      debugPrint('[NS] notifications permission: $notifGranted');

      final exactGranted =
          await androidPlugin.requestExactAlarmsPermission() ?? false;
      debugPrint('[NS] exact alarms permission: $exactGranted');

      // ── Alarm channel: MAX importance, full-screen, DND-piercing ──
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _alarmChannelId,
          'Reminder Alarms',
          description: 'Fires when a reminder time arrives',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFFFF0000),
          sound: RawResourceAndroidNotificationSound('notification'),
          // showBadge keeps the dot on the app icon
          showBadge: true,
        ),
      );

      // ── Day channel: silent, drawer-only ──
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _dayChannelId,
          'Daily Reminder Alerts',
          description: 'Silent reminder shown in the drawer on reminder day',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        ),
      );
    }
  }

  // ─── RESPONSE HANDLING ────────────────────────────────────────────────────

  static void _onResponse(NotificationResponse response) {
    debugPrint('[NS] response: action=${response.actionId}');
    _handleAction(response.actionId, response.payload);
  }

  static void _handleAction(String? actionId, String? payload) {
    if (payload == null) return;

    final map         = jsonDecode(payload) as Map<String, dynamic>;
    final createdAtMs = map['createdAt'] as int;
    final timeIndex   = map['timeIndex'] as int;
    final type        = map['type']      as String;
    final today       = DateTime.now();

    ReminderEntry? reminder;
    try {
      reminder = cubit?.getReminders().firstWhere(
            (r) => r.createdAt.millisecondsSinceEpoch == createdAtMs,
      );
    } catch (_) {
      return;
    }
    if (reminder == null) return;

    if (actionId == 'skip_action') {
      cubit?.skipReminderLog(reminder, timeIndex, today);
      return;
    }

    cubit?.resolveReminderLog(reminder, timeIndex, today);

    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    Widget screen;
    switch (type) {
      case 'blood_pressure':
        screen = const BloodPressureScreen();
        break;
      case 'meds':
        screen = const MedicationLogScreen();
        break;
      case 'weight':
        screen = const WeightLogScreen();
        break;
      case 'glucose':
        screen = const GlucoseScreen();
        break;
      default:
        return;
    }

    nav.push(MaterialPageRoute(builder: (_) => screen));
  }

  // ─── NOTIFICATION DETAILS ─────────────────────────────────────────────────

  /// Invasive alarm: full-screen intent, lock-screen public, DND-bypass,
  /// LED, vibration, max importance, persistent until acted on.
  static NotificationDetails _alarmDetails(String body) => NotificationDetails(
    android: AndroidNotificationDetails(
      _alarmChannelId,
      'Reminder Alarms',
      channelDescription: 'Fires when a reminder time arrives',
      importance: Importance.max,
      priority: Priority.max,                                   // ← was high
      category: AndroidNotificationCategory.alarm,              // ← bypass DND
      sound: const RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]), // 3 pulses
      enableLights: true,
      ledColor: const Color(0xFFFF6B00),
      ledOnMs: 500,
      ledOffMs: 500,
      fullScreenIntent: true,                                   // ← shows over lock screen
      visibility: NotificationVisibility.public,                // ← full preview on lock screen
      autoCancel: false,                                        // ← stays until user acts
      ongoing: false,                                           // set true to make undismissable
      showWhen: true,
      ticker: 'Health reminder',
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: false,
        contentTitle: 'Health Reminder',
        summaryText: 'Tap to log',
      ),
      actions: const [
        AndroidNotificationAction(
          'log_action',
          '✔ Log Now',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'skip_action',
          '✖ Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive, // ← iOS 15+: breaks through Focus
    ),
  );

  static NotificationDetails _dayDetails(String body) => NotificationDetails(
    android: AndroidNotificationDetails(
      _dayChannelId,
      'Daily Reminder Alerts',
      channelDescription: 'Silent reminder shown in the drawer',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(body),
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    ),
  );

  // ─── SCHEDULE ────────────────────────────────────────────────────────────

  static Future<void> scheduleReminder(ReminderEntry entry) async {
    await cancelReminder(entry);

    for (int i = 0; i < entry.times.length; i++) {
      final time = entry.times[i];

      try {
        await _scheduleDayNotification(entry, i);
      } catch (e) {
        debugPrint('[NS] day notification failed: $e');
      }

      final alarmId = _alarmIdFor(entry, i);
      final payload = jsonEncode({
        'createdAt': entry.createdAt.millisecondsSinceEpoch,
        'timeIndex': i,
        'type':      entry.type,
      });

      final scheduled = _nextInstanceOf(time, entry.startDate);

      DateTimeComponents? matchComponent;
      if (entry.schedule != 'once') {
        switch (entry.frequency) {
          case 'weekly':
            matchComponent = DateTimeComponents.dayOfWeekAndTime;
            break;
          case 'monthly':
            matchComponent = DateTimeComponents.dayOfMonthAndTime;
            break;
          default:
            matchComponent = DateTimeComponents.time;
        }
      }

      await _scheduleWithFallback(
        id: alarmId,
        title: _titleFor(entry),
        body: _bodyFor(entry),
        scheduled: scheduled,
        details: _alarmDetails(_bodyFor(entry)),
        payload: payload,
        matchComponent: matchComponent,
      );
    }
  }

  /// Tries exactAllowWhileIdle → inexactAllowWhileIdle → instant show.
  /// The final fallback ensures something ALWAYS fires on heavily-restricted OEMs.
  static Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduled,
    required NotificationDetails details,
    required String payload,
    DateTimeComponents? matchComponent,
  }) async {
    // ── Attempt 1: exact (requires SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM) ──
    try {
      await _plugin.zonedSchedule(
        id, title, body, scheduled, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponent,
      );
      debugPrint('[NS] ✅ exact scheduled → $scheduled');
      return;
    } catch (e) {
      debugPrint('[NS] exact failed: $e');
    }

    // ── Attempt 2: inexact (works without exact-alarm permission) ──
    try {
      await _plugin.zonedSchedule(
        id, title, body, scheduled, details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponent,
      );
      debugPrint('[NS] ⚠️ inexact scheduled → $scheduled');
      return;
    } catch (e) {
      debugPrint('[NS] inexact failed: $e');
    }

    // ── Attempt 3: fire instantly so the user at least sees it now ──
    try {
      await _plugin.show(id, title, '(Immediate) $body', details,
          payload: payload);
      debugPrint('[NS] 🆘 instant fallback fired');
    } catch (e) {
      debugPrint('[NS] all modes failed: $e');
    }
  }

  static Future<void> _scheduleDayNotification(
      ReminderEntry entry, int timeIndex) async {
    final dayId    = _dayIdFor(entry, timeIndex);
    final time     = entry.times[timeIndex];
    final startDay = entry.startDate;
    final now      = DateTime.now();

    final body  = 'Reminder at ${_formatTime(time)}: ${_bodyFor(entry)}';
    final title = _titleFor(entry);

    var eightAm =
    DateTime(startDay.year, startDay.month, startDay.day, 8, 0);

    if (eightAm.isBefore(now)) {
      final reminderToday =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (reminderToday.isAfter(now)) {
        await _plugin.show(dayId, title, body, _dayDetails(body));
      }
      return;
    }

    await _plugin.zonedSchedule(
      dayId,
      title,
      body,
      tz.TZDateTime(
          tz.local, eightAm.year, eightAm.month, eightAm.day, 8, 0),
      _dayDetails(body),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── CANCEL ──────────────────────────────────────────────────────────────

  static Future<void> cancelReminder(ReminderEntry entry) async {
    for (int i = 0; i < entry.times.length; i++) {
      await _plugin.cancel(_alarmIdFor(entry, i));
      await _plugin.cancel(_dayIdFor(entry, i));
    }
  }

  // ─── RESCHEDULE AFTER BOOT ───────────────────────────────────────────────
  // Call this from your boot-receiver or from initState in your root widget
  // after the app launches, so alarms survive device restarts.

  static Future<void> rescheduleAll(List<ReminderEntry> reminders) async {
    final now = DateTime.now();
    for (final r in reminders) {
      if (r.endDate != null && r.endDate!.isBefore(now)) continue;
      await scheduleReminder(r);
    }
    debugPrint('[NS] ♻️ rescheduled ${reminders.length} reminders after boot');
  }

  // ─── SYNC TO DRAWER ──────────────────────────────────────────────────────

  static Future<void> syncUpcomingToDrawer(
      List<ReminderEntry> reminders) async {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int id = 50000; id < 51000; id++) {
      await _plugin.cancel(id);
    }

    int idCounter = 50000;

    for (final reminder in reminders) {
      if (reminder.startDate.isAfter(now)) continue;
      if (reminder.endDate != null &&
          reminder.endDate!.isBefore(today)) {
        continue;
      }

      for (int i = 0; i < reminder.times.length; i++) {
        final t   = reminder.times[i];
        final due =
        DateTime(today.year, today.month, today.day, t.hour, t.minute);

        if (due.isBefore(now)) continue;

        final title = reminder.reminderName ?? reminder.medicineName;
        final body  = 'Due at ${_formatTime(t)} — ${_bodyFor(reminder)}';

        await _plugin.show(
          idCounter++,
          '$title',
          body,
          _dayDetails(body),
        );
      }
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  static int _alarmIdFor(ReminderEntry entry, int idx) =>
      (entry.createdAt.millisecondsSinceEpoch ~/ 1000 * 10 + idx) % 0x7FFFFFFF;

  static int _dayIdFor(ReminderEntry entry, int idx) =>
      (_alarmIdFor(entry, idx) + 0x3FFFFFFF) % 0x7FFFFFFF;

  static String _titleFor(ReminderEntry entry) =>
      entry.reminderName ?? entry.medicineName;

  static String _bodyFor(ReminderEntry entry) {
    final type = entry.type.replaceAll('_', ' ');
    return entry.notes != null && entry.notes!.isNotEmpty
        ? '${entry.medicineName} • ${entry.notes}'
        : '${entry.medicineName} ($type)';
  }

  static String _formatTime(TimeOfDay t) {
    final h  = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m  = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ap';
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time, DateTime startDate) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      time.hour, time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ─── DEBUG HELPERS ────────────────────────────────────────────────────────

  static Future<void> testNotification() async {
    await _plugin.zonedSchedule(
      1,
      '🔔 TEST ALARM',
      'Fires in 5 seconds',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _alarmDetails('Test notification — 5 second delay'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showInstantTest() async {
    await _plugin.show(
      1001,
      '🔔 Instant Test',
      'If you see this, notifications are working on your device',
      _alarmDetails('Instant test fired successfully'),
    );
  }
}
