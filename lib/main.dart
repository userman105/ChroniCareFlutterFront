import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chronic_care/services/api_client.dart';
import 'package:chronic_care/services/notification_service.dart';
import 'package:chronic_care/services/token_service.dart';
import 'package:chronic_care/widgets/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_activity/main_container.dart';
import 'sign_up_screen.dart';
import 'cubit/health_cubit.dart';
import 'cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.init();

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
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HealthCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
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

      home: const RootDecider(),
    );
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleNotificationsCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('reminders') ?? [];

  final reminders = list.map((e) => ReminderEntry.fromJson(e)).toList();

  for (final r in reminders) {
    await NotificationService.scheduleReminder(r);
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await TokenStorage.getAccessToken();

    final loggedIn = prefs.getBool("is_logged_in") == true;
    final guest = prefs.getBool("is_guest") == true;

    return loggedIn && token != null && (guest || token.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snapshot.data as bool;

        if (loggedIn) {
          return const MainContainer(tiles: []);
        }

        return const SignUpScreen();
      },
    );
  }
}