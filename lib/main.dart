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
import 'dart:async';

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

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  Widget? _targetScreen;

  Future<_RootRoute> _decide() async {
    final prefs = await SharedPreferences.getInstance();

    if (AppConfig.guestMode) {
      final onboardingDone =
          prefs.getBool('guest_onboarding_completed') ?? false;

      return onboardingDone
          ? _RootRoute.main
          : _RootRoute.onboarding;
    }

    final token = await TokenStorage.getAccessToken();
    final loggedIn = prefs.getBool("is_logged_in") == true;
    final guest = prefs.getBool("is_guest") == true;

    final isAuthenticated =
        loggedIn && token != null && (guest || token.isNotEmpty);

    if (!isAuthenticated) {
      return _RootRoute.signUp;
    }

    try {
      final store = await AccountScopedStorage.forCurrentUser();

      final onboardingDone =
          store.getBool('onboarding_completed') ?? false;

      return onboardingDone
          ? _RootRoute.main
          : _RootRoute.onboarding;
    } catch (_) {
      return _RootRoute.onboarding;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    await _ensureGuestLogin();

    final route = await _decide();

    // Keep splash visible briefly
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    switch (route) {
      case _RootRoute.main:
        _targetScreen = const MainContainer();
        break;

      case _RootRoute.onboarding:
        _targetScreen = const ChooseYourCondition();
        break;

      case _RootRoute.signUp:
        _targetScreen = const SignUpScreen();
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const SignUpScreen(),
            ),
                (route) => false,
          );
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _targetScreen ?? const _SplashScreen(),
      ),
    );
  }
  Future<void> _ensureGuestLogin() async {
    if (!AppConfig.guestMode) return;

    final prefs = await SharedPreferences.getInstance();

    // Already initialized
    if (prefs.getBool("is_guest") == true) {
      return;
    }

    await prefs.setBool("is_logged_in", true);
    await prefs.setBool("is_guest", true);

    // Optional fake token if your code expects one
    await TokenStorage.saveAccessToken("guest-token");
  }
}

enum _RootRoute { signUp, onboarding, main }

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (value * 0.1),
                child: child,
              ),
            );
          },
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 2,
                  color: Colors.black.withValues(
                   alpha: isDark ? 0.25 : 0.08,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                'assets/logos/appIcon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class AppConfig {
  static const bool guestMode =
  bool.fromEnvironment('GUEST_MODE', defaultValue: false);
}
// flutter build apk --release --dart-define=GUEST_MODE=true