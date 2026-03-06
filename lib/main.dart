import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

void main() {
  runApp(const MyApp());
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