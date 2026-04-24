import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chronic_care/services/api_client.dart';
import 'package:chronic_care/services/notification_service.dart';
import 'package:chronic_care/services/token_service.dart';
import 'package:chronic_care/widgets/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubit/theme_cubit.dart';
import 'main_activity/main_container.dart';
import 'sign_up_screen.dart';
import 'cubit/health_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/locale_cubit.dart';

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
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()..loadSavedLang()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, lang) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return Directionality(
              textDirection:
              lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
              child: MaterialApp(
                title: 'ChroniCare',
                debugShowCheckedModeBanner: false,

                themeMode: mode,

                theme: ThemeData(
                  brightness: Brightness.light,
                  fontFamily: "arimo",
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: const Color(0xFF00C950),
                ),

                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: "arimo",
                  scaffoldBackgroundColor: const Color(0xFF111111),
                  primaryColor: const Color(0xFF00C950),
                ),

                home: const RootDecider(),
              ),
            );
          },
        );
      },
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                (route) => false,
          );
        }
      },
      child: FutureBuilder(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final loggedIn = snapshot.data as bool;

          if (loggedIn) {
            return const MainContainer();
          }

          return const SignUpScreen();
        },
      ),
    );
  }
}