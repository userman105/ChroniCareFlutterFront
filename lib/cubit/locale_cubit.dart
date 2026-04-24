import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit() : super("en");

  void changeLang(String lang) {
    emit(lang);
  }

  void loadSavedLang() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString("lang") ?? "en";
    emit(lang);
  }

}