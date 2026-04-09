import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chronic_care/services/notification_service.dart';
import 'package:chronic_care/widgets/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up_screen.dart';
import 'cubit/health_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();
  await NotificationService.init();
  await AndroidAlarmManager.oneShot(
    const Duration(seconds: 5),
    999,
    rescheduleNotificationsCallback,
    exact: true,
    wakeup: true,
  );

  runApp(
    BlocProvider(
      create: (_) => HealthCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChroniCare',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: "BonaNova",
        scaffoldBackgroundColor: Colors.white,
      ),

      home: SignUpScreen(),
    );
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleNotificationsCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('reminders') ?? [];

  final reminders = list
      .map((e) => ReminderEntry.fromJson(e))
      .toList();

  for (final r in reminders) {
    await NotificationService.scheduleReminder(r);
  }
}