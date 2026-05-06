import 'dart:convert';
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

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _alarmChannelId = 'reminders_alarm_channel';
  static const _dayChannelId   = 'reminders_day_channel';

  // Wired from main.dart before init() is called
  static GlobalKey<NavigatorState>? navigatorKey;
  static HealthCubit? cubit;

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    final String tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse:
      notificationBackgroundHandler,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('[NS] requestNotificationsPermission not supported: $e');
    }

    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('[NS] requestExactAlarmsPermission not supported: $e');
    }

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alarmChannelId,
        'Reminder Alarms',
        description: 'Plays sound when a reminder time arrives',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _dayChannelId,
        'Daily Reminder Alerts',
        description: 'Silent notification shown in the drawer on reminder day',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  static void _onResponse(NotificationResponse response) {
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
      return; // reminder was deleted
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

  static NotificationDetails _alarmDetails(String body) => NotificationDetails(
    android: AndroidNotificationDetails(
      _alarmChannelId,
      'Reminder Alarms',
      channelDescription: 'Plays sound when a reminder time arrives',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
      actions: const [
        AndroidNotificationAction(
          'log_action',
          'Log',
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
    ),
  );

  static NotificationDetails _dayDetails(String body) => NotificationDetails(
    android: AndroidNotificationDetails(
      _dayChannelId,
      'Daily Reminder Alerts',
      channelDescription:
      'Silent notification shown in the drawer on reminder day',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(body),
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    ),
  );

  static Future<void> scheduleReminder(ReminderEntry entry) async {
    await cancelReminder(entry);

    for (int i = 0; i < entry.times.length; i++) {
      final time = entry.times[i];

      try { await _scheduleDayNotification(entry, i); } catch (e) {
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
          case 'weekly':  matchComponent = DateTimeComponents.dayOfWeekAndTime; break;
          case 'monthly': matchComponent = DateTimeComponents.dayOfMonthAndTime; break;
          default:        matchComponent = DateTimeComponents.time;
        }
      }

      try {
        await _plugin.zonedSchedule(
          alarmId,
          _titleFor(entry),
          _bodyFor(entry),
          scheduled,
          _alarmDetails(_bodyFor(entry)),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponent,
        );
        debugPrint('[NS] exact alarm set for $scheduled');
      } catch (e) {
        debugPrint('[NS] ️exact failed: $e — trying inexact');
        try {
          await _plugin.zonedSchedule(
            alarmId,
            _titleFor(entry),
            _bodyFor(entry),
            scheduled,
            _alarmDetails(_bodyFor(entry)),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: matchComponent,
          );
          debugPrint('[NS] inexact alarm set for $scheduled');
        } catch (e2) {
          debugPrint('[NS] both modes failed: $e2');
        }
      }
    }
  }

  static Future<void> _scheduleDayNotification(
      ReminderEntry entry, int timeIndex) async {
    final dayId    = _dayIdFor(entry, timeIndex);
    final time     = entry.times[timeIndex];
    final startDay = entry.startDate;
    final now      = DateTime.now();

    final body  = 'Reminder at ${_formatTime(time)}: ${_bodyFor(entry)}';
    final title = '${_titleFor(entry)}';

    var eightAm = DateTime(
        startDay.year, startDay.month, startDay.day, 8, 0);

    if (eightAm.isBefore(now)) {

      final reminderToday = DateTime(
          now.year, now.month, now.day, time.hour, time.minute);

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
        tz.local,
        eightAm.year,
        eightAm.month,
        eightAm.day,
        8,
        0,
      ),
      _dayDetails(body),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(ReminderEntry entry) async {
    for (int i = 0; i < entry.times.length; i++) {
      await _plugin.cancel(_alarmIdFor(entry, i));
      await _plugin.cancel(_dayIdFor(entry, i));
    }
  }

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

  // ✅ Returns tz.TZDateTime directly — no conversion needed at call site
  static tz.TZDateTime _nextInstanceOf(TimeOfDay time, DateTime startDate) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If today already passed → push to next day
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<void> testNotification() async {
    await _plugin.zonedSchedule(
      1,
      "TEST",
      "Fires in 5 seconds",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _alarmDetails("test"),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showInstantTest() async {
    await _plugin.show(
      1001,
      " Instant Test",
      "If you see this, notifications are working",
      _alarmDetails("instant test"),
    );
  }

  static Future<void> syncUpcomingToDrawer(List<ReminderEntry> reminders) async {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Clear old synced notifications before reposting
    for (int id = 50000; id < 51000; id++) {
      await _plugin.cancel(id);
    }

    int idCounter = 50000;

    for (final reminder in reminders) {
      if (reminder.startDate.isAfter(now)) continue;
      if (reminder.endDate != null && reminder.endDate!.isBefore(today)) continue;

      for (int i = 0; i < reminder.times.length; i++) {
        final t   = reminder.times[i];
        final due = DateTime(today.year, today.month, today.day, t.hour, t.minute);

        // Only upcoming (not yet passed)
        if (due.isBefore(now)) continue;

        final title = reminder.reminderName ?? reminder.medicineName;
        final body  = 'Due at ${_formatTime(t)} — ${_bodyFor(reminder)}';

        await _plugin.show(
          idCounter++,
          ' $title',
          body,
          _dayDetails(body),
        );
      }
    }
  }
}