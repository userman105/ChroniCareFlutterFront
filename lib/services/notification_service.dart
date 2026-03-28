import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import '../widgets/alarm_screen.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Init ───────────────────────────────────────────────────────────────────
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
    await _plugin
        .resolvePlatformSpecificImplementation
    AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Notification details ───────────────────────────────────────────────────
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

  // ── Schedule all times for a reminder ─────────────────────────────────────
  static Future<void> scheduleReminder(ReminderEntry entry) async {
    // Cancel any existing notifications for this reminder first
    await cancelReminder(entry);

    for (int i = 0; i < entry.times.length; i++) {
      final time = entry.times[i];
      final id = _idFor(entry, i);

      if (entry.schedule == 'Once') {
        // ── One-time notification ──────────────────────────────
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
        // ── Recurring notification ─────────────────────────────
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

  // ── Cancel all notifications for a reminder ────────────────────────────────
  static Future<void> cancelReminder(ReminderEntry entry) async {
    for (int i = 0; i < entry.times.length; i++) {
      await _plugin.cancel(_idFor(entry, i));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  // Unique ID per reminder+time slot using hashCode
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

  // Returns the next DateTime at the given TimeOfDay on or after startDate
  static DateTime _nextInstanceOf(TimeOfDay time, DateTime startDate) {
    final now = DateTime.now();
    var candidate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      time.hour,
      time.minute,
    );

    // If that time has already passed today, push to tomorrow
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }
}