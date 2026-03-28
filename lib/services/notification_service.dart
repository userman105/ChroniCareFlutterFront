import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import '../widgets/alarm_screen.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request Android 13+ permission
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static NotificationDetails _details(String title) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders_channel',
        'Reminders',
        channelDescription: 'Health reminders',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('notification'), // uses system default if not found
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(title),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static Future<void> scheduleReminder(ReminderEntry entry) async {
    // Cancel any existing notifications for this reminder first
    await cancelReminder(entry);

    for (int i = 0; i < entry.times.length; i++) {
      final time = entry.times[i];
      final id = _idFor(entry, i);

      if (entry.schedule == 'Once') {

        final scheduled = _nextInstanceOf(time, entry.startDate);

        await _plugin.zonedSchedule(
          id,
          _titleFor(entry),
          _bodyFor(entry),
          tz.TZDateTime.from(scheduled, tz.local),
          _details(_bodyFor(entry)),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {

        DateTimeComponents? matchComponent;

        switch (entry.frequency) {
          case 'Daily':
            matchComponent = DateTimeComponents.time;
            break;
          case 'Weekly':
            matchComponent = DateTimeComponents.dayOfWeekAndTime;
            break;
          case 'Monthly':
            matchComponent = DateTimeComponents.dayOfMonthAndTime;
            break;
          default:
            matchComponent = DateTimeComponents.time;
        }

        final scheduled = _nextInstanceOf(time, entry.startDate);

        await _plugin.zonedSchedule(
          id,
          _titleFor(entry),
          _bodyFor(entry),
          tz.TZDateTime.from(scheduled, tz.local),
          _details(_bodyFor(entry)),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponent,
        );
      }
    }
  }

  static Future<void> cancelReminder(ReminderEntry entry) async {
    for (int i = 0; i < entry.times.length; i++) {
      await _plugin.cancel(_idFor(entry, i));
    }
  }


  static int _idFor(ReminderEntry entry, int timeIndex) {
    return (entry.createdAt.millisecondsSinceEpoch + timeIndex) % 0x7FFFFFFF;
  }

  static String _titleFor(ReminderEntry entry) {
    return entry.reminderName ?? entry.medicineName;
  }

  static String _bodyFor(ReminderEntry entry) {
    final type = entry.type.replaceAll('_', ' ');
    return entry.notes != null && entry.notes!.isNotEmpty
        ? '${entry.medicineName} • ${entry.notes}'
        : '${entry.medicineName} ($type)';
  }

  static DateTime _nextInstanceOf(TimeOfDay time, DateTime startDate) {
    final now = DateTime.now();
    var candidate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      time.hour,
      time.minute,
    );

    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }
}