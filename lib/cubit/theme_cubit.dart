import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark) {
    loadTheme();
  }

  void toggleTheme(bool isLight) async {
    final prefs = await SharedPreferences.getInstance();
    final mode = isLight ? ThemeMode.light : ThemeMode.dark;

    await prefs.setBool('is_light_mode', isLight);
    emit(mode);
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool('is_light_mode') ?? false;
    emit(isLight ? ThemeMode.light : ThemeMode.dark);
  }
}