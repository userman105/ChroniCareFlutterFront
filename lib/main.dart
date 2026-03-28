import 'package:chronic_care/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sign_up_screen.dart';
import 'cubit/health_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

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