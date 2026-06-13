import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chronic_care/services/account_scoped_storage.dart';
import 'package:chronic_care/services/api_client.dart';
import 'package:chronic_care/services/notification_service.dart';
import 'package:chronic_care/services/token_service.dart';
import 'package:chronic_care/widgets/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'choose_your_condition.dart';
import 'cubit/theme_cubit.dart';
import 'main_activity/main_container.dart';
import 'sign_up_screen.dart';
import 'cubit/health_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/locale_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final HealthCubit healthCubit = HealthCubit();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.init();

  await NotificationService.init();

  NotificationService.navigatorKey = navigatorKey;
  NotificationService.cubit        = healthCubit;

  await AndroidAlarmManager.initialize();
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
        BlocProvider.value(value: healthCubit),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()..loadSavedLang()),
        BlocProvider(
          create: (ctx) {
            final auth = AuthCubit();
            final health = ctx.read<HealthCubit>();
            auth.onUserSwitched = () => health.reloadForCurrentUser();
            return auth;
          },
        ),
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
              textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
              child: MaterialApp(
                title: 'ChroniCare',
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
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

  final prefs     = await SharedPreferences.getInstance();
  final list      = prefs.getStringList('reminder_entries') ?? [];
  final reminders = list.map((e) => ReminderEntry.fromJson(e)).toList();

  await NotificationService.rescheduleAll(reminders);
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  Future<_RootRoute> _decide() async {
    final prefs    = await SharedPreferences.getInstance();
    final token    = await TokenStorage.getAccessToken();
    final loggedIn = prefs.getBool("is_logged_in") == true;
    final guest    = prefs.getBool("is_guest") == true;

    final isAuthenticated =
        loggedIn && token != null && (guest || token.isNotEmpty);

    if (!isAuthenticated) return _RootRoute.signUp;

    try {
      final store = await AccountScopedStorage.forCurrentUser();
      final onboardingDone = store.getBool('onboarding_completed') ?? false;
      return onboardingDone ? _RootRoute.main : _RootRoute.onboarding;
    } catch (_) {
      // No active user namespace yet — treat as not onboarded
      return _RootRoute.onboarding;
    }
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
      child: FutureBuilder<_RootRoute>(
        future: _decide(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          switch (snapshot.data!) {
            case _RootRoute.main:
              return const MainContainer();
            case _RootRoute.onboarding:
              return const ChooseYourCondition();
            case _RootRoute.signUp:
              return const SignUpScreen();
          }
        },
      ),
    );
  }
}

enum _RootRoute { signUp, onboarding, main }